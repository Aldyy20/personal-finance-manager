<?php

namespace App\Services;

use App\Exceptions\EntityConflictException;
use App\Exceptions\FinancialValidationException;
use App\Exceptions\OwnershipViolationException;
use App\Models\Account;
use App\Models\Category;
use App\Models\Device;
use App\Models\Transaction;
use App\Models\TransactionRevision;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Str;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

/**
 * Handles income, expense, revision/reversal edits, and void operations.
 */
class TransactionService
{
    private const STANDARD_TYPES = ['income', 'expense'];

    public function __construct(
        private readonly LedgerService $ledgerService,
        private readonly UserBootstrapService $syncRecorder,
    ) {}

    /**
     * Creates an income or expense transaction with an atomic signed ledger movement and audit revision.
     *
     * @param  array<string, mixed>  $data
     */
    public function createTransaction(User $user, array $data): Transaction
    {
        $type = (string) ($data['type'] ?? '');
        if (! in_array($type, self::STANDARD_TYPES, true)) {
            throw new FinancialValidationException(
                'Transaction type must be income or expense.',
                ['type' => ['Type must be income or expense. Use TransferService for transfers.']]
            );
        }

        $amount = (int) ($data['amount'] ?? 0);
        if ($amount <= 0) {
            throw new FinancialValidationException(
                'Transaction amount must be greater than zero.',
                ['amount' => ['Amount must be greater than zero.']]
            );
        }

        $accountId = (string) ($data['account_id'] ?? '');
        $categoryId = (string) ($data['category_id'] ?? '');

        return $this->ledgerService->executeAtomically(function () use ($user, $data, $type, $amount, $accountId, $categoryId) {
            $deviceId = $data['created_by_device_id'] ?? null;
            $this->assertDeviceOwnership($user->id, $deviceId);

            $lockedAccounts = $this->ledgerService->lockAccountsInOrder($user->id, [$accountId]);
            /** @var Account $account */
            $account = $lockedAccounts->get($accountId);

            if (! $account->is_active) {
                throw new FinancialValidationException(
                    'Archived accounts cannot be used for new transactions.',
                    ['account_id' => ['Selected account is archived.']]
                );
            }

            $category = $this->validateCategoryForType($user->id, $categoryId, $type, requireActive: true);

            $txId = (string) ($data['id'] ?? Str::uuid());
            if (Transaction::withTrashed()->where('id', $txId)->exists()) {
                throw new EntityConflictException('Transaction ID already exists.');
            }

            $transaction = Transaction::query()->create([
                'id' => $txId,
                'user_id' => $user->id,
                'type' => $type,
                'category_id' => $category->id,
                'category_type' => $category->type,
                'amount' => $amount,
                'transaction_date' => $data['transaction_date'] ?? now()->utc(),
                'description' => $data['description'] ?? null,
                'notes' => $data['notes'] ?? null,
                'status' => 'posted',
                'created_by_device_id' => $deviceId,
                'version' => 1,
            ]);

            $signedAmount = $type === 'income' ? $amount : -$amount;
            $postingGroupId = (string) Str::uuid();
            $this->ledgerService->postTransactionMovement($account, $transaction, $signedAmount, $postingGroupId);

            $this->appendRevision(
                transaction: $transaction,
                action: 'create',
                beforeData: null,
                afterData: $this->buildTransactionSnapshot($transaction->fresh('movements')),
                reason: null,
                deviceId: $deviceId,
            );

            $this->bumpAccountsAndRecordSync($lockedAccounts, $user->id, $transaction, 'create');

            return $transaction->fresh(['movements', 'revisions', 'category']);
        });
    }

    /**
     * Edits an existing posted income/expense transaction using reversal + replacement posting.
     *
     * @param  array<string, mixed>  $data
     */
    public function updateTransaction(
        User $user,
        string $transactionId,
        array $data,
        ?int $baseVersion = null
    ): Transaction {
        return $this->ledgerService->executeAtomically(function () use ($user, $transactionId, $data, $baseVersion) {
            $transaction = $this->findAndLockOwnedTransaction($user->id, $transactionId);

            if (! in_array($transaction->type, self::STANDARD_TYPES, true)) {
                throw new FinancialValidationException(
                    'Use TransferService to edit transfer transactions.',
                    ['type' => ['Transfers must be edited through TransferService.']]
                );
            }

            if ($transaction->status !== 'posted') {
                throw new EntityConflictException('Voided transactions cannot be edited.');
            }

            $this->assertBaseVersion($transaction, $baseVersion);

            $deviceId = $data['device_id'] ?? $data['created_by_device_id'] ?? null;
            $this->assertDeviceOwnership($user->id, $deviceId);

            $activeMovements = $this->ledgerService->getActiveMovementsForTransaction($transaction->id);
            $oldAccountId = $activeMovements->first()?->account_id;
            if ($oldAccountId === null) {
                throw new EntityConflictException('Transaction has no active movements to revise.');
            }

            $newType = (string) ($data['type'] ?? $transaction->type);
            if (! in_array($newType, self::STANDARD_TYPES, true)) {
                throw new FinancialValidationException(
                    'Transaction type must be income or expense.',
                    ['type' => ['Type must be income or expense.']]
                );
            }

            $newAmount = (int) ($data['amount'] ?? $transaction->amount);
            if ($newAmount <= 0) {
                throw new FinancialValidationException(
                    'Transaction amount must be greater than zero.',
                    ['amount' => ['Amount must be greater than zero.']]
                );
            }

            $newAccountId = (string) ($data['account_id'] ?? $oldAccountId);
            $newCategoryId = (string) ($data['category_id'] ?? $transaction->category_id);

            $beforeSnapshot = $this->buildTransactionSnapshot($transaction->load('movements'));

            $lockedAccounts = $this->ledgerService->lockAccountsInOrder($user->id, [$oldAccountId, $newAccountId]);
            /** @var Account $targetAccount */
            $targetAccount = $lockedAccounts->get($newAccountId);

            if (! $targetAccount->is_active) {
                throw new FinancialValidationException(
                    'Archived accounts cannot be targeted for transaction updates.',
                    ['account_id' => ['Target account is archived.']]
                );
            }

            $requireActiveCategory = $newCategoryId !== $transaction->category_id;
            $category = $this->validateCategoryForType($user->id, $newCategoryId, $newType, $requireActiveCategory);

            $postingGroupId = (string) Str::uuid();
            $this->ledgerService->reverseActiveMovementsForTransaction($transaction, $postingGroupId);

            $transaction->type = $newType;
            $transaction->category_id = $category->id;
            $transaction->category_type = $category->type;
            $transaction->amount = $newAmount;
            $transaction->transaction_date = $data['transaction_date'] ?? $transaction->transaction_date;
            if (array_key_exists('description', $data)) {
                $transaction->description = $data['description'];
            }
            if (array_key_exists('notes', $data)) {
                $transaction->notes = $data['notes'];
            }
            $transaction->version = $transaction->version + 1;
            $transaction->save();

            $signedAmount = $newType === 'income' ? $newAmount : -$newAmount;
            $this->ledgerService->postTransactionMovement($targetAccount, $transaction, $signedAmount, $postingGroupId);

            $this->appendRevision(
                transaction: $transaction,
                action: 'edit',
                beforeData: $beforeSnapshot,
                afterData: $this->buildTransactionSnapshot($transaction->fresh('movements')),
                reason: $data['reason'] ?? null,
                deviceId: $deviceId,
            );

            $this->bumpAccountsAndRecordSync($lockedAccounts, $user->id, $transaction, 'update');

            return $transaction->fresh(['movements', 'revisions', 'category']);
        });
    }

    /**
     * Voids any posted transaction (income, expense, or transfer) via reversal movements.
     */
    public function voidTransaction(
        User $user,
        string $transactionId,
        ?string $reason = null,
        ?string $deviceId = null,
        ?int $baseVersion = null
    ): Transaction {
        return $this->ledgerService->executeAtomically(function () use ($user, $transactionId, $reason, $deviceId, $baseVersion) {
            $transaction = $this->findAndLockOwnedTransaction($user->id, $transactionId);

            if ($transaction->status === 'voided') {
                throw new EntityConflictException('Transaction is already voided.');
            }

            $this->assertBaseVersion($transaction, $baseVersion);
            $this->assertDeviceOwnership($user->id, $deviceId);

            $activeMovements = $this->ledgerService->getActiveMovementsForTransaction($transaction->id);
            /** @var list<string> $affectedAccountIds */
            $affectedAccountIds = $activeMovements->pluck('account_id')->all();
            $lockedAccounts = $this->ledgerService->lockAccountsInOrder($user->id, $affectedAccountIds);

            $beforeSnapshot = $this->buildTransactionSnapshot($transaction->load('movements'));

            $postingGroupId = (string) Str::uuid();
            $this->ledgerService->reverseActiveMovementsForTransaction($transaction, $postingGroupId);

            $transaction->status = 'voided';
            $transaction->version = $transaction->version + 1;
            $transaction->save();

            $this->appendRevision(
                transaction: $transaction,
                action: 'void',
                beforeData: $beforeSnapshot,
                afterData: $this->buildTransactionSnapshot($transaction->fresh('movements')),
                reason: $reason,
                deviceId: $deviceId,
            );

            $this->bumpAccountsAndRecordSync($lockedAccounts, $user->id, $transaction, 'void');

            return $transaction->fresh(['movements', 'revisions', 'category']);
        });
    }

    public function findAndLockOwnedTransaction(string $userId, string $transactionId): Transaction
    {
        $transaction = Transaction::query()->where('id', $transactionId)->lockForUpdate()->first();
        if ($transaction === null) {
            throw new NotFoundHttpException('Transaction not found.');
        }

        if ($transaction->user_id !== $userId) {
            throw new OwnershipViolationException('You do not have access to this transaction.');
        }

        return $transaction;
    }

    public function assertDeviceOwnership(string $userId, ?string $deviceId): void
    {
        if ($deviceId === null) {
            return;
        }

        $ownsDevice = Device::query()
            ->where('id', $deviceId)
            ->where('user_id', $userId)
            ->exists();

        if (! $ownsDevice) {
            throw new OwnershipViolationException('Device does not belong to the authenticated user.');
        }
    }

    public function assertBaseVersion(Transaction $transaction, ?int $baseVersion): void
    {
        if ($baseVersion !== null && $transaction->version !== $baseVersion) {
            throw new EntityConflictException('Transaction version conflict detected.', [
                'entity_type' => 'transactions',
                'entity_id' => $transaction->id,
                'server_version' => $transaction->version,
                'base_version' => $baseVersion,
            ]);
        }
    }

    /**
     * @return array<string, mixed>
     */
    public function buildTransactionSnapshot(Transaction $transaction): array
    {
        $activeMovements = $this->ledgerService->getActiveMovementsForTransaction($transaction->id);

        return [
            'id' => $transaction->id,
            'type' => $transaction->type,
            'category_id' => $transaction->category_id,
            'category_type' => $transaction->category_type,
            'amount' => $transaction->amount,
            'transaction_date' => $transaction->transaction_date?->utc()->toIso8601ZuluString('millisecond'),
            'description' => $transaction->description,
            'notes' => $transaction->notes,
            'status' => $transaction->status,
            'version' => $transaction->version,
            'active_movements' => $activeMovements->map(fn ($m) => [
                'id' => $m->id,
                'account_id' => $m->account_id,
                'amount_signed' => $m->amount_signed,
            ])->values()->all(),
        ];
    }

    /**
     * @param  array<string, mixed>|null  $beforeData
     * @param  array<string, mixed>  $afterData
     */
    public function appendRevision(
        Transaction $transaction,
        string $action,
        ?array $beforeData,
        array $afterData,
        ?string $reason,
        ?string $deviceId
    ): TransactionRevision {
        $latestNumber = (int) TransactionRevision::query()
            ->where('transaction_id', $transaction->id)
            ->max('revision_number');

        return TransactionRevision::query()->create([
            'id' => (string) Str::uuid(),
            'transaction_id' => $transaction->id,
            'user_id' => $transaction->user_id,
            'revision_number' => $latestNumber + 1,
            'action' => $action,
            'before_data' => $beforeData,
            'after_data' => $afterData,
            'reason' => $reason,
            'device_id' => $deviceId,
            'created_at' => now()->utc(),
        ]);
    }

    /**
     * @param  Collection<string, Account>  $accounts
     */
    public function bumpAccountsAndRecordSync(
        Collection $accounts,
        string $userId,
        Transaction $transaction,
        string $txSyncOperation
    ): void {
        $this->syncRecorder->recordSyncChange(
            $userId,
            'transactions',
            $transaction->id,
            $txSyncOperation,
            $transaction->version
        );

        foreach ($accounts as $account) {
            $account->version = $account->version + 1;
            $account->save();

            $this->syncRecorder->recordSyncChange(
                $userId,
                'accounts',
                $account->id,
                'update',
                $account->version
            );
        }
    }

    private function validateCategoryForType(
        string $userId,
        string $categoryId,
        string $expectedType,
        bool $requireActive
    ): Category {
        $category = Category::query()->where('id', $categoryId)->first();

        if ($category === null) {
            throw new FinancialValidationException(
                'Category not found.',
                ['category_id' => ['Selected category does not exist.']]
            );
        }

        if ($category->user_id !== $userId) {
            throw new OwnershipViolationException('Category belongs to another user.');
        }

        if ($requireActive && ! $category->is_active) {
            throw new FinancialValidationException(
                'Inactive categories cannot be selected.',
                ['category_id' => ['Selected category is inactive.']]
            );
        }

        if ($category->type !== $expectedType) {
            throw new FinancialValidationException(
                'Category type does not match transaction type.',
                ['category_id' => ["Category must be of type {$expectedType}."]]
            );
        }

        return $category;
    }
}

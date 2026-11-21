<?php

namespace App\Services;

use App\Exceptions\EntityConflictException;
use App\Exceptions\FinancialValidationException;
use App\Models\Account;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Support\Str;
use LogicException;

/**
 * Handles zero-sum inter-account transfers (one transaction + two opposite movements).
 */
class TransferService
{
    public function __construct(
        private readonly LedgerService $ledgerService,
        private readonly TransactionService $transactionService,
    ) {}

    /**
     * Creates an inter-account transfer with two balanced movements totaling zero.
     *
     * @param  array<string, mixed>  $data
     */
    public function createTransfer(User $user, array $data): Transaction
    {
        $amount = (int) ($data['amount'] ?? 0);
        if ($amount <= 0) {
            throw new FinancialValidationException(
                'Transfer amount must be greater than zero.',
                ['amount' => ['Transfer amount must be greater than zero.']]
            );
        }

        $sourceId = (string) ($data['source_account_id'] ?? '');
        $destinationId = (string) ($data['destination_account_id'] ?? '');

        if ($sourceId === '' || $destinationId === '') {
            throw new FinancialValidationException(
                'Source and destination accounts are required.',
                ['accounts' => ['Both source_account_id and destination_account_id are required.']]
            );
        }

        if ($sourceId === $destinationId) {
            throw new FinancialValidationException(
                'Source and destination accounts must be different.',
                ['destination_account_id' => ['Cannot transfer to the same account.']]
            );
        }

        return $this->ledgerService->executeAtomically(function () use ($user, $data, $amount, $sourceId, $destinationId) {
            $deviceId = $data['created_by_device_id'] ?? null;
            $this->transactionService->assertDeviceOwnership($user->id, $deviceId);

            $lockedAccounts = $this->ledgerService->lockAccountsInOrder($user->id, [$sourceId, $destinationId]);
            /** @var Account $sourceAccount */
            $sourceAccount = $lockedAccounts->get($sourceId);
            /** @var Account $destinationAccount */
            $destinationAccount = $lockedAccounts->get($destinationId);

            if (! $sourceAccount->is_active || ! $destinationAccount->is_active) {
                throw new FinancialValidationException(
                    'Archived accounts cannot be used for transfers.',
                    ['accounts' => ['Both source and destination accounts must be active.']]
                );
            }

            $txId = (string) ($data['id'] ?? Str::uuid());
            if (Transaction::withTrashed()->where('id', $txId)->exists()) {
                throw new EntityConflictException('Transfer transaction ID already exists.');
            }

            $transaction = Transaction::query()->create([
                'id' => $txId,
                'user_id' => $user->id,
                'type' => 'transfer',
                'category_id' => null,
                'category_type' => null,
                'amount' => $amount,
                'transaction_date' => $data['transaction_date'] ?? now()->utc(),
                'description' => $data['description'] ?? null,
                'notes' => $data['notes'] ?? null,
                'status' => 'posted',
                'created_by_device_id' => $deviceId,
                'version' => 1,
            ]);

            $postingGroupId = (string) Str::uuid();
            $debit = $this->ledgerService->postTransactionMovement($sourceAccount, $transaction, -$amount, $postingGroupId);
            $credit = $this->ledgerService->postTransactionMovement($destinationAccount, $transaction, $amount, $postingGroupId);

            if (($debit->amount_signed + $credit->amount_signed) !== 0) {
                throw new LogicException('Transfer movements failed zero-sum invariant.');
            }

            $this->transactionService->appendRevision(
                transaction: $transaction,
                action: 'create',
                beforeData: null,
                afterData: $this->transactionService->buildTransactionSnapshot($transaction->fresh('movements')),
                reason: null,
                deviceId: $deviceId,
            );

            $this->transactionService->bumpAccountsAndRecordSync($lockedAccounts, $user->id, $transaction, 'create');

            return $transaction->fresh(['movements', 'revisions']);
        });
    }

    /**
     * Edits an existing posted transfer via reversal of both movements + two replacement movements.
     *
     * @param  array<string, mixed>  $data
     */
    public function updateTransfer(
        User $user,
        string $transactionId,
        array $data,
        ?int $baseVersion = null
    ): Transaction {
        return $this->ledgerService->executeAtomically(function () use ($user, $transactionId, $data, $baseVersion) {
            $transaction = $this->transactionService->findAndLockOwnedTransaction($user->id, $transactionId);

            if ($transaction->type !== 'transfer') {
                throw new FinancialValidationException(
                    'Transaction is not a transfer.',
                    ['type' => ['Use TransactionService for income or expense transactions.']]
                );
            }

            if ($transaction->status !== 'posted') {
                throw new EntityConflictException('Voided transfers cannot be edited.');
            }

            $this->transactionService->assertBaseVersion($transaction, $baseVersion);

            $deviceId = $data['device_id'] ?? $data['created_by_device_id'] ?? null;
            $this->transactionService->assertDeviceOwnership($user->id, $deviceId);

            $activeMovements = $this->ledgerService->getActiveMovementsForTransaction($transaction->id);
            $oldDebit = $activeMovements->firstWhere('amount_signed', '<', 0);
            $oldCredit = $activeMovements->firstWhere('amount_signed', '>', 0);

            if ($oldDebit === null || $oldCredit === null) {
                throw new EntityConflictException('Transfer does not have balanced active movements.');
            }

            $newAmount = (int) ($data['amount'] ?? $transaction->amount);
            if ($newAmount <= 0) {
                throw new FinancialValidationException(
                    'Transfer amount must be greater than zero.',
                    ['amount' => ['Transfer amount must be greater than zero.']]
                );
            }

            $newSourceId = (string) ($data['source_account_id'] ?? $oldDebit->account_id);
            $newDestinationId = (string) ($data['destination_account_id'] ?? $oldCredit->account_id);

            if ($newSourceId === $newDestinationId) {
                throw new FinancialValidationException(
                    'Source and destination accounts must be different.',
                    ['destination_account_id' => ['Cannot transfer to the same account.']]
                );
            }

            $beforeSnapshot = $this->transactionService->buildTransactionSnapshot($transaction->load('movements'));

            $lockedAccounts = $this->ledgerService->lockAccountsInOrder($user->id, [
                $oldDebit->account_id,
                $oldCredit->account_id,
                $newSourceId,
                $newDestinationId,
            ]);

            /** @var Account $newSource */
            $newSource = $lockedAccounts->get($newSourceId);
            /** @var Account $newDestination */
            $newDestination = $lockedAccounts->get($newDestinationId);

            if (! $newSource->is_active || ! $newDestination->is_active) {
                throw new FinancialValidationException(
                    'Archived accounts cannot be targeted for transfers.',
                    ['accounts' => ['Target source and destination accounts must be active.']]
                );
            }

            $postingGroupId = (string) Str::uuid();
            $this->ledgerService->reverseActiveMovementsForTransaction($transaction, $postingGroupId);

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

            $debit = $this->ledgerService->postTransactionMovement($newSource, $transaction, -$newAmount, $postingGroupId);
            $credit = $this->ledgerService->postTransactionMovement($newDestination, $transaction, $newAmount, $postingGroupId);

            if (($debit->amount_signed + $credit->amount_signed) !== 0) {
                throw new LogicException('Updated transfer movements failed zero-sum invariant.');
            }

            $this->transactionService->appendRevision(
                transaction: $transaction,
                action: 'edit',
                beforeData: $beforeSnapshot,
                afterData: $this->transactionService->buildTransactionSnapshot($transaction->fresh('movements')),
                reason: $data['reason'] ?? null,
                deviceId: $deviceId,
            );

            $this->transactionService->bumpAccountsAndRecordSync($lockedAccounts, $user->id, $transaction, 'update');

            return $transaction->fresh(['movements', 'revisions']);
        });
    }

    public function voidTransfer(
        User $user,
        string $transactionId,
        ?string $reason = null,
        ?string $deviceId = null,
        ?int $baseVersion = null
    ): Transaction {
        $transaction = Transaction::query()->find($transactionId);
        if ($transaction !== null && $transaction->user_id === $user->id && $transaction->type !== 'transfer') {
            throw new FinancialValidationException(
                'Transaction is not a transfer.',
                ['type' => ['Use TransactionService to void income or expense transactions.']]
            );
        }

        return $this->transactionService->voidTransaction($user, $transactionId, $reason, $deviceId, $baseVersion);
    }
}

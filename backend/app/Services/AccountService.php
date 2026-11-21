<?php

namespace App\Services;

use App\Exceptions\EntityConflictException;
use App\Exceptions\FinancialValidationException;
use App\Exceptions\OwnershipViolationException;
use App\Models\Account;
use App\Models\AccountAdjustment;
use App\Models\Device;
use App\Models\User;
use Illuminate\Support\Str;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

/**
 * Manages user accounts, opening balances, archiving, and recorded balance adjustments.
 */
class AccountService
{
    private const VALID_ACCOUNT_TYPES = ['cash', 'bank', 'e_wallet', 'other'];

    public function __construct(
        private readonly LedgerService $ledgerService,
        private readonly UserBootstrapService $syncRecorder,
    ) {}

    /**
     * Atomically creates a new account and posts its single opening movement.
     *
     * @param  array<string, mixed>  $data
     */
    public function createAccount(User $user, array $data): Account
    {
        $accountType = $data['account_type'] ?? '';
        if (! in_array($accountType, self::VALID_ACCOUNT_TYPES, true)) {
            throw new FinancialValidationException(
                'Invalid account type.',
                ['account_type' => ['Account type must be one of: cash, bank, e_wallet, other.']]
            );
        }

        $name = trim((string) ($data['name'] ?? ''));
        if ($name === '') {
            throw new FinancialValidationException(
                'Account name is required.',
                ['name' => ['Account name is required.']]
            );
        }

        $openingBalance = (int) ($data['opening_balance'] ?? 0);
        $openingDate = (string) ($data['opening_balance_date'] ?? now()->utc()->toDateString());

        return $this->ledgerService->executeAtomically(function () use ($user, $data, $name, $accountType, $openingBalance, $openingDate) {
            $accountId = (string) ($data['id'] ?? Str::uuid());

            if (Account::withTrashed()->where('id', $accountId)->exists()) {
                throw new EntityConflictException('Account ID already exists.');
            }

            $account = Account::query()->create([
                'id' => $accountId,
                'user_id' => $user->id,
                'name' => $name,
                'account_type' => $accountType,
                'institution_name' => $data['institution_name'] ?? null,
                'account_number' => $data['account_number'] ?? null,
                'opening_balance' => $openingBalance,
                'opening_balance_date' => $openingDate,
                'balance_cache' => 0,
                'icon' => $data['icon'] ?? null,
                'color' => $data['color'] ?? null,
                'is_active' => true,
                'version' => 1,
            ]);

            $this->ledgerService->postOpeningMovement($account, $openingBalance);

            $this->syncRecorder->recordSyncChange($user->id, 'accounts', $account->id, 'create', 1);

            return $account->fresh();
        });
    }

    /**
     * Updates account metadata. Direct modification of opening_balance is prohibited.
     *
     * @param  array<string, mixed>  $data
     */
    public function updateAccount(User $user, string $accountId, array $data, ?int $baseVersion = null): Account
    {
        return $this->ledgerService->executeAtomically(function () use ($user, $accountId, $data, $baseVersion) {
            $account = $this->findAndLockOwnedAccount($user->id, $accountId);
            $this->assertVersion($account, $baseVersion);

            if (
                array_key_exists('opening_balance', $data) &&
                (int) $data['opening_balance'] !== (int) $account->opening_balance
            ) {
                throw new FinancialValidationException(
                    'Opening balance cannot be modified directly. Use an account adjustment instead.',
                    ['opening_balance' => ['Direct modification of opening_balance is not allowed.']]
                );
            }

            if (
                array_key_exists('account_type', $data) &&
                ! in_array($data['account_type'], self::VALID_ACCOUNT_TYPES, true)
            ) {
                throw new FinancialValidationException(
                    'Invalid account type.',
                    ['account_type' => ['Account type must be one of: cash, bank, e_wallet, other.']]
                );
            }

            $updatable = array_intersect_key($data, array_flip([
                'name',
                'account_type',
                'institution_name',
                'account_number',
                'icon',
                'color',
            ]));

            if (isset($updatable['name'])) {
                $updatable['name'] = trim((string) $updatable['name']);
                if ($updatable['name'] === '') {
                    throw new FinancialValidationException(
                        'Account name cannot be empty.',
                        ['name' => ['Account name cannot be empty.']]
                    );
                }
            }

            $account->fill($updatable);
            $account->version = $account->version + 1;
            $account->save();

            $this->syncRecorder->recordSyncChange($user->id, 'accounts', $account->id, 'update', $account->version);

            return $account->fresh();
        });
    }

    public function archiveAccount(User $user, string $accountId, ?int $baseVersion = null): Account
    {
        return $this->setAccountActiveState($user, $accountId, false, $baseVersion);
    }

    public function restoreAccount(User $user, string $accountId, ?int $baseVersion = null): Account
    {
        return $this->setAccountActiveState($user, $accountId, true, $baseVersion);
    }

    /**
     * Creates a recorded manual balance correction and posts its corresponding adjustment movement.
     *
     * @param  array<string, mixed>  $data
     */
    public function createAdjustment(User $user, string $accountId, array $data): AccountAdjustment
    {
        $amountSigned = (int) ($data['amount_signed'] ?? 0);
        if ($amountSigned === 0) {
            throw new FinancialValidationException(
                'Adjustment amount must be non-zero.',
                ['amount_signed' => ['Adjustment amount cannot be zero.']]
            );
        }

        $reason = trim((string) ($data['reason'] ?? ''));
        if ($reason === '') {
            throw new FinancialValidationException(
                'Adjustment reason is required.',
                ['reason' => ['Reason is required for balance adjustments.']]
            );
        }

        return $this->ledgerService->executeAtomically(function () use ($user, $accountId, $data, $amountSigned, $reason) {
            $account = $this->findAndLockOwnedAccount($user->id, $accountId);

            $deviceId = $data['created_by_device_id'] ?? null;
            if ($deviceId !== null) {
                $ownsDevice = Device::query()
                    ->where('id', $deviceId)
                    ->where('user_id', $user->id)
                    ->exists();
                if (! $ownsDevice) {
                    throw new OwnershipViolationException('Device does not belong to the authenticated user.');
                }
            }

            $adjustmentId = (string) ($data['id'] ?? Str::uuid());
            $adjustment = AccountAdjustment::query()->create([
                'id' => $adjustmentId,
                'user_id' => $user->id,
                'account_id' => $account->id,
                'amount_signed' => $amountSigned,
                'reason' => $reason,
                'created_by_device_id' => $deviceId,
                'created_at' => now()->utc(),
            ]);

            $this->ledgerService->postAdjustmentMovement($account, $adjustment, $amountSigned);

            $account->version = $account->version + 1;
            $account->save();

            $this->syncRecorder->recordSyncChange($user->id, 'account_adjustments', $adjustment->id, 'create', 1);
            $this->syncRecorder->recordSyncChange($user->id, 'accounts', $account->id, 'update', $account->version);

            return $adjustment->fresh();
        });
    }

    private function setAccountActiveState(User $user, string $accountId, bool $active, ?int $baseVersion): Account
    {
        return $this->ledgerService->executeAtomically(function () use ($user, $accountId, $active, $baseVersion) {
            $account = $this->findAndLockOwnedAccount($user->id, $accountId);
            $this->assertVersion($account, $baseVersion);

            $account->is_active = $active;
            $account->version = $account->version + 1;
            $account->save();

            $this->syncRecorder->recordSyncChange($user->id, 'accounts', $account->id, 'update', $account->version);

            return $account->fresh();
        });
    }

    private function findAndLockOwnedAccount(string $userId, string $accountId): Account
    {
        $account = Account::query()->where('id', $accountId)->lockForUpdate()->first();
        if ($account === null) {
            throw new NotFoundHttpException('Account not found.');
        }

        if ($account->user_id !== $userId) {
            throw new OwnershipViolationException('You do not have access to this account.');
        }

        return $account;
    }

    private function assertVersion(Account $account, ?int $baseVersion): void
    {
        if ($baseVersion !== null && $account->version !== $baseVersion) {
            throw new EntityConflictException('Account version conflict detected.', [
                'entity_type' => 'accounts',
                'entity_id' => $account->id,
                'server_version' => $account->version,
                'base_version' => $baseVersion,
            ]);
        }
    }
}

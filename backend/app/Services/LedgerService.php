<?php

namespace App\Services;

use App\Exceptions\EntityConflictException;
use App\Exceptions\FinancialValidationException;
use App\Exceptions\OwnershipViolationException;
use App\Models\Account;
use App\Models\AccountAdjustment;
use App\Models\AccountMovement;
use App\Models\Transaction;
use Closure;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Immutable Ledger Engine (Master PRD Section 5.5, 7 & 18.3).
 *
 * Account balances are strictly derived from SUM(account_movements.amount_signed).
 * Posted movements cannot be modified or deleted; edits and voids reverse active
 * movements and create replacement postings atomically.
 */
class LedgerService
{
    /**
     * Executes a financial operation inside an atomic DB transaction with deadlock retry.
     */
    public function executeAtomically(Closure $callback, int $attempts = 3): mixed
    {
        return DB::transaction($callback, $attempts);
    }

    /**
     * Locks user-owned accounts in deterministic UUID order to prevent deadlocks.
     *
     * @param  list<string>  $accountIds
     * @return Collection<string, Account>
     */
    public function lockAccountsInOrder(string $userId, array $accountIds): Collection
    {
        $uniqueIds = array_values(array_unique(array_filter($accountIds)));
        if ($uniqueIds === []) {
            throw new FinancialValidationException('At least one account ID is required.');
        }

        sort($uniqueIds, SORT_STRING);

        $accounts = Account::query()
            ->where('user_id', $userId)
            ->whereIn('id', $uniqueIds)
            ->orderBy('id')
            ->lockForUpdate()
            ->get()
            ->keyBy('id');

        if ($accounts->count() !== count($uniqueIds)) {
            throw new OwnershipViolationException('One or more accounts do not exist or belong to another user.');
        }

        return $accounts;
    }

    /**
     * Posts the single opening balance movement when an account is created.
     */
    public function postOpeningMovement(
        Account $account,
        int $openingBalance,
        ?string $postingGroupId = null
    ): AccountMovement {
        $alreadyExists = AccountMovement::query()
            ->where('account_id', $account->id)
            ->where('movement_type', 'opening')
            ->exists();

        if ($alreadyExists) {
            throw new EntityConflictException('Opening movement already exists for this account.');
        }

        $movement = AccountMovement::query()->create([
            'id' => (string) Str::uuid(),
            'user_id' => $account->user_id,
            'account_id' => $account->id,
            'transaction_id' => null,
            'adjustment_id' => null,
            'posting_group_id' => $postingGroupId ?? (string) Str::uuid(),
            'movement_type' => 'opening',
            'amount_signed' => $openingBalance,
            'reversal_of_id' => null,
            'created_at' => now()->utc(),
        ]);

        $this->reconcileAccountBalance($account);

        return $movement;
    }

    /**
     * Posts a signed transaction movement (+ for income/credit, - for expense/debit).
     */
    public function postTransactionMovement(
        Account $account,
        Transaction $transaction,
        int $amountSigned,
        string $postingGroupId
    ): AccountMovement {
        if ($amountSigned === 0) {
            throw new FinancialValidationException('Transaction movement amount cannot be zero.');
        }

        if ($account->user_id !== $transaction->user_id) {
            throw new OwnershipViolationException('Cross-user movement posting is prohibited.');
        }

        $movement = AccountMovement::query()->create([
            'id' => (string) Str::uuid(),
            'user_id' => $transaction->user_id,
            'account_id' => $account->id,
            'transaction_id' => $transaction->id,
            'adjustment_id' => null,
            'posting_group_id' => $postingGroupId,
            'movement_type' => 'transaction',
            'amount_signed' => $amountSigned,
            'reversal_of_id' => null,
            'created_at' => now()->utc(),
        ]);

        $this->reconcileAccountBalance($account);

        return $movement;
    }

    /**
     * Posts a signed manual account balance adjustment movement.
     */
    public function postAdjustmentMovement(
        Account $account,
        AccountAdjustment $adjustment,
        int $amountSigned,
        ?string $postingGroupId = null
    ): AccountMovement {
        if ($amountSigned === 0) {
            throw new FinancialValidationException('Adjustment movement amount cannot be zero.');
        }

        if ($account->user_id !== $adjustment->user_id) {
            throw new OwnershipViolationException('Cross-user adjustment posting is prohibited.');
        }

        $movement = AccountMovement::query()->create([
            'id' => (string) Str::uuid(),
            'user_id' => $adjustment->user_id,
            'account_id' => $account->id,
            'transaction_id' => null,
            'adjustment_id' => $adjustment->id,
            'posting_group_id' => $postingGroupId ?? (string) Str::uuid(),
            'movement_type' => 'adjustment',
            'amount_signed' => $amountSigned,
            'reversal_of_id' => null,
            'created_at' => now()->utc(),
        ]);

        $this->reconcileAccountBalance($account);

        return $movement;
    }

    /**
     * Retrieves all un-reversed transaction movements for a transaction.
     *
     * @return Collection<int, AccountMovement>
     */
    public function getActiveMovementsForTransaction(string $transactionId): Collection
    {
        return AccountMovement::query()
            ->where('transaction_id', $transactionId)
            ->where('movement_type', 'transaction')
            ->whereNotExists(function ($query) {
                $query->select(DB::raw(1))
                    ->from('account_movements as rev')
                    ->whereColumn('rev.reversal_of_id', 'account_movements.id');
            })
            ->orderBy('id')
            ->get();
    }

    /**
     * Creates exact opposite reversal movements for all active movements of a transaction.
     *
     * @return Collection<int, AccountMovement>
     */
    public function reverseActiveMovementsForTransaction(
        Transaction $transaction,
        string $postingGroupId
    ): Collection {
        $activeMovements = $this->getActiveMovementsForTransaction($transaction->id);

        if ($activeMovements->isEmpty()) {
            throw new EntityConflictException('No active movements remain to reverse for this transaction.');
        }

        /** @var list<string> $accountIds */
        $accountIds = $activeMovements->pluck('account_id')->all();
        $lockedAccounts = $this->lockAccountsInOrder($transaction->user_id, $accountIds);

        $reversals = new Collection();
        $now = now()->utc();

        foreach ($activeMovements as $movement) {
            $reversal = AccountMovement::query()->create([
                'id' => (string) Str::uuid(),
                'user_id' => $transaction->user_id,
                'account_id' => $movement->account_id,
                'transaction_id' => $transaction->id,
                'adjustment_id' => null,
                'posting_group_id' => $postingGroupId,
                'movement_type' => 'reversal',
                'amount_signed' => -$movement->amount_signed,
                'reversal_of_id' => $movement->id,
                'created_at' => $now,
            ]);

            $reversals->push($reversal);
        }

        foreach ($lockedAccounts as $account) {
            $this->reconcileAccountBalance($account);
        }

        return $reversals;
    }

    /**
     * Computes the authoritative balance of an account directly from the ledger.
     */
    public function calculateLedgerBalance(string $accountId): int
    {
        return (int) AccountMovement::query()
            ->where('account_id', $accountId)
            ->sum('amount_signed');
    }

    /**
     * Reconciles account.balance_cache with SUM(account_movements.amount_signed).
     */
    public function reconcileAccountBalance(Account $account): int
    {
        $balance = $this->calculateLedgerBalance($account->id);
        $account->balance_cache = $balance;
        $account->save();

        return $balance;
    }
}

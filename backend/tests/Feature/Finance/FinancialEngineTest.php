<?php

namespace Tests\Feature\Finance;

use App\Exceptions\EntityConflictException;
use App\Exceptions\FinancialValidationException;
use App\Exceptions\OwnershipViolationException;
use App\Models\Account;
use App\Models\AccountMovement;
use App\Models\Category;
use App\Models\Transaction;
use App\Models\User;
use App\Services\AccountService;
use App\Services\CategoryService;
use App\Services\LedgerService;
use App\Services\TransactionService;
use App\Services\TransferService;
use App\Services\UserBootstrapService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FinancialEngineTest extends TestCase
{
    use RefreshDatabase;

    private AccountService $accountService;

    private CategoryService $categoryService;

    private TransactionService $transactionService;

    private TransferService $transferService;

    private LedgerService $ledgerService;

    protected function setUp(): void
    {
        parent::setUp();

        $this->accountService = app(AccountService::class);
        $this->categoryService = app(CategoryService::class);
        $this->transactionService = app(TransactionService::class);
        $this->transferService = app(TransferService::class);
        $this->ledgerService = app(LedgerService::class);
    }

    public function test_opening_balance_is_recorded_once_and_cannot_be_modified_directly(): void
    {
        $user = $this->createBootstrappedUser();

        $bca = $this->accountService->createAccount($user, [
            'name' => 'BCA',
            'account_type' => 'bank',
            'institution_name' => 'Bank Central Asia',
            'opening_balance' => 5000000,
            'opening_balance_date' => '2026-11-21',
        ]);

        // Opening balance is recorded once, not double-counted
        $this->assertSame(5000000, $bca->opening_balance);
        $this->assertSame(5000000, $bca->balance_cache);
        $this->assertSame(5000000, $this->ledgerService->calculateLedgerBalance($bca->id));
        $this->assertSame(1, AccountMovement::query()->where('account_id', $bca->id)->where('movement_type', 'opening')->count());

        // Attempting to add a second opening movement throws EntityConflictException
        try {
            $this->ledgerService->postOpeningMovement($bca, 1000000);
            $this->fail('Expected EntityConflictException for duplicate opening movement.');
        } catch (EntityConflictException $e) {
            $this->assertStringContainsString('already exists', $e->getMessage());
        }

        // Direct opening_balance edit via updateAccount is prohibited
        try {
            $this->accountService->updateAccount($user, $bca->id, [
                'name' => 'BCA Utama',
                'opening_balance' => 9999999,
            ]);
            $this->fail('Expected FinancialValidationException for direct opening_balance edit.');
        } catch (FinancialValidationException $e) {
            $this->assertArrayHasKey('opening_balance', $e->errors);
        }

        // Metadata update without changing opening_balance succeeds and bumps version
        $updated = $this->accountService->updateAccount($user, $bca->id, [
            'name' => 'BCA Utama',
            'opening_balance' => 5000000,
        ], baseVersion: 1);
        $this->assertSame('BCA Utama', $updated->name);
        $this->assertSame(2, $updated->version);
    }

    public function test_income_expense_negative_balance_and_category_type_validation(): void
    {
        $user = $this->createBootstrappedUser();
        $cash = $user->accounts()->where('account_type', 'cash')->firstOrFail();
        $salaryCat = $user->categories()->where('type', 'income')->where('name', 'Gaji')->firstOrFail();
        $foodCat = $user->categories()->where('type', 'expense')->where('name', 'Makanan')->firstOrFail();

        // Income +500.000
        $incomeTx = $this->transactionService->createTransaction($user, [
            'type' => 'income',
            'account_id' => $cash->id,
            'category_id' => $salaryCat->id,
            'amount' => 500000,
            'description' => 'Gaji November',
        ]);
        $this->assertSame('posted', $incomeTx->status);
        $this->assertSame(500000, $cash->fresh()->balance_cache);

        // Expense -700.000 -> negative balance (-200.000) is explicitly allowed per PRD 5.2
        $expenseTx = $this->transactionService->createTransaction($user, [
            'type' => 'expense',
            'account_id' => $cash->id,
            'category_id' => $foodCat->id,
            'amount' => 700000,
            'description' => 'Belanja bulanan',
        ]);
        $this->assertSame('posted', $expenseTx->status);
        $this->assertSame(-200000, $cash->fresh()->balance_cache);

        // Category type mismatch is rejected
        $this->expectException(FinancialValidationException::class);
        $this->transactionService->createTransaction($user, [
            'type' => 'expense',
            'account_id' => $cash->id,
            'category_id' => $salaryCat->id,
            'amount' => 50000,
        ]);
    }

    public function test_transfer_creates_two_balanced_movements_and_rejects_same_account(): void
    {
        $user = $this->createBootstrappedUser();
        $cash = $user->accounts()->where('account_type', 'cash')->firstOrFail();
        $bca = $this->accountService->createAccount($user, [
            'name' => 'BCA',
            'account_type' => 'bank',
            'opening_balance' => 3000000,
            'opening_balance_date' => '2026-11-21',
        ]);

        // Transfer 1.000.000 from BCA to Cash
        $transfer = $this->transferService->createTransfer($user, [
            'source_account_id' => $bca->id,
            'destination_account_id' => $cash->id,
            'amount' => 1000000,
            'description' => 'Tarik tunai',
        ]);

        $this->assertSame('transfer', $transfer->type);
        $this->assertNull($transfer->category_id);
        $this->assertNull($transfer->category_type);
        $this->assertSame(2, $transfer->movements->count());
        $this->assertSame(0, (int) $transfer->movements->sum('amount_signed'));
        $this->assertSame(1, $transfer->movements->pluck('posting_group_id')->unique()->count());

        $this->assertSame(2000000, $bca->fresh()->balance_cache);
        $this->assertSame(1000000, $cash->fresh()->balance_cache);

        // Rejects same source and destination account
        $this->expectException(FinancialValidationException::class);
        $this->transferService->createTransfer($user, [
            'source_account_id' => $bca->id,
            'destination_account_id' => $bca->id,
            'amount' => 100000,
        ]);
    }

    public function test_editing_transaction_uses_reversal_and_replacement_across_accounts(): void
    {
        $user = $this->createBootstrappedUser();
        $cash = $user->accounts()->where('account_type', 'cash')->firstOrFail();
        $bca = $this->accountService->createAccount($user, [
            'name' => 'BCA',
            'account_type' => 'bank',
            'opening_balance' => 1000000,
            'opening_balance_date' => '2026-11-21',
        ]);
        $foodCat = $user->categories()->where('type', 'expense')->where('name', 'Makanan')->firstOrFail();
        $transportCat = $user->categories()->where('type', 'expense')->where('name', 'Transportasi')->firstOrFail();

        // Initial expense: 100.000 from Cash
        $tx = $this->transactionService->createTransaction($user, [
            'type' => 'expense',
            'account_id' => $cash->id,
            'category_id' => $foodCat->id,
            'amount' => 100000,
            'description' => 'Makan siang',
        ]);
        $this->assertSame(-100000, $cash->fresh()->balance_cache);

        // Edit: change amount to 250.000, category to Transportasi, and move to BCA
        $edited = $this->transactionService->updateTransaction($user, $tx->id, [
            'account_id' => $bca->id,
            'category_id' => $transportCat->id,
            'amount' => 250000,
            'description' => 'Bensin',
            'reason' => 'Salah pilih rekening',
        ], baseVersion: 1);

        $this->assertSame(2, $edited->version);
        $this->assertSame(250000, $edited->amount);
        $this->assertSame($transportCat->id, $edited->category_id);

        // 3 movements total on transaction: original (-100k), reversal (+100k), replacement (-250k)
        $this->assertSame(3, $edited->movements->count());
        $this->assertSame(1, $edited->movements->where('movement_type', 'reversal')->count());

        // Revisions: rev 1 (create), rev 2 (edit) with before_data and after_data
        $this->assertSame(2, $edited->revisions->count());
        $editRevision = $edited->revisions->firstWhere('revision_number', 2);
        $this->assertSame('edit', $editRevision->action);
        $this->assertSame(100000, $editRevision->before_data['amount']);
        $this->assertSame(250000, $editRevision->after_data['amount']);

        // Balances reconciled on both Cash (back to 0) and BCA (1.000.000 - 250.000 = 750.000)
        $this->assertSame(0, $cash->fresh()->balance_cache);
        $this->assertSame(750000, $bca->fresh()->balance_cache);
        $this->assertAllUserAccountBalancesReconciled($user);
    }

    public function test_editing_and_voiding_transfer_and_preventing_double_void(): void
    {
        $user = $this->createBootstrappedUser();
        $cash = $user->accounts()->where('account_type', 'cash')->firstOrFail();
        $bca = $this->accountService->createAccount($user, [
            'name' => 'BCA',
            'account_type' => 'bank',
            'opening_balance' => 2000000,
            'opening_balance_date' => '2026-11-21',
        ]);
        $gopay = $this->accountService->createAccount($user, [
            'name' => 'GoPay',
            'account_type' => 'e_wallet',
            'opening_balance' => 100000,
            'opening_balance_date' => '2026-11-21',
        ]);

        // Transfer 500.000 BCA -> Cash
        $transfer = $this->transferService->createTransfer($user, [
            'source_account_id' => $bca->id,
            'destination_account_id' => $cash->id,
            'amount' => 500000,
        ]);

        // Edit transfer: 300.000 BCA -> GoPay
        $edited = $this->transferService->updateTransfer($user, $transfer->id, [
            'source_account_id' => $bca->id,
            'destination_account_id' => $gopay->id,
            'amount' => 300000,
        ], baseVersion: 1);

        $this->assertSame(2, $edited->version);
        $this->assertSame(1700000, $bca->fresh()->balance_cache);
        $this->assertSame(0, $cash->fresh()->balance_cache);
        $this->assertSame(400000, $gopay->fresh()->balance_cache);

        // Void transfer
        $voided = $this->transferService->voidTransfer($user, $transfer->id, reason: 'Batal topup', baseVersion: 2);
        $this->assertSame('voided', $voided->status);
        $this->assertSame(3, $voided->version);
        $this->assertSame(2000000, $bca->fresh()->balance_cache);
        $this->assertSame(0, $cash->fresh()->balance_cache);
        $this->assertSame(100000, $gopay->fresh()->balance_cache);
        $this->assertAllUserAccountBalancesReconciled($user);

        // Double void throws EntityConflictException
        $this->expectException(EntityConflictException::class);
        $this->transferService->voidTransfer($user, $transfer->id);
    }

    public function test_account_adjustments_update_balance_correctly(): void
    {
        $user = $this->createBootstrappedUser();
        $cash = $user->accounts()->where('account_type', 'cash')->firstOrFail();

        $this->accountService->createAdjustment($user, $cash->id, [
            'amount_signed' => 1000000,
            'reason' => 'Stok kas fisik awal',
        ]);
        $this->assertSame(1000000, $cash->fresh()->balance_cache);

        $this->accountService->createAdjustment($user, $cash->id, [
            'amount_signed' => -50000,
            'reason' => 'Selisih hitung uang tunai',
        ]);
        $this->assertSame(950000, $cash->fresh()->balance_cache);
        $this->assertAllUserAccountBalancesReconciled($user);
    }

    public function test_archived_entities_cross_user_access_and_version_conflicts_are_blocked(): void
    {
        $userA = $this->createBootstrappedUser('a@example.com');
        $userB = $this->createBootstrappedUser('b@example.com');

        $cashA = $userA->accounts()->where('account_type', 'cash')->firstOrFail();
        $foodCatA = $userA->categories()->where('type', 'expense')->where('name', 'Makanan')->firstOrFail();
        $cashB = $userB->accounts()->where('account_type', 'cash')->firstOrFail();

        // Cross-user transaction attempt throws OwnershipViolationException
        try {
            $this->transactionService->createTransaction($userA, [
                'type' => 'expense',
                'account_id' => $cashB->id,
                'category_id' => $foodCatA->id,
                'amount' => 10000,
            ]);
            $this->fail('Expected OwnershipViolationException for cross-user account.');
        } catch (OwnershipViolationException $e) {
            $this->assertNotEmpty($e->getMessage());
        }

        // Archived category cannot be used for new transactions
        $customCat = $this->categoryService->createCategory($userA, [
            'name' => 'Hobi',
            'type' => 'expense',
        ]);
        $this->categoryService->archiveCategory($userA, $customCat->id);

        try {
            $this->transactionService->createTransaction($userA, [
                'type' => 'expense',
                'account_id' => $cashA->id,
                'category_id' => $customCat->id,
                'amount' => 25000,
            ]);
            $this->fail('Expected FinancialValidationException for inactive category.');
        } catch (FinancialValidationException $e) {
            $this->assertArrayHasKey('category_id', $e->errors);
        }

        // Optimistic concurrency conflict check on Transaction update
        $tx = $this->transactionService->createTransaction($userA, [
            'type' => 'expense',
            'account_id' => $cashA->id,
            'category_id' => $foodCatA->id,
            'amount' => 30000,
        ]);

        // Archived account cannot be used for new transactions
        $this->accountService->archiveAccount($userA, $cashA->id);
        try {
            $this->transactionService->createTransaction($userA, [
                'type' => 'expense',
                'account_id' => $cashA->id,
                'category_id' => $foodCatA->id,
                'amount' => 15000,
            ]);
            $this->fail('Expected FinancialValidationException for archived account.');
        } catch (FinancialValidationException $e) {
            $this->assertArrayHasKey('account_id', $e->errors);
        }

        // Version mismatch (sending stale baseVersion 99) throws EntityConflictException
        $this->accountService->restoreAccount($userA, $cashA->id);
        $this->expectException(EntityConflictException::class);
        $this->transactionService->updateTransaction($userA, $tx->id, [
            'amount' => 35000,
        ], baseVersion: 99);
    }

    private function createBootstrappedUser(?string $email = null): User
    {
        $user = User::factory()->create(array_filter([
            'email' => $email,
        ]));
        app(UserBootstrapService::class)->bootstrapNewUser($user);

        return $user->fresh();
    }

    private function assertAllUserAccountBalancesReconciled(User $user): void
    {
        $accounts = Account::query()->where('user_id', $user->id)->get();
        foreach ($accounts as $account) {
            $ledgerSum = $this->ledgerService->calculateLedgerBalance($account->id);
            $this->assertSame(
                $ledgerSum,
                $account->balance_cache,
                "Account [{$account->name}] balance_cache ({$account->balance_cache}) does not match ledger sum ({$ledgerSum})."
            );
        }
    }
}


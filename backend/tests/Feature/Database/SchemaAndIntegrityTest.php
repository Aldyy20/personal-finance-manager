<?php

namespace Tests\Feature\Database;

use App\Models\Account;
use App\Models\AccountMovement;
use App\Models\Category;
use App\Models\Transaction;
use App\Models\TransactionRevision;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use LogicException;
use Tests\TestCase;

class SchemaAndIntegrityTest extends TestCase
{
    use RefreshDatabase;

    public function test_all_16_domain_tables_exist(): void
    {
        $expectedTables = [
            'users',
            'devices',
            'user_settings',
            'accounts',
            'categories',
            'transactions',
            'account_movements',
            'account_adjustments',
            'transaction_revisions',
            'receipts',
            'budgets',
            'budget_categories',
            'sync_operations',
            'sync_cursors',
            'sync_sequences',
            'sync_changes',
        ];

        foreach ($expectedTables as $table) {
            $this->assertTrue(Schema::hasTable($table), "Expected table [{$table}] to exist.");
        }
    }

    public function test_database_seeder_bootstraps_default_user_data_atomically(): void
    {
        $this->seed(DatabaseSeeder::class);

        $user = User::query()->where('email', 'demo@personalfinance.test')->firstOrFail();

        $this->assertNotNull($user->settings);
        $this->assertSame('IDR', $user->settings->currency);
        $this->assertSame(17, $user->categories()->count());
        $this->assertSame(7, $user->categories()->where('type', 'income')->count());
        $this->assertSame(10, $user->categories()->where('type', 'expense')->count());

        $cash = $user->accounts()->where('account_type', 'cash')->firstOrFail();
        $this->assertSame('Cash', $cash->name);
        $this->assertSame(0, $cash->opening_balance);
        $this->assertSame(0, $cash->balance_cache);
        $this->assertSame(1, $cash->movements()->where('movement_type', 'opening')->count());
    }

    public function test_composite_foreign_keys_prevent_cross_user_references(): void
    {
        $userA = User::factory()->create();
        $userB = User::factory()->create();

        $categoryUserB = Category::query()->create([
            'id' => (string) Str::uuid(),
            'user_id' => $userB->id,
            'name' => 'Gaji User B',
            'type' => 'income',
        ]);

        $this->expectException(QueryException::class);

        Transaction::query()->create([
            'id' => (string) Str::uuid(),
            'user_id' => $userA->id,
            'type' => 'income',
            'category_id' => $categoryUserB->id,
            'category_type' => 'income',
            'amount' => 100000,
            'transaction_date' => now()->utc(),
            'status' => 'posted',
        ]);
    }

    public function test_account_movements_and_revisions_are_immutable_and_single_reversal(): void
    {
        $user = User::factory()->create();
        $account = Account::query()->create([
            'id' => (string) Str::uuid(),
            'user_id' => $user->id,
            'name' => 'BCA',
            'account_type' => 'bank',
            'opening_balance' => 500000,
            'opening_balance_date' => '2026-11-21',
            'balance_cache' => 500000,
        ]);

        $movement = AccountMovement::query()->create([
            'id' => (string) Str::uuid(),
            'user_id' => $user->id,
            'account_id' => $account->id,
            'posting_group_id' => (string) Str::uuid(),
            'movement_type' => 'opening',
            'amount_signed' => 500000,
            'created_at' => now()->utc(),
        ]);

        try {
            $movement->update(['amount_signed' => 999999]);
            $this->fail('Expected LogicException when updating AccountMovement.');
        } catch (LogicException $e) {
            $this->assertStringContainsString('immutable', $e->getMessage());
        }

        try {
            $movement->delete();
            $this->fail('Expected LogicException when deleting AccountMovement.');
        } catch (LogicException $e) {
            $this->assertStringContainsString('immutable', $e->getMessage());
        }

        // First reversal succeeds
        AccountMovement::query()->create([
            'id' => (string) Str::uuid(),
            'user_id' => $user->id,
            'account_id' => $account->id,
            'posting_group_id' => (string) Str::uuid(),
            'movement_type' => 'reversal',
            'amount_signed' => -500000,
            'reversal_of_id' => $movement->id,
            'created_at' => now()->utc(),
        ]);

        // Duplicate reversal on the same movement violates unique reversal_of_id constraint
        $this->expectException(QueryException::class);
        AccountMovement::query()->create([
            'id' => (string) Str::uuid(),
            'user_id' => $user->id,
            'account_id' => $account->id,
            'posting_group_id' => (string) Str::uuid(),
            'movement_type' => 'reversal',
            'amount_signed' => -500000,
            'reversal_of_id' => $movement->id,
            'created_at' => now()->utc(),
        ]);
    }

    public function test_transaction_revisions_cannot_be_updated_or_deleted(): void
    {
        $user = User::factory()->create();
        $category = Category::query()->create([
            'id' => (string) Str::uuid(),
            'user_id' => $user->id,
            'name' => 'Gaji',
            'type' => 'income',
        ]);

        $tx = Transaction::query()->create([
            'id' => (string) Str::uuid(),
            'user_id' => $user->id,
            'type' => 'income',
            'category_id' => $category->id,
            'category_type' => 'income',
            'amount' => 100000,
            'transaction_date' => now()->utc(),
            'status' => 'posted',
        ]);

        $revision = TransactionRevision::query()->create([
            'id' => (string) Str::uuid(),
            'transaction_id' => $tx->id,
            'user_id' => $user->id,
            'revision_number' => 1,
            'action' => 'create',
            'after_data' => ['amount' => 100000],
            'created_at' => now()->utc(),
        ]);

        $this->expectException(LogicException::class);
        $revision->update(['action' => 'edit']);
    }
}


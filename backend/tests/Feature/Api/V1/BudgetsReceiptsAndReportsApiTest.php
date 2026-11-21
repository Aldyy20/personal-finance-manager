<?php

namespace Tests\Feature\Api\V1;

use App\Models\User;
use App\Services\UserBootstrapService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class BudgetsReceiptsAndReportsApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_budgets_enforce_expense_categories_and_calculate_utilization_accurately(): void
    {
        [$user, $token] = $this->createUserWithToken('budget@example.com');
        $cash = $user->accounts()->where('account_type', 'cash')->firstOrFail();
        $salaryCat = $user->categories()->where('type', 'income')->where('name', 'Gaji')->firstOrFail();
        $foodCat = $user->categories()->where('type', 'expense')->where('name', 'Makanan')->firstOrFail();

        $monthStart = now()->utc()->startOfMonth()->format('Y-m-d');
        $monthEnd = now()->utc()->endOfMonth()->format('Y-m-d');

        // Reject income category in budget
        $this->withToken($token)->postJson('/api/v1/budgets', [
            'name' => 'Budget Invalid',
            'start_date' => $monthStart,
            'end_date' => $monthEnd,
            'categories' => [
                ['category_id' => $salaryCat->id, 'amount_limit' => 500000],
            ],
        ])->assertStatus(422)->assertJson(['code' => 'VALIDATION_ERROR']);

        // Create monthly budget for Makanan = 1.000.000, warning at 80%
        $budgetRes = $this->withToken($token)->postJson('/api/v1/budgets', [
            'name' => 'Anggaran Bulan Ini',
            'start_date' => $monthStart,
            'end_date' => $monthEnd,
            'total_limit' => 1500000,
            'warning_percent' => 80,
            'categories' => [
                ['category_id' => $foodCat->id, 'amount_limit' => 1000000],
            ],
        ])->assertStatus(201);
        $budgetId = $budgetRes->json('data.id');

        // Spend 850.000 on Makanan (85% -> warning)
        $txId = $this->withToken($token)->postJson('/api/v1/transactions', [
            'type' => 'expense',
            'account_id' => $cash->id,
            'category_id' => $foodCat->id,
            'amount' => 850000,
            'transaction_date' => now()->utc()->toIso8601ZuluString('millisecond'),
        ])->assertStatus(201)->json('data.id');

        $this->withToken($token)->getJson("/api/v1/budgets/{$budgetId}/summary")
            ->assertStatus(200)
            ->assertJsonPath('data.summary.total_used', 850000)
            ->assertJsonPath('data.categories.0.used', 850000)
            ->assertJsonPath('data.categories.0.remaining', 150000)
            ->assertJsonPath('data.categories.0.status', 'warning');

        // Voiding the expense restores budget usage to 0
        $this->withToken($token)->postJson("/api/v1/transactions/{$txId}/void")->assertStatus(200);

        $this->withToken($token)->getJson("/api/v1/budgets/{$budgetId}/summary")
            ->assertStatus(200)
            ->assertJsonPath('data.summary.total_used', 0)
            ->assertJsonPath('data.categories.0.status', 'normal');
    }

    public function test_receipt_upload_validation_private_download_ownership_and_delete(): void
    {
        Storage::fake('local');

        [$userA, $tokenA] = $this->createUserWithToken('rcpt_a@example.com');
        [, $tokenB] = $this->createUserWithToken('rcpt_b@example.com');

        $cash = $userA->accounts()->where('account_type', 'cash')->firstOrFail();
        $foodCat = $userA->categories()->where('type', 'expense')->where('name', 'Makanan')->firstOrFail();

        $txId = $this->withToken($tokenA)->postJson('/api/v1/transactions', [
            'type' => 'expense',
            'account_id' => $cash->id,
            'category_id' => $foodCat->id,
            'amount' => 45000,
            'transaction_date' => now()->utc()->toIso8601ZuluString('millisecond'),
        ])->assertStatus(201)->json('data.id');

        // Reject invalid MIME type (text file)
        $badFile = UploadedFile::fake()->create('note.txt', 10, 'text/plain');
        $this->withToken($tokenA)->postJson('/api/v1/receipts', [
            'transaction_id' => $txId,
            'file' => $badFile,
        ])->assertStatus(422);

        // Valid JPEG image with matching SHA-256 checksum
        $image = UploadedFile::fake()->image('nota.jpg', 600, 800);
        $checksum = hash_file('sha256', $image->getRealPath());

        $uploadRes = $this->withToken($tokenA)->postJson('/api/v1/receipts', [
            'transaction_id' => $txId,
            'file' => $image,
            'checksum' => $checksum,
            'ocr_text' => "TOKO MAJU\nTOTAL 45.000",
        ])->assertStatus(201)
            ->assertJsonPath('data.mime_type', 'image/jpeg')
            ->assertJsonPath('data.checksum', $checksum);

        $receiptId = $uploadRes->json('data.id');

        // Authorized download succeeds
        $this->withToken($tokenA)->get("/api/v1/receipts/{$receiptId}/download")
            ->assertStatus(200);

        // User B cannot download User A's receipt
        $this->app['auth']->forgetGuards();
        $this->withToken($tokenB)->getJson("/api/v1/receipts/{$receiptId}/download")
            ->assertStatus(403)
            ->assertJson(['code' => 'FORBIDDEN']);

        // User A deletes receipt
        $this->app['auth']->forgetGuards();
        $this->withToken($tokenA)->deleteJson("/api/v1/receipts/{$receiptId}")
            ->assertStatus(200);
        $this->withToken($tokenA)->getJson("/api/v1/receipts/{$receiptId}")
            ->assertStatus(404);
    }

    public function test_reports_exclude_transfers_adjustments_and_voided_transactions(): void
    {
        [$user, $token] = $this->createUserWithToken('reports@example.com');
        $cash = $user->accounts()->where('account_type', 'cash')->firstOrFail();
        $salaryCat = $user->categories()->where('type', 'income')->where('name', 'Gaji')->firstOrFail();
        $foodCat = $user->categories()->where('type', 'expense')->where('name', 'Makanan')->firstOrFail();

        $bcaId = $this->withToken($token)->postJson('/api/v1/accounts', [
            'name' => 'BCA',
            'account_type' => 'bank',
            'opening_balance' => 3000000,
            'opening_balance_date' => now()->utc()->format('Y-m-d'),
        ])->assertStatus(201)->json('data.id');

        // Income 2.000.000
        $this->withToken($token)->postJson('/api/v1/transactions', [
            'type' => 'income',
            'account_id' => $bcaId,
            'category_id' => $salaryCat->id,
            'amount' => 2000000,
            'transaction_date' => now()->utc()->toIso8601ZuluString('millisecond'),
        ])->assertStatus(201);

        // Expense 400.000
        $this->withToken($token)->postJson('/api/v1/transactions', [
            'type' => 'expense',
            'account_id' => $cash->id,
            'category_id' => $foodCat->id,
            'amount' => 400000,
            'transaction_date' => now()->utc()->toIso8601ZuluString('millisecond'),
        ])->assertStatus(201);

        // Voided expense 999.000 (excluded)
        $voidTxId = $this->withToken($token)->postJson('/api/v1/transactions', [
            'type' => 'expense',
            'account_id' => $cash->id,
            'category_id' => $foodCat->id,
            'amount' => 999000,
            'transaction_date' => now()->utc()->toIso8601ZuluString('millisecond'),
        ])->assertStatus(201)->json('data.id');
        $this->withToken($token)->postJson("/api/v1/transactions/{$voidTxId}/void")->assertStatus(200);

        // Transfer 1.500.000 (excluded from income & expense)
        $this->withToken($token)->postJson('/api/v1/transfers', [
            'source_account_id' => $bcaId,
            'destination_account_id' => $cash->id,
            'amount' => 1500000,
            'transaction_date' => now()->utc()->toIso8601ZuluString('millisecond'),
        ])->assertStatus(201);

        // Total balance: BCA (3M + 2M - 1.5M = 3.5M) + Cash (1.5M - 400k = 1.1M) = 4.600.000
        $this->withToken($token)->getJson('/api/v1/reports/overview?period=this_month')
            ->assertStatus(200)
            ->assertJsonPath('data.total_balance', 4600000)
            ->assertJsonPath('data.total_income', 2000000)
            ->assertJsonPath('data.total_expense', 400000)
            ->assertJsonPath('data.net_cash_flow', 1600000);

        $this->withToken($token)->getJson('/api/v1/reports/income')->assertStatus(200)->assertJsonPath('data.total', 2000000);
        $this->withToken($token)->getJson('/api/v1/reports/expense')->assertStatus(200)->assertJsonPath('data.total', 400000);
        $this->withToken($token)->getJson('/api/v1/reports/cash-flow')->assertStatus(200)->assertJsonPath('data.net_cash_flow', 1600000);
        $this->withToken($token)->getJson('/api/v1/reports/categories')->assertStatus(200);
        $this->withToken($token)->getJson('/api/v1/reports/accounts')->assertStatus(200)->assertJsonPath('data.total_active_balance', 4600000);
        $this->withToken($token)->getJson('/api/v1/reports/budgets')->assertStatus(200);
        $this->withToken($token)->getJson('/api/v1/reports/monthly-comparison?months=3')->assertStatus(200)->assertJsonCount(3, 'data.series');
    }

    /**
     * @return array{0: User, 1: string}
     */
    private function createUserWithToken(string $email): array
    {
        $user = User::factory()->create(['email' => $email]);
        app(UserBootstrapService::class)->bootstrapNewUser($user);
        $token = $user->createToken('test-device')->plainTextToken;

        return [$user->fresh(), $token];
    }
}


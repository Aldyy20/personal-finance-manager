<?php

namespace Tests\Feature\Api\V1;

use App\Models\User;
use App\Services\UserBootstrapService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TransactionsAndTransfersApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_income_expense_edit_void_revisions_and_transfer_endpoints(): void
    {
        [$user, $token] = $this->createUserWithToken('tx@example.com');
        $cash = $user->accounts()->where('account_type', 'cash')->firstOrFail();
        $salaryCat = $user->categories()->where('type', 'income')->where('name', 'Gaji')->firstOrFail();
        $foodCat = $user->categories()->where('type', 'expense')->where('name', 'Makanan')->firstOrFail();

        $bcaId = $this->withToken($token)->postJson('/api/v1/accounts', [
            'name' => 'BCA',
            'account_type' => 'bank',
            'opening_balance' => 2000000,
            'opening_balance_date' => '2026-11-21',
        ])->assertStatus(201)->json('data.id');

        // Create income 500.000 into Cash
        $incomeRes = $this->withToken($token)->postJson('/api/v1/transactions', [
            'type' => 'income',
            'account_id' => $cash->id,
            'category_id' => $salaryCat->id,
            'amount' => 500000,
            'transaction_date' => '2026-11-21T10:00:00Z',
            'description' => 'Bonus Proyek',
        ])->assertStatus(201);
        $incomeId = $incomeRes->json('data.id');
        $this->assertSame($cash->id, $incomeRes->json('data.account_id'));

        // Create expense 100.000 from Cash
        $expenseRes = $this->withToken($token)->postJson('/api/v1/transactions', [
            'type' => 'expense',
            'account_id' => $cash->id,
            'category_id' => $foodCat->id,
            'amount' => 100000,
            'transaction_date' => '2026-11-21T11:00:00Z',
            'description' => 'Makan siang',
        ])->assertStatus(201);
        $expenseId = $expenseRes->json('data.id');

        // Edit expense from 100.000 to 150.000
        $this->withToken($token)->putJson("/api/v1/transactions/{$expenseId}", [
            'amount' => 150000,
            'base_version' => 1,
            'reason' => 'Tambahan minuman',
        ])->assertStatus(200)
            ->assertJsonPath('data.amount', 150000)
            ->assertJsonPath('data.version', 2);

        // Stale base_version returns 409 CONFLICT
        $this->withToken($token)->putJson("/api/v1/transactions/{$expenseId}", [
            'amount' => 200000,
            'base_version' => 1,
        ])->assertStatus(409)->assertJson(['code' => 'CONFLICT']);

        // Revisions history contains 2 revisions (create + edit)
        $this->withToken($token)->getJson("/api/v1/transactions/{$expenseId}/revisions")
            ->assertStatus(200)
            ->assertJsonCount(2, 'data');

        // Transfer 1.000.000 from BCA to Cash
        $transferRes = $this->withToken($token)->postJson('/api/v1/transfers', [
            'source_account_id' => $bcaId,
            'destination_account_id' => $cash->id,
            'amount' => 1000000,
            'transaction_date' => '2026-11-21T12:00:00Z',
            'description' => 'Tarik tunai ATM',
        ])->assertStatus(201);
        $transferId = $transferRes->json('data.id');
        $this->assertSame($bcaId, $transferRes->json('data.source_account_id'));
        $this->assertSame($cash->id, $transferRes->json('data.destination_account_id'));

        // Cash balance: +500.000 - 150.000 + 1.000.000 = 1.350.000
        // BCA balance: 2.000.000 - 1.000.000 = 1.000.000
        $this->withToken($token)->getJson("/api/v1/accounts/{$cash->id}/balance")
            ->assertJsonPath('data.balance', 1350000);
        $this->withToken($token)->getJson("/api/v1/accounts/{$bcaId}/balance")
            ->assertJsonPath('data.balance', 1000000);

        // Edit transfer to 800.000
        $this->withToken($token)->putJson("/api/v1/transfers/{$transferId}", [
            'amount' => 800000,
            'base_version' => 1,
        ])->assertStatus(200)->assertJsonPath('data.amount', 800000);

        $this->withToken($token)->getJson("/api/v1/accounts/{$cash->id}/balance")
            ->assertJsonPath('data.balance', 1150000);

        // Void transfer & void income
        $this->withToken($token)->postJson("/api/v1/transfers/{$transferId}/void", ['base_version' => 2])
            ->assertStatus(200)->assertJsonPath('data.status', 'voided');

        $this->withToken($token)->postJson("/api/v1/transactions/{$incomeId}/void")
            ->assertStatus(200)->assertJsonPath('data.status', 'voided');

        // Cash balance: only -150.000 expense remains
        $this->withToken($token)->getJson("/api/v1/accounts/{$cash->id}/balance")
            ->assertJsonPath('data.balance', -150000);

        // Paginated transactions filter
        $this->withToken($token)->getJson('/api/v1/transactions?type=expense&status=posted')
            ->assertStatus(200)
            ->assertJsonCount(1, 'data');

        $this->withToken($token)->getJson('/api/v1/transfers')
            ->assertStatus(200)
            ->assertJsonCount(1, 'data');
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


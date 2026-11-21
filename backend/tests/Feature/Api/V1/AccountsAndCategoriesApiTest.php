<?php

namespace Tests\Feature\Api\V1;

use App\Models\User;
use App\Services\UserBootstrapService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AccountsAndCategoriesApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_account_crud_movements_balance_adjustment_and_ownership_isolation(): void
    {
        [$userA, $tokenA] = $this->createUserWithToken('acc_a@example.com');
        [, $tokenB] = $this->createUserWithToken('acc_b@example.com');

        // List initial Cash account
        $this->withToken($tokenA)->getJson('/api/v1/accounts')
            ->assertStatus(200)
            ->assertJsonCount(1, 'data');

        // Create BCA bank account with opening balance 5.000.000
        $createRes = $this->withToken($tokenA)->postJson('/api/v1/accounts', [
            'name' => 'BCA',
            'account_type' => 'bank',
            'institution_name' => 'Bank Central Asia',
            'opening_balance' => 5000000,
            'opening_balance_date' => '2026-11-21',
        ]);
        $createRes->assertStatus(201)
            ->assertJsonPath('data.balance_cache', 5000000)
            ->assertJsonPath('data.version', 1);

        $bcaId = $createRes->json('data.id');

        // Direct edit of opening_balance returns 422
        $this->withToken($tokenA)->putJson("/api/v1/accounts/{$bcaId}", [
            'name' => 'BCA Tabungan',
            'opening_balance' => 9000000,
        ])->assertStatus(422)->assertJson(['code' => 'VALIDATION_ERROR']);

        // Valid update bumps version
        $this->withToken($tokenA)->putJson("/api/v1/accounts/{$bcaId}", [
            'name' => 'BCA Tabungan',
            'base_version' => 1,
        ])->assertStatus(200)->assertJsonPath('data.version', 2);

        // Create manual adjustment -250.000
        $this->withToken($tokenA)->postJson("/api/v1/accounts/{$bcaId}/adjustments", [
            'amount_signed' => -250000,
            'reason' => 'Biaya admin historis',
        ])->assertStatus(201)->assertJsonPath('data.amount_signed', -250000);

        // Balance endpoint matches ledger sum (4.750.000)
        $this->withToken($tokenA)->getJson("/api/v1/accounts/{$bcaId}/balance")
            ->assertStatus(200)
            ->assertJson([
                'data' => [
                    'balance' => 4750000,
                    'balance_cache' => 4750000,
                    'is_reconciled' => true,
                ],
            ]);

        // Movements history shows 2 movements (opening + adjustment)
        $this->withToken($tokenA)->getJson("/api/v1/accounts/{$bcaId}/movements")
            ->assertStatus(200)
            ->assertJsonCount(2, 'data');

        // Archive and restore
        $this->withToken($tokenA)->postJson("/api/v1/accounts/{$bcaId}/archive")
            ->assertStatus(200)
            ->assertJsonPath('data.is_active', false);

        $this->withToken($tokenA)->postJson("/api/v1/accounts/{$bcaId}/restore")
            ->assertStatus(200)
            ->assertJsonPath('data.is_active', true);

        // User B cannot access User A's account
        $this->app['auth']->forgetGuards();
        $this->withToken($tokenB)->getJson("/api/v1/accounts/{$bcaId}")
            ->assertStatus(403)
            ->assertJson(['code' => 'FORBIDDEN']);
    }

    public function test_category_crud_archive_restore_and_ownership_isolation(): void
    {
        [$userA, $tokenA] = $this->createUserWithToken('cat_a@example.com');
        [, $tokenB] = $this->createUserWithToken('cat_b@example.com');

        // 17 default categories
        $this->withToken($tokenA)->getJson('/api/v1/categories')
            ->assertStatus(200)
            ->assertJsonCount(17, 'data');

        $createRes = $this->withToken($tokenA)->postJson('/api/v1/categories', [
            'name' => 'Olahraga',
            'type' => 'expense',
            'icon' => 'fitness_center',
            'color' => '#00897B',
        ]);
        $createRes->assertStatus(201)->assertJsonPath('data.name', 'Olahraga');
        $catId = $createRes->json('data.id');

        $this->withToken($tokenA)->putJson("/api/v1/categories/{$catId}", [
            'name' => 'Gym & Olahraga',
            'base_version' => 1,
        ])->assertStatus(200)->assertJsonPath('data.version', 2);

        $this->withToken($tokenA)->postJson("/api/v1/categories/{$catId}/archive")
            ->assertStatus(200)->assertJsonPath('data.is_active', false);

        $this->withToken($tokenA)->postJson("/api/v1/categories/{$catId}/restore")
            ->assertStatus(200)->assertJsonPath('data.is_active', true);

        $this->app['auth']->forgetGuards();
        $this->withToken($tokenB)->getJson("/api/v1/categories/{$catId}")
            ->assertStatus(403);
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


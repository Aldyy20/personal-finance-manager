<?php

namespace Tests\Feature\Api\V1;

use App\Models\Account;
use App\Models\Category;
use App\Models\Device;
use App\Models\SyncSequence;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class AuthenticationAndDeviceTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_bootstraps_user_settings_categories_cash_account_and_device(): void
    {
        $deviceId = (string) Str::uuid();

        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Aldi User',
            'email' => 'Aldi@Example.com',
            'password' => 'SecurePass123!',
            'password_confirmation' => 'SecurePass123!',
            'device' => [
                'id' => $deviceId,
                'name' => 'Pixel Physical Phone',
                'platform' => 'android',
                'app_version' => '1.0.0',
            ],
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'user' => ['id', 'name', 'email'],
                    'settings' => ['id', 'theme_mode', 'currency', 'timezone', 'budget_warning_percent'],
                    'device' => ['id', 'device_name', 'platform', 'is_active'],
                    'access_token',
                    'token_type',
                    'sync_meta' => ['last_sequence', 'device_cursor', 'server_time'],
                ],
                'meta',
            ])
            ->assertJson([
                'success' => true,
                'data' => [
                    'user' => ['email' => 'aldi@example.com'],
                    'settings' => ['currency' => 'IDR', 'theme_mode' => 'system'],
                    'device' => ['id' => $deviceId, 'is_active' => true],
                    'token_type' => 'Bearer',
                    'sync_meta' => ['last_sequence' => 19, 'device_cursor' => 0],
                ],
            ]);

        $userId = $response->json('data.user.id');
        $this->assertSame(17, Category::query()->where('user_id', $userId)->count());
        $this->assertSame(1, Account::query()->where('user_id', $userId)->where('name', 'Cash')->count());
        $this->assertSame(19, SyncSequence::query()->where('user_id', $userId)->value('last_sequence'));
    }

    public function test_login_me_refresh_and_logout_flow(): void
    {
        $deviceId = (string) Str::uuid();
        $this->postJson('/api/v1/auth/register', [
            'name' => 'Budi',
            'email' => 'budi@example.com',
            'password' => 'SecretPass123',
            'password_confirmation' => 'SecretPass123',
        ])->assertStatus(201);

        $badLogin = $this->postJson('/api/v1/auth/login', [
            'email' => 'budi@example.com',
            'password' => 'WrongPass',
        ]);
        $badLogin->assertStatus(401)->assertJson(['success' => false, 'code' => 'UNAUTHENTICATED']);

        $login = $this->postJson('/api/v1/auth/login', [
            'email' => 'budi@example.com',
            'password' => 'SecretPass123',
            'device' => [
                'id' => $deviceId,
                'name' => 'Samsung Galaxy',
                'platform' => 'android',
            ],
        ]);
        $login->assertStatus(200);
        $token = $login->json('data.access_token');

        $this->withToken($token)->getJson('/api/v1/auth/me')
            ->assertStatus(200)
            ->assertJsonPath('data.user.email', 'budi@example.com');

        $refresh = $this->withToken($token)->postJson('/api/v1/auth/refresh');
        $refresh->assertStatus(200);
        $newToken = $refresh->json('data.access_token');
        $this->assertNotSame($token, $newToken);

        // Reset in-process Sanctum guard cache to simulate independent HTTP requests
        $this->app['auth']->forgetGuards();

        // Old token is revoked by refresh
        $this->withToken($token)->getJson('/api/v1/auth/me')->assertStatus(401);

        $this->app['auth']->forgetGuards();
        $this->withToken($newToken)->postJson('/api/v1/auth/logout')
            ->assertStatus(200)
            ->assertJson(['success' => true]);

        // Ensure revoked token no longer authenticates
        $this->app['auth']->forgetGuards();
        $this->withToken($newToken)->getJson('/api/v1/auth/me')->assertStatus(401);
    }

    public function test_profile_settings_and_cross_user_device_isolation(): void
    {
        $regA = $this->postJson('/api/v1/auth/register', [
            'name' => 'User A',
            'email' => 'usera@example.com',
            'password' => 'PasswordA123',
            'password_confirmation' => 'PasswordA123',
            'device' => [
                'id' => (string) Str::uuid(),
                'name' => 'Device A',
            ],
        ])->assertStatus(201);

        $tokenA = $regA->json('data.access_token');
        $deviceAId = $regA->json('data.device.id');

        $regB = $this->postJson('/api/v1/auth/register', [
            'name' => 'User B',
            'email' => 'userb@example.com',
            'password' => 'PasswordB123',
            'password_confirmation' => 'PasswordB123',
        ])->assertStatus(201);

        $tokenB = $regB->json('data.access_token');

        // User A updates profile & settings
        $this->withToken($tokenA)->putJson('/api/v1/profile', [
            'name' => 'User A Updated',
            'email' => 'usera@example.com',
        ])->assertStatus(200)->assertJsonPath('data.name', 'User A Updated');

        $this->withToken($tokenA)->putJson('/api/v1/settings', [
            'theme_mode' => 'dark',
            'budget_warning_percent' => 85,
            'notifications_enabled' => false,
        ])->assertStatus(200)
            ->assertJsonPath('data.theme_mode', 'dark')
            ->assertJsonPath('data.budget_warning_percent', 85)
            ->assertJsonPath('data.version', 2);

        // User A updates password
        $this->withToken($tokenA)->putJson('/api/v1/profile/password', [
            'current_password' => 'PasswordA123',
            'password' => 'NewPasswordA123',
            'password_confirmation' => 'NewPasswordA123',
        ])->assertStatus(200);

        // Switch to User B (reset in-process auth guard cache between users)
        $this->app['auth']->forgetGuards();

        // User B cannot revoke User A's device
        $this->withToken($tokenB)->postJson("/api/v1/devices/{$deviceAId}/revoke")
            ->assertStatus(403)
            ->assertJson(['success' => false, 'code' => 'FORBIDDEN']);

        // User B registers their own device and revokes it
        $deviceBReg = $this->withToken($tokenB)->postJson('/api/v1/devices/register', [
            'name' => 'Device B',
            'platform' => 'android',
            'app_version' => '1.0.1',
        ])->assertStatus(200);

        $deviceBId = $deviceBReg->json('data.id');
        $this->withToken($tokenB)->getJson('/api/v1/devices')
            ->assertStatus(200)
            ->assertJsonCount(1, 'data');

        $this->withToken($tokenB)->postJson("/api/v1/devices/{$deviceBId}/revoke")
            ->assertStatus(200)
            ->assertJsonPath('data.is_active', false);

        $this->assertFalse(Device::query()->findOrFail($deviceBId)->is_active);
    }
}

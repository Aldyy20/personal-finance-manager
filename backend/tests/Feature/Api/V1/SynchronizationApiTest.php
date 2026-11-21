<?php

namespace Tests\Feature\Api\V1;

use App\Models\Account;
use App\Models\Transaction;
use App\Models\User;
use App\Services\UserBootstrapService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class SynchronizationApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_sync_push_idempotency_conflict_detection_and_pull_hydration(): void
    {
        $device1Id = (string) Str::uuid();
        $device2Id = (string) Str::uuid();

        $reg = $this->postJson('/api/v1/auth/register', [
            'name' => 'Sync Tester',
            'email' => 'sync@example.com',
            'password' => 'SyncPass123!',
            'password_confirmation' => 'SyncPass123!',
            'device' => [
                'id' => $device1Id,
                'name' => 'Device 1',
                'platform' => 'android',
            ],
        ])->assertStatus(201);

        $token = $reg->json('data.access_token');
        $userId = $reg->json('data.user.id');
        $initialSequence = (int) $reg->json('data.sync_meta.last_sequence');
        $user = User::query()->findOrFail($userId);

        // Register a second device for multi-device pull verification
        $this->withToken($token)->postJson('/api/v1/devices/register', [
            'id' => $device2Id,
            'name' => 'Device 2',
            'platform' => 'android',
        ])->assertStatus(200);

        $cash = $user->accounts()->where('account_type', 'cash')->firstOrFail();
        $foodCat = $user->categories()->where('type', 'expense')->where('name', 'Makanan')->firstOrFail();

        $newBcaId = (string) Str::uuid();
        $expenseTxId = (string) Str::uuid();
        $opCreateBca = (string) Str::uuid();
        $opCreateTx = (string) Str::uuid();

        // Batch push from Device 1: Create BCA (opening 2.000.000) + Create Expense 250.000 on BCA
        $pushPayload = [
            'device_id' => $device1Id,
            'operations' => [
                [
                    'operation_id' => $opCreateBca,
                    'entity_type' => 'accounts',
                    'entity_id' => $newBcaId,
                    'operation_type' => 'create',
                    'base_version' => 0,
                    'payload' => [
                        'name' => 'BCA Sync',
                        'account_type' => 'bank',
                        'opening_balance' => 2000000,
                        'opening_balance_date' => '2026-11-21',
                    ],
                ],
                [
                    'operation_id' => $opCreateTx,
                    'entity_type' => 'transactions',
                    'entity_id' => $expenseTxId,
                    'operation_type' => 'create',
                    'base_version' => 0,
                    'payload' => [
                        'type' => 'expense',
                        'account_id' => $newBcaId,
                        'category_id' => $foodCat->id,
                        'amount' => 250000,
                        'transaction_date' => '2026-11-21T08:00:00Z',
                        'description' => 'Offline Dinner',
                    ],
                ],
            ],
        ];

        $pushRes = $this->withToken($token)->postJson('/api/v1/sync/push', $pushPayload)
            ->assertStatus(200)
            ->assertJsonPath('data.results.0.status', 'applied')
            ->assertJsonPath('data.results.0.idempotent_replay', false)
            ->assertJsonPath('data.results.1.status', 'applied')
            ->assertJsonPath('data.results.1.idempotent_replay', false);

        $this->assertSame(1750000, Account::query()->findOrFail($newBcaId)->balance_cache);

        // Retry exact same push batch -> Idempotency must prevent duplicate balance deduction
        $retryRes = $this->withToken($token)->postJson('/api/v1/sync/push', $pushPayload)
            ->assertStatus(200)
            ->assertJsonPath('data.results.0.status', 'applied')
            ->assertJsonPath('data.results.0.idempotent_replay', true)
            ->assertJsonPath('data.results.1.status', 'applied')
            ->assertJsonPath('data.results.1.idempotent_replay', true);

        $this->assertSame(1750000, Account::query()->findOrFail($newBcaId)->balance_cache);
        $this->assertSame(1, Transaction::query()->where('id', $expenseTxId)->count());

        // Device 2 pushes an update to expenseTxId with valid base_version = 1
        $opUpdateDevice2 = (string) Str::uuid();
        $this->withToken($token)->postJson('/api/v1/sync/push', [
            'device_id' => $device2Id,
            'operations' => [
                [
                    'operation_id' => $opUpdateDevice2,
                    'entity_type' => 'transactions',
                    'entity_id' => $expenseTxId,
                    'operation_type' => 'update',
                    'base_version' => 1,
                    'payload' => [
                        'amount' => 300000,
                        'description' => 'Updated by Device 2',
                    ],
                ],
            ],
        ])->assertStatus(200)
            ->assertJsonPath('data.results.0.status', 'applied')
            ->assertJsonPath('data.results.0.entity_version', 2);

        $this->assertSame(1700000, Account::query()->findOrFail($newBcaId)->balance_cache);

        // Device 1 tries to update with stale base_version = 1 -> Conflict detected without overwriting Device 2
        $opStaleDevice1 = (string) Str::uuid();
        $this->withToken($token)->postJson('/api/v1/sync/push', [
            'device_id' => $device1Id,
            'operations' => [
                [
                    'operation_id' => $opStaleDevice1,
                    'entity_type' => 'transactions',
                    'entity_id' => $expenseTxId,
                    'operation_type' => 'update',
                    'base_version' => 1,
                    'payload' => [
                        'amount' => 999999,
                    ],
                ],
            ],
        ])->assertStatus(200)
            ->assertJsonPath('data.results.0.status', 'conflict')
            ->assertJsonPath('data.results.0.code', 'CONFLICT')
            ->assertJsonPath('data.results.0.details.server_version', 2);

        $this->assertSame(300000, Transaction::query()->findOrFail($expenseTxId)->amount);

        // Device 2 pulls changes starting from initialSequence -> receives hydrated snapshots
        $pullRes = $this->withToken($token)->getJson("/api/v1/sync/pull?device_id={$device2Id}&cursor={$initialSequence}&limit=50")
            ->assertStatus(200)
            ->assertJsonPath('data.has_more', false);

        $changes = $pullRes->json('data.changes');
        $this->assertNotEmpty($changes);

        $txChange = collect($changes)->first(fn ($c) => $c['entity_type'] === 'transactions' && $c['entity_id'] === $expenseTxId && $c['operation'] === 'update');
        $this->assertNotNull($txChange);
        $this->assertSame(300000, $txChange['data']['amount']);
        $this->assertSame($newBcaId, $txChange['data']['account_id']);

        // Sync status endpoint reports pending pull count accurately
        $nextCursor = (int) $pullRes->json('data.next_cursor');
        $this->withToken($token)->getJson("/api/v1/sync/status?device_id={$device2Id}")
            ->assertStatus(200)
            ->assertJsonPath('data.last_sequence', $nextCursor);
    }

    public function test_cross_user_device_cannot_push_or_pull(): void
    {
        $userA = User::factory()->create(['email' => 'sync_a@example.com']);
        $bootA = app(UserBootstrapService::class)->bootstrapNewUser($userA, [
            'id' => (string) Str::uuid(),
            'name' => 'Phone A',
        ]);
        $deviceAId = $bootA['device']->id;

        $userB = User::factory()->create(['email' => 'sync_b@example.com']);
        app(UserBootstrapService::class)->bootstrapNewUser($userB);
        $tokenB = $userB->createToken('phone-b')->plainTextToken;

        $this->withToken($tokenB)->postJson('/api/v1/sync/push', [
            'device_id' => $deviceAId,
            'operations' => [
                [
                    'operation_id' => (string) Str::uuid(),
                    'entity_type' => 'accounts',
                    'entity_id' => (string) Str::uuid(),
                    'operation_type' => 'create',
                    'payload' => ['name' => 'Hack', 'account_type' => 'cash'],
                ],
            ],
        ])->assertStatus(403)->assertJson(['code' => 'FORBIDDEN']);
    }
}


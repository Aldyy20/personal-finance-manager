<?php

namespace Tests\Feature\Qa;

use App\Models\Account;
use App\Models\Transaction;
use App\Services\LedgerService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class Phase7QualityAssuranceTest extends TestCase
{
    use RefreshDatabase;

    public function test_multi_device_simultaneous_transactions_and_bidirectional_sync_convergence(): void
    {
        $deviceAId = (string) Str::uuid();
        $deviceBId = (string) Str::uuid();

        $reg = $this->postJson('/api/v1/auth/register', [
            'name' => 'QA Multi Device',
            'email' => 'qa_multi@example.com',
            'password' => 'QaPassword123!',
            'password_confirmation' => 'QaPassword123!',
            'device' => [
                'id' => $deviceAId,
                'name' => 'Pixel QA 1',
                'platform' => 'android',
            ],
        ])->assertStatus(201);

        $token = $reg->json('data.access_token');
        $userId = $reg->json('data.user.id');

        $this->withToken($token)->postJson('/api/v1/devices/register', [
            'id' => $deviceBId,
            'name' => 'Galaxy QA 2',
            'platform' => 'android',
        ])->assertStatus(200);

        $accountsRes = $this->withToken($token)->getJson('/api/v1/accounts')->assertStatus(200);
        $cashId = $accountsRes->json('data.0.id');

        $catsRes = $this->withToken($token)->getJson('/api/v1/categories')->assertStatus(200);
        $categories = collect($catsRes->json('data'));
        $salaryCatId = $categories->firstWhere(fn ($c) => $c['type'] === 'income' && $c['name'] === 'Gaji')['id'];
        $foodCatId = $categories->firstWhere(fn ($c) => $c['type'] === 'expense' && $c['name'] === 'Makanan')['id'];

        // Device A offline mutations: Create BCA (5.000.000), Income (+2.000.000), Expense (-300.000 from Cash)
        $bcaId = (string) Str::uuid();
        $txIncId = (string) Str::uuid();
        $txExpAId = (string) Str::uuid();

        $this->withToken($token)->postJson('/api/v1/sync/push', [
            'device_id' => $deviceAId,
            'operations' => [
                [
                    'operation_id' => (string) Str::uuid(),
                    'entity_type' => 'accounts',
                    'entity_id' => $bcaId,
                    'operation_type' => 'create',
                    'base_version' => 0,
                    'payload' => [
                        'name' => 'BCA QA',
                        'account_type' => 'bank',
                        'opening_balance' => 5000000,
                        'opening_balance_date' => '2026-11-21',
                    ],
                ],
                [
                    'operation_id' => (string) Str::uuid(),
                    'entity_type' => 'transactions',
                    'entity_id' => $txIncId,
                    'operation_type' => 'create',
                    'base_version' => 0,
                    'payload' => [
                        'type' => 'income',
                        'account_id' => $bcaId,
                        'category_id' => $salaryCatId,
                        'amount' => 2000000,
                        'transaction_date' => '2026-11-21T08:00:00Z',
                        'description' => 'Gaji Device A',
                    ],
                ],
                [
                    'operation_id' => (string) Str::uuid(),
                    'entity_type' => 'transactions',
                    'entity_id' => $txExpAId,
                    'operation_type' => 'create',
                    'base_version' => 0,
                    'payload' => [
                        'type' => 'expense',
                        'account_id' => $cashId,
                        'category_id' => $foodCatId,
                        'amount' => 300000,
                        'transaction_date' => '2026-11-21T09:00:00Z',
                        'description' => 'Makan Device A',
                    ],
                ],
            ],
        ])->assertStatus(200)
            ->assertJsonPath('data.results.0.status', 'applied')
            ->assertJsonPath('data.results.1.status', 'applied')
            ->assertJsonPath('data.results.2.status', 'applied');

        // Device B simultaneously pushes independent offline mutations: GoPay (1.000.000), Expense (-250.000), Transfer (500.000 -> Cash)
        $gopayId = (string) Str::uuid();
        $txExpBId = (string) Str::uuid();
        $txTrfBId = (string) Str::uuid();

        $batchB = [
            'device_id' => $deviceBId,
            'operations' => [
                [
                    'operation_id' => (string) Str::uuid(),
                    'entity_type' => 'accounts',
                    'entity_id' => $gopayId,
                    'operation_type' => 'create',
                    'base_version' => 0,
                    'payload' => [
                        'name' => 'GoPay QA',
                        'account_type' => 'e_wallet',
                        'opening_balance' => 1000000,
                        'opening_balance_date' => '2026-11-21',
                    ],
                ],
                [
                    'operation_id' => (string) Str::uuid(),
                    'entity_type' => 'transactions',
                    'entity_id' => $txExpBId,
                    'operation_type' => 'create',
                    'base_version' => 0,
                    'payload' => [
                        'type' => 'expense',
                        'account_id' => $gopayId,
                        'category_id' => $foodCatId,
                        'amount' => 250000,
                        'transaction_date' => '2026-11-21T10:00:00Z',
                        'description' => 'Jajan Device B',
                    ],
                ],
                [
                    'operation_id' => (string) Str::uuid(),
                    'entity_type' => 'transfers',
                    'entity_id' => $txTrfBId,
                    'operation_type' => 'create',
                    'base_version' => 0,
                    'payload' => [
                        'source_account_id' => $gopayId,
                        'destination_account_id' => $cashId,
                        'amount' => 500000,
                        'transaction_date' => '2026-11-21T11:00:00Z',
                        'description' => 'Topup Cash Device B',
                    ],
                ],
            ],
        ];

        $this->withToken($token)->postJson('/api/v1/sync/push', $batchB)
            ->assertStatus(200)
            ->assertJsonPath('data.results.0.status', 'applied')
            ->assertJsonPath('data.results.1.status', 'applied')
            ->assertJsonPath('data.results.2.status', 'applied');

        // Replaying exact same batch B triggers idempotency without double-posting
        $this->withToken($token)->postJson('/api/v1/sync/push', $batchB)
            ->assertStatus(200)
            ->assertJsonPath('data.results.0.idempotent_replay', true)
            ->assertJsonPath('data.results.1.idempotent_replay', true)
            ->assertJsonPath('data.results.2.idempotent_replay', true);

        // Both devices pull full sequence cleanly
        $pullA = $this->withToken($token)->getJson("/api/v1/sync/pull?device_id={$deviceAId}&cursor=0&limit=100")
            ->assertStatus(200)
            ->assertJsonPath('data.has_more', false);
        $pullB = $this->withToken($token)->getJson("/api/v1/sync/pull?device_id={$deviceBId}&cursor=0&limit=100")
            ->assertStatus(200)
            ->assertJsonPath('data.has_more', false);

        $this->assertSame($pullA->json('data.next_cursor'), $pullB->json('data.next_cursor'));

        $ledger = app(LedgerService::class);
        $bca = Account::query()->findOrFail($bcaId);
        $gopay = Account::query()->findOrFail($gopayId);
        $cash = Account::query()->findOrFail($cashId);

        // BCA = 5M + 2M = 7.000.000; GoPay = 1M - 250k - 500k = 250.000; Cash = 0 - 300k + 500k = 200.000
        $this->assertSame(7000000, $bca->balance_cache);
        $this->assertSame(250000, $gopay->balance_cache);
        $this->assertSame(200000, $cash->balance_cache);

        $this->assertSame($bca->balance_cache, $ledger->calculateLedgerBalance($bca->id));
        $this->assertSame($gopay->balance_cache, $ledger->calculateLedgerBalance($gopay->id));
        $this->assertSame($cash->balance_cache, $ledger->calculateLedgerBalance($cash->id));
        $this->assertSame(4, Transaction::query()->where('user_id', $userId)->count());
    }

    public function test_security_unauthenticated_cross_user_idor_revoked_device_and_secret_redaction(): void
    {
        // Unauthenticated requests must be rejected with 401
        $this->getJson('/api/v1/accounts')->assertStatus(401);
        $this->getJson('/api/v1/transactions')->assertStatus(401);
        $this->getJson('/api/v1/reports/overview')->assertStatus(401);
        $this->postJson('/api/v1/sync/push', [])->assertStatus(401);

        $deviceA1 = (string) Str::uuid();
        $deviceA2 = (string) Str::uuid();

        $regA = $this->postJson('/api/v1/auth/register', [
            'name' => 'Owner A',
            'email' => 'owner_a@example.com',
            'password' => 'OwnerPass123!',
            'password_confirmation' => 'OwnerPass123!',
            'device' => ['id' => $deviceA1, 'name' => 'A1', 'platform' => 'android'],
        ])->assertStatus(201);
        $tokenA = $regA->json('data.access_token');

        // Verify user payloads never expose password or remember_token
        $meRes = $this->withToken($tokenA)->getJson('/api/v1/auth/me')->assertStatus(200);
        $this->assertArrayNotHasKey('password', $meRes->json('data.user'));
        $this->assertArrayNotHasKey('remember_token', $meRes->json('data.user'));

        // Register second device for User A, then revoke it and ensure it cannot sync anymore
        $this->withToken($tokenA)->postJson('/api/v1/devices/register', [
            'id' => $deviceA2,
            'name' => 'A2 Lost Phone',
            'platform' => 'android',
        ])->assertStatus(200);

        $this->withToken($tokenA)->postJson("/api/v1/devices/{$deviceA2}/revoke")->assertStatus(200);

        $this->withToken($tokenA)->getJson("/api/v1/sync/pull?device_id={$deviceA2}&cursor=0")
            ->assertStatus(422)
            ->assertJson(['code' => 'VALIDATION_ERROR']);

        $this->withToken($tokenA)->postJson('/api/v1/sync/push', [
            'device_id' => $deviceA2,
            'operations' => [
                [
                    'operation_id' => (string) Str::uuid(),
                    'entity_type' => 'accounts',
                    'entity_id' => (string) Str::uuid(),
                    'operation_type' => 'create',
                    'payload' => ['name' => 'Blocked', 'account_type' => 'cash'],
                ],
            ],
        ])->assertStatus(422)->assertJson(['code' => 'VALIDATION_ERROR']);

        // Create domain entities owned by User A
        $cashAId = $this->withToken($tokenA)->getJson('/api/v1/accounts')->json('data.0.id');
        $bcaAId = $this->withToken($tokenA)->postJson('/api/v1/accounts', [
            'name' => 'Secret A Bank',
            'account_type' => 'bank',
            'opening_balance' => 1500000,
            'opening_balance_date' => '2026-11-21',
        ])->assertStatus(201)->json('data.id');

        $catsA = collect($this->withToken($tokenA)->getJson('/api/v1/categories')->json('data'));
        $foodAId = $catsA->firstWhere(fn ($c) => $c['type'] === 'expense')['id'];

        $txAId = $this->withToken($tokenA)->postJson('/api/v1/transactions', [
            'type' => 'expense',
            'account_id' => $bcaAId,
            'category_id' => $foodAId,
            'amount' => 50000,
            'transaction_date' => '2026-11-21T12:00:00Z',
        ])->assertStatus(201)->json('data.id');

        $trfAId = $this->withToken($tokenA)->postJson('/api/v1/transfers', [
            'source_account_id' => $bcaAId,
            'destination_account_id' => $cashAId,
            'amount' => 100000,
            'transaction_date' => '2026-11-21T12:05:00Z',
        ])->assertStatus(201)->json('data.id');

        $budgetAId = $this->withToken($tokenA)->postJson('/api/v1/budgets', [
            'name' => 'Secret A Budget',
            'start_date' => '2026-11-01',
            'end_date' => '2026-11-30',
            'total_limit' => 2000000,
        ])->assertStatus(201)->json('data.id');

        // Register User B and assert IDOR isolation across all endpoints
        $regB = $this->postJson('/api/v1/auth/register', [
            'name' => 'Attacker B',
            'email' => 'attacker_b@example.com',
            'password' => 'AttackerPass123!',
            'password_confirmation' => 'AttackerPass123!',
        ])->assertStatus(201);
        $tokenB = $regB->json('data.access_token');

        $this->app['auth']->forgetGuards();

        $this->withToken($tokenB)->getJson("/api/v1/accounts/{$bcaAId}")->assertStatus(403);
        $this->withToken($tokenB)->getJson("/api/v1/transactions/{$txAId}")->assertStatus(403);
        $this->withToken($tokenB)->getJson("/api/v1/transfers/{$trfAId}")->assertStatus(403);
        $this->withToken($tokenB)->getJson("/api/v1/budgets/{$budgetAId}")->assertStatus(403);
        $this->withToken($tokenB)->getJson("/api/v1/budgets/{$budgetAId}/summary")->assertStatus(403);
        $this->withToken($tokenB)->getJson("/api/v1/sync/pull?device_id={$deviceA1}&cursor=0")->assertStatus(403);
    }

    public function test_batch_50_sync_operations_performance_and_ledger_invariant(): void
    {
        $deviceId = (string) Str::uuid();
        $reg = $this->postJson('/api/v1/auth/register', [
            'name' => 'Batch Perf Tester',
            'email' => 'perf50@example.com',
            'password' => 'PerfPass123!',
            'password_confirmation' => 'PerfPass123!',
            'device' => ['id' => $deviceId, 'name' => 'Perf Phone', 'platform' => 'android'],
        ])->assertStatus(201);

        $token = $reg->json('data.access_token');
        $cashId = $this->withToken($token)->getJson('/api/v1/accounts')->json('data.0.id');
        $cats = collect($this->withToken($token)->getJson('/api/v1/categories')->json('data'));
        $incomeCatId = $cats->firstWhere(fn ($c) => $c['type'] === 'income')['id'];
        $expenseCatId = $cats->firstWhere(fn ($c) => $c['type'] === 'expense')['id'];

        $bankId = (string) Str::uuid();
        $ops = [
            [
                'operation_id' => (string) Str::uuid(),
                'entity_type' => 'accounts',
                'entity_id' => $bankId,
                'operation_type' => 'create',
                'base_version' => 0,
                'payload' => [
                    'name' => 'Mandiri Perf',
                    'account_type' => 'bank',
                    'opening_balance' => 50000000,
                    'opening_balance_date' => '2026-11-21',
                ],
            ],
        ];

        $nowIso = now()->utc()->toIso8601ZuluString('millisecond');

        // 20 incomes x 100.000 = +2.000.000
        for ($i = 0; $i < 20; $i++) {
            $ops[] = [
                'operation_id' => (string) Str::uuid(),
                'entity_type' => 'transactions',
                'entity_id' => (string) Str::uuid(),
                'operation_type' => 'create',
                'base_version' => 0,
                'payload' => [
                    'type' => 'income',
                    'account_id' => $bankId,
                    'category_id' => $incomeCatId,
                    'amount' => 100000,
                    'transaction_date' => $nowIso,
                    'description' => "Batch Inc {$i}",
                ],
            ];
        }

        // 20 expenses x 50.000 = -1.000.000 (keep first 3 IDs for edit & void tests)
        $expIds = [];
        for ($i = 0; $i < 20; $i++) {
            $id = (string) Str::uuid();
            $expIds[] = $id;
            $ops[] = [
                'operation_id' => (string) Str::uuid(),
                'entity_type' => 'transactions',
                'entity_id' => $id,
                'operation_type' => 'create',
                'base_version' => 0,
                'payload' => [
                    'type' => 'expense',
                    'account_id' => $bankId,
                    'category_id' => $expenseCatId,
                    'amount' => 50000,
                    'transaction_date' => $nowIso,
                    'description' => "Batch Exp {$i}",
                ],
            ];
        }

        // 5 transfers x 200.000 = Bank -1.000.000, Cash +1.000.000
        for ($i = 0; $i < 5; $i++) {
            $ops[] = [
                'operation_id' => (string) Str::uuid(),
                'entity_type' => 'transfers',
                'entity_id' => (string) Str::uuid(),
                'operation_type' => 'create',
                'base_version' => 0,
                'payload' => [
                    'source_account_id' => $bankId,
                    'destination_account_id' => $cashId,
                    'amount' => 200000,
                    'transaction_date' => $nowIso,
                    'description' => "Batch Trf {$i}",
                ],
            ];
        }

        // 2 edits (50k -> 75k each, net -50k extra)
        $ops[] = [
            'operation_id' => (string) Str::uuid(),
            'entity_type' => 'transactions',
            'entity_id' => $expIds[0],
            'operation_type' => 'update',
            'base_version' => 1,
            'payload' => ['amount' => 75000, 'reason' => 'Edit perf 0'],
        ];
        $ops[] = [
            'operation_id' => (string) Str::uuid(),
            'entity_type' => 'transactions',
            'entity_id' => $expIds[1],
            'operation_type' => 'update',
            'base_version' => 1,
            'payload' => ['amount' => 75000, 'reason' => 'Edit perf 1'],
        ];

        // 1 void (+50k restored)
        $ops[] = [
            'operation_id' => (string) Str::uuid(),
            'entity_type' => 'transactions',
            'entity_id' => $expIds[2],
            'operation_type' => 'void',
            'base_version' => 1,
            'payload' => ['reason' => 'Void perf 2'],
        ];

        // 1 adjustment (+50k)
        $ops[] = [
            'operation_id' => (string) Str::uuid(),
            'entity_type' => 'account_adjustments',
            'entity_id' => (string) Str::uuid(),
            'operation_type' => 'create',
            'base_version' => 0,
            'payload' => [
                'account_id' => $bankId,
                'amount_signed' => 50000,
                'reason' => 'Perf adjustment',
            ],
        ];

        $this->assertCount(50, $ops);

        $started = microtime(true);
        $pushRes = $this->withToken($token)->postJson('/api/v1/sync/push', [
            'device_id' => $deviceId,
            'operations' => $ops,
        ]);
        $elapsedMs = (microtime(true) - $started) * 1000.0;

        $pushRes->assertStatus(200);
        foreach ($pushRes->json('data.results') as $res) {
            $this->assertSame('applied', $res['status']);
        }
        $this->assertLessThan(5000.0, $elapsedMs, '50-operation sync batch exceeded 5000ms SLA.');

        // Bank: 50M + 2M - 1M - 1M - 50k (edits) + 50k (void) + 50k (adj) = 50.050.000
        // Cash: +1.000.000
        $ledger = app(LedgerService::class);
        $bank = Account::query()->findOrFail($bankId);
        $cash = Account::query()->findOrFail($cashId);

        $this->assertSame(50050000, $bank->balance_cache);
        $this->assertSame(1000000, $cash->balance_cache);
        $this->assertSame($bank->balance_cache, $ledger->calculateLedgerBalance($bankId));
        $this->assertSame($cash->balance_cache, $ledger->calculateLedgerBalance($cashId));

        // Overview report: income 2.000.000, expense 1.000.000 (17*50k + 2*75k = 850k + 150k = 1.000.000), transfers & voided excluded
        $this->withToken($token)->getJson('/api/v1/reports/overview?period=this_month')
            ->assertStatus(200)
            ->assertJsonPath('data.total_income', 2000000)
            ->assertJsonPath('data.total_expense', 1000000)
            ->assertJsonPath('data.total_balance', 51050000);
    }
}


<?php

namespace App\Services;

use App\Exceptions\EntityConflictException;
use App\Exceptions\FinancialValidationException;
use App\Exceptions\OwnershipViolationException;
use App\Http\Resources\Api\V1\AccountAdjustmentResource;
use App\Http\Resources\Api\V1\AccountResource;
use App\Http\Resources\Api\V1\BudgetResource;
use App\Http\Resources\Api\V1\CategoryResource;
use App\Http\Resources\Api\V1\ReceiptResource;
use App\Http\Resources\Api\V1\TransactionResource;
use App\Http\Resources\Api\V1\UserSettingResource;
use App\Models\Account;
use App\Models\AccountAdjustment;
use App\Models\Budget;
use App\Models\BudgetCategory;
use App\Models\Category;
use App\Models\Device;
use App\Models\Receipt;
use App\Models\SyncChange;
use App\Models\SyncCursor;
use App\Models\SyncOperation;
use App\Models\SyncSequence;
use App\Models\Transaction;
use App\Models\User;
use App\Models\UserSetting;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Handles idempotent multi-device sync push batches, cursor-based sync pull hydration, and sync status.
 */
class SyncService
{
    public function __construct(
        private readonly AccountService $accountService,
        private readonly CategoryService $categoryService,
        private readonly TransactionService $transactionService,
        private readonly TransferService $transferService,
        private readonly BudgetService $budgetService,
        private readonly UserBootstrapService $syncRecorder,
    ) {}

    /**
     * Processes a batch of offline client operations idempotently.
     *
     * @param  list<array<string, mixed>>  $operations
     * @return array<string, mixed>
     */
    public function push(User $user, string $deviceId, array $operations): array
    {
        $device = $this->assertActiveOwnedDevice($user->id, $deviceId);

        $results = [];
        foreach ($operations as $op) {
            $results[] = $this->processSingleOperation($user, $device, $op);
        }

        $device->update(['last_sync_at' => now()->utc()]);

        $lastSequence = (int) (SyncSequence::query()
            ->where('user_id', $user->id)
            ->value('last_sequence') ?? 0);

        return [
            'device_id' => $device->id,
            'last_sequence' => $lastSequence,
            'results' => $results,
        ];
    }

    /**
     * Pulls ordered server changes past cursor and hydrates entity snapshots.
     *
     * @return array<string, mixed>
     */
    public function pull(User $user, ?string $deviceId, int $cursor, int $limit = 100): array
    {
        $limit = max(1, min(200, $limit));
        $device = $deviceId !== null ? $this->assertActiveOwnedDevice($user->id, $deviceId) : null;

        $rows = SyncChange::query()
            ->where('user_id', $user->id)
            ->where('sequence', '>', $cursor)
            ->orderBy('sequence')
            ->limit($limit + 1)
            ->get();

        $hasMore = $rows->count() > $limit;
        $changes = $hasMore ? $rows->take($limit) : $rows;

        $hydrated = $changes->map(function (SyncChange $change) {
            return [
                'sequence' => (int) $change->sequence,
                'entity_type' => $change->entity_type,
                'entity_id' => $change->entity_id,
                'operation' => $change->operation,
                'entity_version' => (int) $change->entity_version,
                'created_at' => $change->created_at?->utc()->toIso8601ZuluString('millisecond'),
                'data' => $this->hydrateEntitySnapshot($change->entity_type, $change->entity_id),
            ];
        })->values()->all();

        $nextCursor = $changes->isNotEmpty()
            ? (int) $changes->last()->sequence
            : $cursor;

        if ($device !== null) {
            $now = now()->utc();
            $device->update(['last_sync_at' => $now]);

            // Only record the cursor the client has already acknowledged via $cursor parameter.
            $syncCursor = SyncCursor::query()->firstOrCreate(
                ['user_id' => $user->id, 'device_id' => $device->id],
                ['id' => (string) Str::uuid(), 'last_cursor' => 0]
            );
            $syncCursor->update([
                'last_cursor' => max((int) $syncCursor->last_cursor, $cursor),
                'last_sync_at' => $now,
            ]);
        }

        return [
            'changes' => $hydrated,
            'next_cursor' => $nextCursor,
            'has_more' => $hasMore,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function status(User $user, ?string $deviceId): array
    {
        $lastSequence = (int) (SyncSequence::query()
            ->where('user_id', $user->id)
            ->value('last_sequence') ?? 0);

        $cursor = null;
        $lastSyncAt = null;

        if ($deviceId !== null) {
            $device = Device::query()->find($deviceId);
            if ($device === null || $device->user_id !== $user->id) {
                throw new OwnershipViolationException('Device does not belong to the authenticated user.');
            }

            $cursorRow = SyncCursor::query()
                ->where('user_id', $user->id)
                ->where('device_id', $device->id)
                ->first();

            $cursor = (int) ($cursorRow?->last_cursor ?? 0);
            $lastSyncAt = ($cursorRow?->last_sync_at ?? $device->last_sync_at)?->utc()->toIso8601ZuluString('millisecond');
        }

        return [
            'last_sequence' => $lastSequence,
            'device_cursor' => $cursor,
            'pending_pull_count' => $cursor !== null ? max(0, $lastSequence - $cursor) : null,
            'last_sync_at' => $lastSyncAt,
            'server_time' => now()->utc()->toIso8601ZuluString('millisecond'),
        ];
    }

    /**
     * @param  array<string, mixed>  $op
     * @return array<string, mixed>
     */
    private function processSingleOperation(User $user, Device $device, array $op): array
    {
        $operationId = (string) ($op['operation_id'] ?? '');
        $entityType = (string) ($op['entity_type'] ?? '');
        $entityId = (string) ($op['entity_id'] ?? '');
        $operationType = (string) ($op['operation_type'] ?? '');
        $baseVersion = isset($op['base_version']) ? (int) $op['base_version'] : null;
        $payload = is_array($op['payload'] ?? null) ? $op['payload'] : [];

        // 1. Idempotency check
        $existingOp = SyncOperation::query()
            ->where('user_id', $user->id)
            ->where('operation_id', $operationId)
            ->first();

        if ($existingOp !== null) {
            $stored = $existingOp->response_data ?? [];
            $stored['idempotent_replay'] = true;

            return $stored;
        }

        try {
            $applied = DB::transaction(function () use (
                $user,
                $device,
                $operationId,
                $entityType,
                $entityId,
                $operationType,
                $baseVersion,
                $payload
            ) {
                $payload['id'] = $payload['id'] ?? $entityId;
                $payload['created_by_device_id'] = $device->id;
                $payload['device_id'] = $device->id;

                $dispatchResult = $this->dispatchOperation(
                    $user,
                    $entityType,
                    $entityId,
                    $operationType,
                    $baseVersion,
                    $payload
                );

                $resultPayload = [
                    'operation_id' => $operationId,
                    'status' => 'applied',
                    'entity_type' => $entityType,
                    'entity_id' => $dispatchResult['entity_id'],
                    'entity_version' => $dispatchResult['entity_version'],
                    'data' => $dispatchResult['data'],
                    'idempotent_replay' => false,
                ];

                SyncOperation::query()->create([
                    'id' => (string) Str::uuid(),
                    'user_id' => $user->id,
                    'device_id' => $device->id,
                    'operation_id' => $operationId,
                    'entity_type' => $entityType,
                    'entity_id' => $dispatchResult['entity_id'],
                    'operation_type' => $operationType,
                    'status' => 'applied',
                    'response_data' => $resultPayload,
                    'created_at' => now()->utc(),
                ]);

                return $resultPayload;
            });

            return $applied;
        } catch (EntityConflictException $e) {
            return [
                'operation_id' => $operationId,
                'status' => 'conflict',
                'code' => 'CONFLICT',
                'entity_type' => $entityType,
                'entity_id' => $entityId,
                'message' => $e->getMessage(),
                'details' => $e->context,
                'idempotent_replay' => false,
            ];
        } catch (FinancialValidationException $e) {
            return [
                'operation_id' => $operationId,
                'status' => 'rejected',
                'code' => 'VALIDATION_ERROR',
                'entity_type' => $entityType,
                'entity_id' => $entityId,
                'message' => $e->getMessage(),
                'errors' => $e->errors,
                'idempotent_replay' => false,
            ];
        } catch (OwnershipViolationException $e) {
            return [
                'operation_id' => $operationId,
                'status' => 'rejected',
                'code' => 'FORBIDDEN',
                'entity_type' => $entityType,
                'entity_id' => $entityId,
                'message' => $e->getMessage(),
                'idempotent_replay' => false,
            ];
        }
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array{entity_id: string, entity_version: int, data: array<string, mixed>}
     */
    private function dispatchOperation(
        User $user,
        string $entityType,
        string $entityId,
        string $operationType,
        ?int $baseVersion,
        array $payload
    ): array {
        return match ($entityType) {
            'accounts' => match ($operationType) {
                'create' => (function () use ($user, $payload) {
                    $account = $this->accountService->createAccount($user, $payload);

                    return ['entity_id' => $account->id, 'entity_version' => $account->version, 'data' => (new AccountResource($account))->resolve()];
                })(),
                'update' => (function () use ($user, $entityId, $payload, $baseVersion) {
                    $account = $this->accountService->updateAccount($user, $entityId, $payload, $baseVersion);

                    return ['entity_id' => $account->id, 'entity_version' => $account->version, 'data' => (new AccountResource($account))->resolve()];
                })(),
                'archive' => (function () use ($user, $entityId, $baseVersion) {
                    $account = $this->accountService->archiveAccount($user, $entityId, $baseVersion);

                    return ['entity_id' => $account->id, 'entity_version' => $account->version, 'data' => (new AccountResource($account))->resolve()];
                })(),
                'restore' => (function () use ($user, $entityId, $baseVersion) {
                    $account = $this->accountService->restoreAccount($user, $entityId, $baseVersion);

                    return ['entity_id' => $account->id, 'entity_version' => $account->version, 'data' => (new AccountResource($account))->resolve()];
                })(),
                default => throw new FinancialValidationException("Unsupported account operation: {$operationType}."),
            },
            'account_adjustments' => match ($operationType) {
                'create', 'adjustment' => (function () use ($user, $payload) {
                    $accountId = (string) ($payload['account_id'] ?? '');
                    $adj = $this->accountService->createAdjustment($user, $accountId, $payload);

                    return ['entity_id' => $adj->id, 'entity_version' => 1, 'data' => (new AccountAdjustmentResource($adj))->resolve()];
                })(),
                default => throw new FinancialValidationException("Unsupported adjustment operation: {$operationType}."),
            },
            'categories' => match ($operationType) {
                'create' => (function () use ($user, $payload) {
                    $cat = $this->categoryService->createCategory($user, $payload);

                    return ['entity_id' => $cat->id, 'entity_version' => $cat->version, 'data' => (new CategoryResource($cat))->resolve()];
                })(),
                'update' => (function () use ($user, $entityId, $payload, $baseVersion) {
                    $cat = $this->categoryService->updateCategory($user, $entityId, $payload, $baseVersion);

                    return ['entity_id' => $cat->id, 'entity_version' => $cat->version, 'data' => (new CategoryResource($cat))->resolve()];
                })(),
                'archive' => (function () use ($user, $entityId, $baseVersion) {
                    $cat = $this->categoryService->archiveCategory($user, $entityId, $baseVersion);

                    return ['entity_id' => $cat->id, 'entity_version' => $cat->version, 'data' => (new CategoryResource($cat))->resolve()];
                })(),
                'restore' => (function () use ($user, $entityId, $baseVersion) {
                    $cat = $this->categoryService->restoreCategory($user, $entityId, $baseVersion);

                    return ['entity_id' => $cat->id, 'entity_version' => $cat->version, 'data' => (new CategoryResource($cat))->resolve()];
                })(),
                default => throw new FinancialValidationException("Unsupported category operation: {$operationType}."),
            },
            'transactions' => match ($operationType) {
                'create' => (function () use ($user, $payload) {
                    $tx = $this->transactionService->createTransaction($user, $payload);

                    return ['entity_id' => $tx->id, 'entity_version' => $tx->version, 'data' => (new TransactionResource($tx))->resolve()];
                })(),
                'update' => (function () use ($user, $entityId, $payload, $baseVersion) {
                    $tx = $this->transactionService->updateTransaction($user, $entityId, $payload, $baseVersion);

                    return ['entity_id' => $tx->id, 'entity_version' => $tx->version, 'data' => (new TransactionResource($tx))->resolve()];
                })(),
                'void', 'delete' => (function () use ($user, $entityId, $payload, $baseVersion) {
                    $tx = $this->transactionService->voidTransaction(
                        $user,
                        $entityId,
                        $payload['reason'] ?? null,
                        $payload['device_id'] ?? null,
                        $baseVersion
                    );

                    return ['entity_id' => $tx->id, 'entity_version' => $tx->version, 'data' => (new TransactionResource($tx))->resolve()];
                })(),
                default => throw new FinancialValidationException("Unsupported transaction operation: {$operationType}."),
            },
            'transfers' => match ($operationType) {
                'create' => (function () use ($user, $payload) {
                    $tx = $this->transferService->createTransfer($user, $payload);

                    return ['entity_id' => $tx->id, 'entity_version' => $tx->version, 'data' => (new TransactionResource($tx))->resolve()];
                })(),
                'update' => (function () use ($user, $entityId, $payload, $baseVersion) {
                    $tx = $this->transferService->updateTransfer($user, $entityId, $payload, $baseVersion);

                    return ['entity_id' => $tx->id, 'entity_version' => $tx->version, 'data' => (new TransactionResource($tx))->resolve()];
                })(),
                'void', 'delete' => (function () use ($user, $entityId, $payload, $baseVersion) {
                    $tx = $this->transferService->voidTransfer(
                        $user,
                        $entityId,
                        $payload['reason'] ?? null,
                        $payload['device_id'] ?? null,
                        $baseVersion
                    );

                    return ['entity_id' => $tx->id, 'entity_version' => $tx->version, 'data' => (new TransactionResource($tx))->resolve()];
                })(),
                default => throw new FinancialValidationException("Unsupported transfer operation: {$operationType}."),
            },
            'budgets' => match ($operationType) {
                'create' => (function () use ($user, $payload) {
                    $budget = $this->budgetService->createBudget($user, $payload);

                    return ['entity_id' => $budget->id, 'entity_version' => $budget->version, 'data' => (new BudgetResource($budget))->resolve()];
                })(),
                'update' => (function () use ($user, $entityId, $payload, $baseVersion) {
                    $budget = $this->budgetService->updateBudget($user, $entityId, $payload, $baseVersion);

                    return ['entity_id' => $budget->id, 'entity_version' => $budget->version, 'data' => (new BudgetResource($budget))->resolve()];
                })(),
                'archive' => (function () use ($user, $entityId, $baseVersion) {
                    $budget = $this->budgetService->archiveBudget($user, $entityId, $baseVersion);

                    return ['entity_id' => $budget->id, 'entity_version' => $budget->version, 'data' => (new BudgetResource($budget))->resolve()];
                })(),
                default => throw new FinancialValidationException("Unsupported budget operation: {$operationType}."),
            },
            'user_settings' => match ($operationType) {
                'update' => (function () use ($user, $payload, $baseVersion) {
                    $settings = UserSetting::query()->where('user_id', $user->id)->lockForUpdate()->firstOrFail();
                    if ($baseVersion !== null && $settings->version !== $baseVersion) {
                        throw new EntityConflictException('User settings version conflict detected.', [
                            'entity_type' => 'user_settings',
                            'entity_id' => $settings->id,
                            'server_version' => $settings->version,
                            'base_version' => $baseVersion,
                        ]);
                    }
                    $settings->fill(array_intersect_key($payload, array_flip([
                        'theme_mode',
                        'timezone',
                        'budget_warning_percent',
                        'notifications_enabled',
                    ])));
                    $settings->version = $settings->version + 1;
                    $settings->save();
                    $this->syncRecorder->recordSyncChange($user->id, 'user_settings', $settings->id, 'update', $settings->version);

                    return ['entity_id' => $settings->id, 'entity_version' => $settings->version, 'data' => (new UserSettingResource($settings))->resolve()];
                })(),
                default => throw new FinancialValidationException("Unsupported user_settings operation: {$operationType}."),
            },
            default => throw new FinancialValidationException("Unsupported entity_type: {$entityType}."),
        };
    }

    /**
     * Hydrates the latest entity snapshot (including deleted_at tombstones) for /sync/pull.
     *
     * @return array<string, mixed>|null
     */
    private function hydrateEntitySnapshot(string $entityType, string $entityId): ?array
    {
        return match ($entityType) {
            'user_settings' => ($s = UserSetting::query()->find($entityId)) ? (new UserSettingResource($s))->resolve() : null,
            'accounts' => ($a = Account::withTrashed()->find($entityId)) ? (new AccountResource($a))->resolve() : null,
            'categories' => ($c = Category::withTrashed()->find($entityId)) ? (new CategoryResource($c))->resolve() : null,
            'transactions' => ($t = Transaction::withTrashed()->with(['category', 'movements'])->find($entityId)) ? (new TransactionResource($t))->resolve() : null,
            'account_adjustments' => ($adj = AccountAdjustment::query()->find($entityId)) ? (new AccountAdjustmentResource($adj))->resolve() : null,
            'budgets' => ($b = Budget::withTrashed()->with('budgetCategories.category')->find($entityId)) ? (new BudgetResource($b))->resolve() : null,
            'budget_categories' => ($bc = BudgetCategory::withTrashed()->find($entityId)) ? [
                'id' => $bc->id,
                'budget_id' => $bc->budget_id,
                'category_id' => $bc->category_id,
                'category_type' => $bc->category_type,
                'amount_limit' => $bc->amount_limit,
                'version' => $bc->version,
                'deleted_at' => $bc->deleted_at?->utc()->toIso8601ZuluString('millisecond'),
            ] : null,
            'receipts' => ($r = Receipt::withTrashed()->find($entityId)) ? (new ReceiptResource($r))->resolve() : null,
            default => null,
        };
    }

    private function assertActiveOwnedDevice(string $userId, string $deviceId): Device
    {
        $device = Device::query()->find($deviceId);
        if ($device === null || $device->user_id !== $userId) {
            throw new OwnershipViolationException('Device does not belong to the authenticated user.');
        }

        if (! $device->is_active) {
            throw new FinancialValidationException(
                'Device has been revoked and cannot synchronize.',
                ['device_id' => ['This device is inactive or revoked.']]
            );
        }

        return $device;
    }
}

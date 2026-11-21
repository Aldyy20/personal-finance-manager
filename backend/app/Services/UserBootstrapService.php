<?php

namespace App\Services;

use App\Models\Account;
use App\Models\AccountMovement;
use App\Models\Category;
use App\Models\Device;
use App\Models\SyncChange;
use App\Models\SyncCursor;
use App\Models\SyncSequence;
use App\Models\User;
use App\Models\UserSetting;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class UserBootstrapService
{
    /**
     * Default income categories specified in Master PRD Section 5.3.
     *
     * @var list<array{name: string, icon: string, color: string}>
     */
    private const DEFAULT_INCOME_CATEGORIES = [
        ['name' => 'Gaji', 'icon' => 'payments', 'color' => '#1B8A5A'],
        ['name' => 'Freelance', 'icon' => 'work', 'color' => '#00796B'],
        ['name' => 'Bisnis', 'icon' => 'store', 'color' => '#0288D1'],
        ['name' => 'Investasi', 'icon' => 'trending_up', 'color' => '#2E7D32'],
        ['name' => 'Hadiah', 'icon' => 'card_giftcard', 'color' => '#7B1FA2'],
        ['name' => 'Penjualan', 'icon' => 'sell', 'color' => '#00838F'],
        ['name' => 'Lainnya', 'icon' => 'category', 'color' => '#546E7A'],
    ];

    /**
     * Default expense categories specified in Master PRD Section 5.3.
     *
     * @var list<array{name: string, icon: string, color: string}>
     */
    private const DEFAULT_EXPENSE_CATEGORIES = [
        ['name' => 'Makanan', 'icon' => 'restaurant', 'color' => '#E65100'],
        ['name' => 'Transportasi', 'icon' => 'directions_car', 'color' => '#1565C0'],
        ['name' => 'Belanja', 'icon' => 'shopping_bag', 'color' => '#AD1457'],
        ['name' => 'Tagihan', 'icon' => 'receipt_long', 'color' => '#C62828'],
        ['name' => 'Kesehatan', 'icon' => 'local_hospital', 'color' => '#D32F2F'],
        ['name' => 'Pendidikan', 'icon' => 'school', 'color' => '#4527A0'],
        ['name' => 'Hiburan', 'icon' => 'movie', 'color' => '#6A1B9A'],
        ['name' => 'Tempat Tinggal', 'icon' => 'home', 'color' => '#4E342E'],
        ['name' => 'Komunikasi', 'icon' => 'phone_android', 'color' => '#0277BD'],
        ['name' => 'Lainnya', 'icon' => 'more_horiz', 'color' => '#546E7A'],
    ];

    /**
     * Atomically initializes default user settings, income/expense categories,
     * initial Cash account with zero opening movement, sync sequence, and optional device.
     *
     * @param  array{id?: string, name?: string, platform?: string, app_version?: string|null}|null  $devicePayload
     * @return array{settings: UserSetting, cash_account: Account, device: Device|null, last_sequence: int}
     */
    public function bootstrapNewUser(User $user, ?array $devicePayload = null): array
    {
        return DB::transaction(function () use ($user, $devicePayload) {
            $now = now()->utc();

            $syncSequence = SyncSequence::query()->create([
                'user_id' => $user->id,
                'last_sequence' => 0,
            ]);

            $sequence = 0;

            $settings = UserSetting::query()->create([
                'id' => (string) Str::uuid(),
                'user_id' => $user->id,
                'theme_mode' => 'system',
                'currency' => 'IDR',
                'timezone' => 'Asia/Jakarta',
                'budget_warning_percent' => 80,
                'notifications_enabled' => true,
                'version' => 1,
            ]);

            $sequence = $this->appendSyncChange($user->id, $sequence, 'user_settings', $settings->id, 'create', 1, $now);

            foreach (self::DEFAULT_INCOME_CATEGORIES as $index => $cat) {
                $category = Category::query()->create([
                    'id' => (string) Str::uuid(),
                    'user_id' => $user->id,
                    'name' => $cat['name'],
                    'type' => 'income',
                    'icon' => $cat['icon'],
                    'color' => $cat['color'],
                    'is_default' => true,
                    'is_active' => true,
                    'sort_order' => $index + 1,
                    'version' => 1,
                ]);
                $sequence = $this->appendSyncChange($user->id, $sequence, 'categories', $category->id, 'create', 1, $now);
            }

            foreach (self::DEFAULT_EXPENSE_CATEGORIES as $index => $cat) {
                $category = Category::query()->create([
                    'id' => (string) Str::uuid(),
                    'user_id' => $user->id,
                    'name' => $cat['name'],
                    'type' => 'expense',
                    'icon' => $cat['icon'],
                    'color' => $cat['color'],
                    'is_default' => true,
                    'is_active' => true,
                    'sort_order' => $index + 1,
                    'version' => 1,
                ]);
                $sequence = $this->appendSyncChange($user->id, $sequence, 'categories', $category->id, 'create', 1, $now);
            }

            $cashAccount = Account::query()->create([
                'id' => (string) Str::uuid(),
                'user_id' => $user->id,
                'name' => 'Cash',
                'account_type' => 'cash',
                'institution_name' => null,
                'account_number' => null,
                'opening_balance' => 0,
                'opening_balance_date' => $now->toDateString(),
                'balance_cache' => 0,
                'icon' => 'wallet',
                'color' => '#00796B',
                'is_active' => true,
                'version' => 1,
            ]);

            AccountMovement::query()->create([
                'id' => (string) Str::uuid(),
                'user_id' => $user->id,
                'account_id' => $cashAccount->id,
                'transaction_id' => null,
                'adjustment_id' => null,
                'posting_group_id' => (string) Str::uuid(),
                'movement_type' => 'opening',
                'amount_signed' => 0,
                'reversal_of_id' => null,
                'created_at' => $now,
            ]);

            $sequence = $this->appendSyncChange($user->id, $sequence, 'accounts', $cashAccount->id, 'create', 1, $now);

            $syncSequence->update(['last_sequence' => $sequence]);

            $device = null;
            if ($devicePayload !== null) {
                $device = $this->registerOrUpdateDevice($user, $devicePayload);
            }

            return [
                'settings' => $settings,
                'cash_account' => $cashAccount,
                'device' => $device,
                'last_sequence' => $sequence,
            ];
        });
    }

    /**
     * Registers or updates an active device belonging to the authenticated user and ensures its sync cursor exists.
     *
     * @param  array{id?: string, name?: string, device_name?: string, platform?: string, app_version?: string|null}  $payload
     */
    public function registerOrUpdateDevice(User $user, array $payload): Device
    {
        return DB::transaction(function () use ($user, $payload) {
            $deviceId = $payload['id'] ?? (string) Str::uuid();
            $existing = Device::query()->find($deviceId);

            if ($existing !== null && $existing->user_id !== $user->id) {
                throw new AccessDeniedHttpException('Device ID is registered to another account.');
            }

            $deviceName = $payload['name'] ?? $payload['device_name'] ?? 'Android Device';
            $platform = $payload['platform'] ?? 'android';
            $appVersion = $payload['app_version'] ?? null;

            if ($existing !== null) {
                $existing->update([
                    'device_name' => $deviceName,
                    'platform' => $platform,
                    'app_version' => $appVersion,
                    'is_active' => true,
                ]);
                $device = $existing;
            } else {
                $device = Device::query()->create([
                    'id' => $deviceId,
                    'user_id' => $user->id,
                    'device_name' => $deviceName,
                    'platform' => $platform,
                    'app_version' => $appVersion,
                    'is_active' => true,
                ]);
            }

            SyncCursor::query()->firstOrCreate(
                [
                    'user_id' => $user->id,
                    'device_id' => $device->id,
                ],
                [
                    'id' => (string) Str::uuid(),
                    'last_cursor' => 0,
                    'last_sync_at' => null,
                ]
            );

            return $device;
        });
    }

    /**
     * Locks user's sync sequence row and appends a new SyncChange entry inside an existing transaction.
     */
    public function recordSyncChange(
        string $userId,
        string $entityType,
        string $entityId,
        string $operation,
        int $entityVersion
    ): int {
        $sequenceRow = SyncSequence::query()
            ->where('user_id', $userId)
            ->lockForUpdate()
            ->first();

        if ($sequenceRow === null) {
            $sequenceRow = SyncSequence::query()->create([
                'user_id' => $userId,
                'last_sequence' => 0,
            ]);
        }

        $nextSequence = $sequenceRow->last_sequence + 1;
        $this->appendSyncChange($userId, $sequenceRow->last_sequence, $entityType, $entityId, $operation, $entityVersion, now()->utc());
        $sequenceRow->update(['last_sequence' => $nextSequence]);

        return $nextSequence;
    }

    private function appendSyncChange(
        string $userId,
        int $currentSequence,
        string $entityType,
        string $entityId,
        string $operation,
        int $entityVersion,
        \DateTimeInterface $createdAt
    ): int {
        $nextSequence = $currentSequence + 1;

        SyncChange::query()->create([
            'user_id' => $userId,
            'sequence' => $nextSequence,
            'entity_type' => $entityType,
            'entity_id' => $entityId,
            'operation' => $operation,
            'entity_version' => $entityVersion,
            'created_at' => $createdAt,
        ]);

        return $nextSequence;
    }
}


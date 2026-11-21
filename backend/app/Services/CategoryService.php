<?php

namespace App\Services;

use App\Exceptions\EntityConflictException;
use App\Exceptions\FinancialValidationException;
use App\Exceptions\OwnershipViolationException;
use App\Models\BudgetCategory;
use App\Models\Category;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Support\Str;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

/**
 * Manages user income and expense categories with soft deactivation support.
 */
class CategoryService
{
    private const VALID_TYPES = ['income', 'expense'];

    public function __construct(
        private readonly LedgerService $ledgerService,
        private readonly UserBootstrapService $syncRecorder,
    ) {}

    /**
     * @param  array<string, mixed>  $data
     */
    public function createCategory(User $user, array $data): Category
    {
        $type = $data['type'] ?? '';
        if (! in_array($type, self::VALID_TYPES, true)) {
            throw new FinancialValidationException(
                'Invalid category type.',
                ['type' => ['Category type must be either income or expense.']]
            );
        }

        $name = trim((string) ($data['name'] ?? ''));
        if ($name === '') {
            throw new FinancialValidationException(
                'Category name is required.',
                ['name' => ['Category name is required.']]
            );
        }

        return $this->ledgerService->executeAtomically(function () use ($user, $data, $name, $type) {
            $categoryId = (string) ($data['id'] ?? Str::uuid());

            if (Category::withTrashed()->where('id', $categoryId)->exists()) {
                throw new EntityConflictException('Category ID already exists.');
            }

            $icon = isset($data['icon'])
                ? trim(explode('|', (string) $data['icon'])[0])
                : null;
            if ($icon === '') {
                $icon = null;
            } elseif ($icon !== null) {
                $icon = substr($icon, 0, 50);
            }

            $category = Category::query()->create([
                'id' => $categoryId,
                'user_id' => $user->id,
                'name' => $name,
                'type' => $type,
                'icon' => $icon,
                'color' => $data['color'] ?? null,
                'is_default' => false,
                'is_active' => array_key_exists('is_active', $data) ? (bool) $data['is_active'] : true,
                'sort_order' => (int) ($data['sort_order'] ?? 0),
                'version' => 1,
            ]);

            $this->syncRecorder->recordSyncChange($user->id, 'categories', $category->id, 'create', 1);

            return $category->fresh();
        });
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function updateCategory(User $user, string $categoryId, array $data, ?int $baseVersion = null): Category
    {
        return $this->ledgerService->executeAtomically(function () use ($user, $categoryId, $data, $baseVersion) {
            $category = $this->findAndLockOwnedCategory($user->id, $categoryId);

            if ($baseVersion !== null && $category->version !== $baseVersion) {
                throw new EntityConflictException('Category version conflict detected.', [
                    'entity_type' => 'categories',
                    'entity_id' => $category->id,
                    'server_version' => $category->version,
                    'base_version' => $baseVersion,
                ]);
            }

            if (array_key_exists('type', $data) && $data['type'] !== $category->type) {
                if (! in_array($data['type'], self::VALID_TYPES, true)) {
                    throw new FinancialValidationException(
                        'Invalid category type.',
                        ['type' => ['Category type must be either income or expense.']]
                    );
                }

                $isReferenced = Transaction::query()->where('category_id', $category->id)->exists()
                    || BudgetCategory::query()->where('category_id', $category->id)->exists();

                if ($isReferenced) {
                    throw new FinancialValidationException(
                        'Category type cannot be changed after it has been referenced by transactions or budgets.',
                        ['type' => ['Category type is locked because it is already referenced.']]
                    );
                }
            }

            $updatable = array_intersect_key($data, array_flip([
                'name',
                'type',
                'icon',
                'color',
                'sort_order',
                'is_active',
            ]));

            if (array_key_exists('icon', $updatable)) {
                $cleanIcon = $updatable['icon'] !== null
                    ? trim(explode('|', (string) $updatable['icon'])[0])
                    : null;
                $updatable['icon'] = ($cleanIcon === null || $cleanIcon === '')
                    ? null
                    : substr($cleanIcon, 0, 50);
            }

            if (array_key_exists('is_active', $updatable)) {
                $updatable['is_active'] = (bool) $updatable['is_active'];
            }

            if (isset($updatable['name'])) {
                $updatable['name'] = trim((string) $updatable['name']);
                if ($updatable['name'] === '') {
                    throw new FinancialValidationException(
                        'Category name cannot be empty.',
                        ['name' => ['Category name cannot be empty.']]
                    );
                }
            }

            $category->fill($updatable);
            $category->version = $category->version + 1;
            $category->save();

            $this->syncRecorder->recordSyncChange($user->id, 'categories', $category->id, 'update', $category->version);

            return $category->fresh();
        });
    }

    public function archiveCategory(User $user, string $categoryId, ?int $baseVersion = null): Category
    {
        return $this->setCategoryActiveState($user, $categoryId, false, $baseVersion);
    }

    public function restoreCategory(User $user, string $categoryId, ?int $baseVersion = null): Category
    {
        return $this->setCategoryActiveState($user, $categoryId, true, $baseVersion);
    }

    private function setCategoryActiveState(User $user, string $categoryId, bool $active, ?int $baseVersion): Category
    {
        return $this->ledgerService->executeAtomically(function () use ($user, $categoryId, $active, $baseVersion) {
            $category = $this->findAndLockOwnedCategory($user->id, $categoryId);

            if ($baseVersion !== null && $category->version !== $baseVersion) {
                throw new EntityConflictException('Category version conflict detected.', [
                    'entity_type' => 'categories',
                    'entity_id' => $category->id,
                    'server_version' => $category->version,
                    'base_version' => $baseVersion,
                ]);
            }

            $category->is_active = $active;
            $category->version = $category->version + 1;
            $category->save();

            $this->syncRecorder->recordSyncChange($user->id, 'categories', $category->id, 'update', $category->version);

            return $category->fresh();
        });
    }

    private function findAndLockOwnedCategory(string $userId, string $categoryId): Category
    {
        $category = Category::query()->where('id', $categoryId)->lockForUpdate()->first();
        if ($category === null) {
            throw new NotFoundHttpException('Category not found.');
        }

        if ($category->user_id !== $userId) {
            throw new OwnershipViolationException('You do not have access to this category.');
        }

        return $category;
    }
}


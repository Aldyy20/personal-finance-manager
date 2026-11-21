<?php

namespace App\Services;

use App\Exceptions\EntityConflictException;
use App\Exceptions\FinancialValidationException;
use App\Exceptions\OwnershipViolationException;
use App\Models\Budget;
use App\Models\BudgetCategory;
use App\Models\Category;
use App\Models\Transaction;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Str;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

/**
 * Manages monthly budgets, expense category allocations, and utilization calculations.
 */
class BudgetService
{
    public function __construct(
        private readonly LedgerService $ledgerService,
        private readonly UserBootstrapService $syncRecorder,
    ) {}

    /**
     * @param  array<string, mixed>  $data
     */
    public function createBudget(User $user, array $data): Budget
    {
        $name = trim((string) ($data['name'] ?? ''));
        if ($name === '') {
            throw new FinancialValidationException(
                'Budget name is required.',
                ['name' => ['Budget name is required.']]
            );
        }

        $startDate = (string) ($data['start_date'] ?? '');
        $endDate = (string) ($data['end_date'] ?? '');
        $this->validateDateRange($startDate, $endDate);

        $warningPercent = (int) ($data['warning_percent'] ?? 80);
        if ($warningPercent < 1 || $warningPercent > 100) {
            throw new FinancialValidationException(
                'Warning percent must be between 1 and 100.',
                ['warning_percent' => ['Warning percent must be between 1 and 100.']]
            );
        }

        $totalLimit = isset($data['total_limit']) ? (int) $data['total_limit'] : null;
        if ($totalLimit !== null && $totalLimit <= 0) {
            throw new FinancialValidationException(
                'Total budget limit must be greater than zero.',
                ['total_limit' => ['Total limit must be greater than zero.']]
            );
        }

        $periodType = (string) ($data['period_type'] ?? 'monthly');
        if (! in_array($periodType, ['monthly', 'custom', 'weekly'], true)) {
            throw new FinancialValidationException(
                'Budget period_type must be monthly, custom, or weekly.',
                ['period_type' => ['Invalid budget period type.']]
            );
        }

        $isActive = array_key_exists('is_active', $data) ? (bool) $data['is_active'] : true;

        return $this->ledgerService->executeAtomically(function () use ($user, $data, $name, $periodType, $startDate, $endDate, $warningPercent, $totalLimit, $isActive) {
            $budgetId = (string) ($data['id'] ?? Str::uuid());
            if (Budget::withTrashed()->where('id', $budgetId)->exists()) {
                throw new EntityConflictException('Budget ID already exists.');
            }

            $budget = Budget::query()->create([
                'id' => $budgetId,
                'user_id' => $user->id,
                'name' => $name,
                'period_type' => $periodType,
                'start_date' => $startDate,
                'end_date' => $endDate,
                'total_limit' => $totalLimit,
                'warning_percent' => $warningPercent,
                'is_active' => $isActive,
                'version' => 1,
            ]);

            $this->syncRecorder->recordSyncChange($user->id, 'budgets', $budget->id, 'create', 1);

            if (! empty($data['categories']) && is_array($data['categories'])) {
                $this->syncAllocations($user, $budget, $data['categories']);
            }

            return $budget->fresh(['budgetCategories.category']);
        });
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function updateBudget(
        User $user,
        string $budgetId,
        array $data,
        ?int $baseVersion = null
    ): Budget {
        return $this->ledgerService->executeAtomically(function () use ($user, $budgetId, $data, $baseVersion) {
            $budget = $this->findAndLockOwnedBudget($user->id, $budgetId);

            if ($baseVersion !== null && $budget->version !== $baseVersion) {
                throw new EntityConflictException('Budget version conflict detected.', [
                    'entity_type' => 'budgets',
                    'entity_id' => $budget->id,
                    'server_version' => $budget->version,
                    'base_version' => $baseVersion,
                ]);
            }

            $startDate = (string) ($data['start_date'] ?? $budget->start_date->format('Y-m-d'));
            $endDate = (string) ($data['end_date'] ?? $budget->end_date->format('Y-m-d'));
            $this->validateDateRange($startDate, $endDate);

            if (array_key_exists('total_limit', $data) && $data['total_limit'] !== null && (int) $data['total_limit'] <= 0) {
                throw new FinancialValidationException(
                    'Total budget limit must be greater than zero.',
                    ['total_limit' => ['Total limit must be greater than zero.']]
                );
            }

            if (array_key_exists('warning_percent', $data)) {
                $wp = (int) $data['warning_percent'];
                if ($wp < 1 || $wp > 100) {
                    throw new FinancialValidationException(
                        'Warning percent must be between 1 and 100.',
                        ['warning_percent' => ['Warning percent must be between 1 and 100.']]
                    );
                }
            }

            if (array_key_exists('period_type', $data) && ! in_array((string) $data['period_type'], ['monthly', 'custom', 'weekly'], true)) {
                throw new FinancialValidationException(
                    'Budget period_type must be monthly, custom, or weekly.',
                    ['period_type' => ['Invalid budget period type.']]
                );
            }

            $updatable = array_intersect_key($data, array_flip([
                'name',
                'period_type',
                'start_date',
                'end_date',
                'total_limit',
                'warning_percent',
                'is_active',
            ]));

            $budget->fill($updatable);
            $budget->version = $budget->version + 1;
            $budget->save();

            $this->syncRecorder->recordSyncChange($user->id, 'budgets', $budget->id, 'update', $budget->version);

            if (array_key_exists('categories', $data) && is_array($data['categories'])) {
                $this->syncAllocations($user, $budget, $data['categories']);
            }

            return $budget->fresh(['budgetCategories.category']);
        });
    }

    public function archiveBudget(User $user, string $budgetId, ?int $baseVersion = null): Budget
    {
        return $this->ledgerService->executeAtomically(function () use ($user, $budgetId, $baseVersion) {
            $budget = $this->findAndLockOwnedBudget($user->id, $budgetId);

            if ($baseVersion !== null && $budget->version !== $baseVersion) {
                throw new EntityConflictException('Budget version conflict detected.', [
                    'entity_type' => 'budgets',
                    'entity_id' => $budget->id,
                    'server_version' => $budget->version,
                    'base_version' => $baseVersion,
                ]);
            }

            $budget->is_active = false;
            $budget->version = $budget->version + 1;
            $budget->save();

            $this->syncRecorder->recordSyncChange($user->id, 'budgets', $budget->id, 'update', $budget->version);

            return $budget->fresh(['budgetCategories.category']);
        });
    }

    public function restoreBudget(User $user, string $budgetId, ?int $baseVersion = null): Budget
    {
        return $this->ledgerService->executeAtomically(function () use ($user, $budgetId, $baseVersion) {
            $budget = $this->findAndLockOwnedBudget($user->id, $budgetId);

            if ($baseVersion !== null && $budget->version !== $baseVersion) {
                throw new EntityConflictException('Budget version conflict detected.', [
                    'entity_type' => 'budgets',
                    'entity_id' => $budget->id,
                    'server_version' => $budget->version,
                    'base_version' => $baseVersion,
                ]);
            }

            $budget->is_active = true;
            $budget->version = $budget->version + 1;
            $budget->save();

            $this->syncRecorder->recordSyncChange($user->id, 'budgets', $budget->id, 'update', $budget->version);

            return $budget->fresh(['budgetCategories.category']);
        });
    }

    /**
     * Computes budget utilization based on posted net expense transactions within the budget date range.
     *
     * @return array<string, mixed>
     */
    public function getBudgetSummary(User $user, string $budgetId): array
    {
        $budget = Budget::query()
            ->with('budgetCategories.category')
            ->find($budgetId);

        if ($budget === null) {
            throw new NotFoundHttpException('Budget not found.');
        }

        if ($budget->user_id !== $user->id) {
            throw new OwnershipViolationException('You do not have access to this budget.');
        }

        $timezone = $user->settings?->timezone ?? 'Asia/Jakarta';
        $startUtc = Carbon::parse($budget->start_date->format('Y-m-d'), $timezone)->startOfDay()->utc();
        $endUtc = Carbon::parse($budget->end_date->format('Y-m-d'), $timezone)->endOfDay()->utc();

        $spendingByCategory = Transaction::query()
            ->where('user_id', $user->id)
            ->where('type', 'expense')
            ->where('status', 'posted')
            ->whereBetween('transaction_date', [$startUtc, $endUtc])
            ->selectRaw('category_id, COALESCE(SUM(amount), 0) as total_spent')
            ->groupBy('category_id')
            ->pluck('total_spent', 'category_id')
            ->map(fn ($v) => (int) $v);

        $totalExpenseInPeriod = (int) $spendingByCategory->sum();

        $categoryBreakdown = $budget->budgetCategories->map(function (BudgetCategory $allocation) use ($spendingByCategory, $budget) {
            $limit = (int) $allocation->amount_limit;
            $used = (int) ($spendingByCategory->get($allocation->category_id) ?? 0);
            $remaining = $limit - $used;
            $percentage = $limit > 0 ? round(($used / $limit) * 100, 2) : 0.0;

            return [
                'id' => $allocation->id,
                'category_id' => $allocation->category_id,
                'category_name' => $allocation->category?->name,
                'category_icon' => $allocation->category?->icon,
                'category_color' => $allocation->category?->color,
                'amount_limit' => $limit,
                'used' => $used,
                'remaining' => $remaining,
                'percentage' => $percentage,
                'status' => $this->resolveThresholdStatus($percentage, $budget->warning_percent),
            ];
        })->values()->all();

        $allocatedUsed = collect($categoryBreakdown)->sum('used');
        $effectiveTotalUsed = $budget->total_limit !== null ? $totalExpenseInPeriod : (int) $allocatedUsed;
        $effectiveTotalLimit = $budget->total_limit !== null
            ? (int) $budget->total_limit
            : (int) $budget->budgetCategories->sum('amount_limit');

        $totalRemaining = $effectiveTotalLimit - $effectiveTotalUsed;
        $totalPercentage = $effectiveTotalLimit > 0
            ? round(($effectiveTotalUsed / $effectiveTotalLimit) * 100, 2)
            : 0.0;

        $startLocal = Carbon::parse($budget->start_date->format('Y-m-d'), $timezone)->startOfDay();
        $endLocal = Carbon::parse($budget->end_date->format('Y-m-d'), $timezone)->startOfDay();
        $daysTotal = max(1, (int) $startLocal->diffInDays($endLocal) + 1);
        $todayLocal = Carbon::now($timezone)->startOfDay();

        if ($todayLocal->lt($startLocal)) {
            $daysElapsed = 1;
            $daysRemaining = $daysTotal;
        } elseif ($todayLocal->gt($endLocal)) {
            $daysElapsed = $daysTotal;
            $daysRemaining = 0;
        } else {
            $daysElapsed = max(1, min($daysTotal, (int) $startLocal->diffInDays($todayLocal) + 1));
            $daysRemaining = max(0, (int) $todayLocal->diffInDays($endLocal));
        }

        $dailyAverageSpent = (int) round($effectiveTotalUsed / max(1, $daysElapsed));
        $dailySafeRemaining = $totalRemaining > 0
            ? (int) round($totalRemaining / max(1, $daysRemaining > 0 ? $daysRemaining : 1))
            : 0;
        $projectedSurplus = max(0, $effectiveTotalLimit - ($dailyAverageSpent * $daysTotal));
        $warningCategoriesCount = collect($categoryBreakdown)
            ->whereIn('status', ['warning', 'exceeded'])
            ->count();

        return [
            'budget' => [
                'id' => $budget->id,
                'name' => $budget->name,
                'period_type' => $budget->period_type,
                'start_date' => $budget->start_date->format('Y-m-d'),
                'end_date' => $budget->end_date->format('Y-m-d'),
                'total_limit' => $budget->total_limit,
                'warning_percent' => $budget->warning_percent,
                'is_active' => $budget->is_active,
                'version' => $budget->version,
            ],
            'summary' => [
                'total_limit' => $effectiveTotalLimit,
                'total_used' => $effectiveTotalUsed,
                'total_remaining' => $totalRemaining,
                'percentage' => $totalPercentage,
                'status' => $this->resolveThresholdStatus($totalPercentage, $budget->warning_percent),
                'days_total' => $daysTotal,
                'days_elapsed' => $daysElapsed,
                'days_remaining' => $daysRemaining,
                'daily_average_spent' => $dailyAverageSpent,
                'daily_safe_remaining' => $dailySafeRemaining,
                'projected_surplus' => $projectedSurplus,
                'warning_categories_count' => $warningCategoriesCount,
            ],
            'categories' => $categoryBreakdown,
        ];
    }

    /**
     * @param  list<array<string, mixed>>  $allocations
     */
    private function syncAllocations(User $user, Budget $budget, array $allocations): void
    {
        $seenCategoryIds = [];

        foreach ($allocations as $item) {
            $categoryId = (string) ($item['category_id'] ?? '');
            $amountLimit = (int) ($item['amount_limit'] ?? 0);

            if ($categoryId === '' || $amountLimit <= 0) {
                throw new FinancialValidationException(
                    'Each budget category must have a valid category_id and positive amount_limit.',
                    ['categories' => ['Invalid category allocation payload.']]
                );
            }

            if (in_array($categoryId, $seenCategoryIds, true)) {
                throw new FinancialValidationException(
                    'Duplicate category in budget allocation.',
                    ['categories' => ['Each expense category can only appear once per budget.']]
                );
            }
            $seenCategoryIds[] = $categoryId;

            $category = Category::query()->find($categoryId);
            if ($category === null) {
                throw new FinancialValidationException(
                    'Category not found.',
                    ['categories' => ["Category {$categoryId} does not exist."]]
                );
            }

            if ($category->user_id !== $user->id) {
                throw new OwnershipViolationException('You do not own the selected budget category.');
            }

            if ($category->type !== 'expense') {
                throw new FinancialValidationException(
                    'Only expense categories can be included in a budget.',
                    ['categories' => ["Category {$category->name} is an income category."]]
                );
            }

            $existing = BudgetCategory::withTrashed()
                ->where('budget_id', $budget->id)
                ->where('category_id', $category->id)
                ->first();

            if ($existing !== null) {
                $existing->deleted_at = null;
                $existing->amount_limit = $amountLimit;
                $existing->version = $existing->version + 1;
                $existing->save();
                $this->syncRecorder->recordSyncChange($user->id, 'budget_categories', $existing->id, 'update', $existing->version);
            } else {
                $bc = BudgetCategory::query()->create([
                    'id' => (string) ($item['id'] ?? Str::uuid()),
                    'user_id' => $user->id,
                    'budget_id' => $budget->id,
                    'category_id' => $category->id,
                    'category_type' => 'expense',
                    'amount_limit' => $amountLimit,
                    'version' => 1,
                ]);
                $this->syncRecorder->recordSyncChange($user->id, 'budget_categories', $bc->id, 'create', 1);
            }
        }

        // Soft-delete allocations omitted from the updated list
        $toRemove = BudgetCategory::query()
            ->where('budget_id', $budget->id)
            ->when($seenCategoryIds !== [], fn ($q) => $q->whereNotIn('category_id', $seenCategoryIds))
            ->get();

        foreach ($toRemove as $removed) {
            $removed->version = $removed->version + 1;
            $removed->save();
            $removed->delete();
            $this->syncRecorder->recordSyncChange($user->id, 'budget_categories', $removed->id, 'delete', $removed->version);
        }
    }

    private function findAndLockOwnedBudget(string $userId, string $budgetId): Budget
    {
        $budget = Budget::query()->where('id', $budgetId)->lockForUpdate()->first();
        if ($budget === null) {
            throw new NotFoundHttpException('Budget not found.');
        }

        if ($budget->user_id !== $userId) {
            throw new OwnershipViolationException('You do not have access to this budget.');
        }

        return $budget;
    }

    private function validateDateRange(string $startDate, string $endDate): void
    {
        if ($startDate === '' || $endDate === '' || $endDate < $startDate) {
            throw new FinancialValidationException(
                'Budget end_date must be on or after start_date.',
                ['end_date' => ['End date must be on or after start date.']]
            );
        }
    }

    private function resolveThresholdStatus(float $percentage, int $warningPercent): string
    {
        if ($percentage >= 100.0) {
            return 'exceeded';
        }
        if ($percentage >= (float) $warningPercent) {
            return 'warning';
        }

        return 'normal';
    }
}

<?php

namespace App\Services;

use App\Http\Resources\Api\V1\TransactionResource;
use App\Models\Account;
use App\Models\AccountMovement;
use App\Models\Budget;
use App\Models\Transaction;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Collection;

/**
 * Generates ledger-consistent financial reports (PRD Section 5.10).
 * Transfers, opening balances, adjustments, and voided transactions are excluded
 * from income and expense totals.
 */
class ReportService
{
    public function __construct(
        private readonly BudgetService $budgetService,
    ) {}

    /**
     * @param  array<string, mixed>  $filters
     * @return array<string, mixed>
     */
    public function getOverview(User $user, array $filters = []): array
    {
        [$startUtc, $endUtc, $periodLabel] = $this->resolveDateRange($user, $filters);

        $activeAccounts = Account::query()
            ->where('user_id', $user->id)
            ->where('is_active', true)
            ->orderBy('name')
            ->get();

        $totalBalance = (int) $activeAccounts->sum('balance_cache');

        $totals = $this->getIncomeAndExpenseTotals($user->id, $startUtc, $endUtc);
        $expenseByCategory = $this->getCategoryTotals($user->id, 'expense', $startUtc, $endUtc);

        $recentTransactions = Transaction::query()
            ->where('user_id', $user->id)
            ->with(['category', 'movements'])
            ->orderByDesc('transaction_date')
            ->limit(10)
            ->get();

        $activeBudgets = Budget::query()
            ->where('user_id', $user->id)
            ->where('is_active', true)
            ->whereDate('end_date', '>=', $startUtc->toDateString())
            ->whereDate('start_date', '<=', $endUtc->toDateString())
            ->get()
            ->map(fn (Budget $b) => $this->budgetService->getBudgetSummary($user, $b->id))
            ->values()
            ->all();

        return [
            'period' => $periodLabel,
            'start_date' => $startUtc->toIso8601ZuluString('millisecond'),
            'end_date' => $endUtc->toIso8601ZuluString('millisecond'),
            'total_balance' => $totalBalance,
            'total_income' => $totals['income'],
            'total_expense' => $totals['expense'],
            'net_cash_flow' => $totals['income'] - $totals['expense'],
            'accounts_summary' => $activeAccounts->map(fn (Account $a) => [
                'id' => $a->id,
                'name' => $a->name,
                'account_type' => $a->account_type,
                'balance' => $a->balance_cache,
                'icon' => $a->icon,
                'color' => $a->color,
            ])->values()->all(),
            'expense_by_category' => $expenseByCategory,
            'recent_transactions' => TransactionResource::collection($recentTransactions)->resolve(),
            'budgets_summary' => $activeBudgets,
        ];
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return array<string, mixed>
     */
    public function getIncomeReport(User $user, array $filters = []): array
    {
        return $this->buildTypeReport($user, 'income', $filters);
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return array<string, mixed>
     */
    public function getExpenseReport(User $user, array $filters = []): array
    {
        return $this->buildTypeReport($user, 'expense', $filters);
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return array<string, mixed>
     */
    public function getCashFlowReport(User $user, array $filters = []): array
    {
        [$startUtc, $endUtc, $periodLabel] = $this->resolveDateRange($user, $filters);
        $totals = $this->getIncomeAndExpenseTotals($user->id, $startUtc, $endUtc);

        $dailyRows = Transaction::query()
            ->where('user_id', $user->id)
            ->where('status', 'posted')
            ->whereIn('type', ['income', 'expense'])
            ->whereBetween('transaction_date', [$startUtc, $endUtc])
            ->selectRaw("DATE(transaction_date) as tx_day, type, COALESCE(SUM(amount), 0) as total")
            ->groupBy('tx_day', 'type')
            ->orderBy('tx_day')
            ->get();

        $series = [];
        foreach ($dailyRows as $row) {
            $day = (string) $row->tx_day;
            if (! isset($series[$day])) {
                $series[$day] = ['date' => $day, 'income' => 0, 'expense' => 0, 'net' => 0];
            }
            $series[$day][$row->type] = (int) $row->total;
            $series[$day]['net'] = $series[$day]['income'] - $series[$day]['expense'];
        }

        return [
            'period' => $periodLabel,
            'total_income' => $totals['income'],
            'total_expense' => $totals['expense'],
            'net_cash_flow' => $totals['income'] - $totals['expense'],
            'daily_series' => array_values($series),
        ];
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return array<string, mixed>
     */
    public function getCategoryReport(User $user, array $filters = []): array
    {
        [$startUtc, $endUtc, $periodLabel] = $this->resolveDateRange($user, $filters);
        $type = in_array(($filters['type'] ?? ''), ['income', 'expense'], true)
            ? (string) $filters['type']
            : null;

        return [
            'period' => $periodLabel,
            'income' => ($type === null || $type === 'income')
                ? $this->getCategoryTotals($user->id, 'income', $startUtc, $endUtc)
                : [],
            'expense' => ($type === null || $type === 'expense')
                ? $this->getCategoryTotals($user->id, 'expense', $startUtc, $endUtc)
                : [],
        ];
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return array<string, mixed>
     */
    public function getAccountReport(User $user, array $filters = []): array
    {
        [$startUtc, $endUtc, $periodLabel] = $this->resolveDateRange($user, $filters);

        $accounts = Account::query()
            ->where('user_id', $user->id)
            ->orderBy('name')
            ->get();

        $movementsInPeriod = AccountMovement::query()
            ->where('user_id', $user->id)
            ->whereBetween('created_at', [$startUtc, $endUtc])
            ->selectRaw('account_id, COALESCE(SUM(CASE WHEN amount_signed > 0 THEN amount_signed ELSE 0 END), 0) as total_inflow, COALESCE(SUM(CASE WHEN amount_signed < 0 THEN ABS(amount_signed) ELSE 0 END), 0) as total_outflow, COALESCE(SUM(amount_signed), 0) as net_change')
            ->groupBy('account_id')
            ->get()
            ->keyBy('account_id');

        $report = $accounts->map(function (Account $account) use ($movementsInPeriod) {
            $m = $movementsInPeriod->get($account->id);

            return [
                'id' => $account->id,
                'name' => $account->name,
                'account_type' => $account->account_type,
                'is_active' => $account->is_active,
                'current_balance' => $account->balance_cache,
                'period_inflow' => (int) ($m->total_inflow ?? 0),
                'period_outflow' => (int) ($m->total_outflow ?? 0),
                'period_net_change' => (int) ($m->net_change ?? 0),
            ];
        })->values()->all();

        return [
            'period' => $periodLabel,
            'total_active_balance' => (int) $accounts->where('is_active', true)->sum('balance_cache'),
            'accounts' => $report,
        ];
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return array<string, mixed>
     */
    public function getBudgetReport(User $user, array $filters = []): array
    {
        $budgets = Budget::query()
            ->where('user_id', $user->id)
            ->when(isset($filters['active_only']) && $filters['active_only'], fn ($q) => $q->where('is_active', true))
            ->orderByDesc('start_date')
            ->get();

        return [
            'budgets' => $budgets->map(
                fn (Budget $b) => $this->budgetService->getBudgetSummary($user, $b->id)
            )->values()->all(),
        ];
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return array<string, mixed>
     */
    public function getMonthlyComparisonReport(User $user, array $filters = []): array
    {
        $monthsCount = max(1, min(24, (int) ($filters['months'] ?? 6)));
        $timezone = $user->settings?->timezone ?? 'Asia/Jakarta';
        $endLocal = Carbon::now($timezone)->endOfMonth();
        $startLocal = $endLocal->copy()->subMonths($monthsCount - 1)->startOfMonth();

        $rows = Transaction::query()
            ->where('user_id', $user->id)
            ->where('status', 'posted')
            ->whereIn('type', ['income', 'expense'])
            ->whereBetween('transaction_date', [$startLocal->copy()->utc(), $endLocal->copy()->utc()])
            ->selectRaw("DATE_FORMAT(transaction_date, '%Y-%m') as month_key, type, COALESCE(SUM(amount), 0) as total")
            ->groupBy('month_key', 'type')
            ->orderBy('month_key')
            ->get();

        $byMonth = [];
        for ($i = 0; $i < $monthsCount; $i++) {
            $m = $startLocal->copy()->addMonths($i)->format('Y-m');
            $byMonth[$m] = ['month' => $m, 'income' => 0, 'expense' => 0, 'net' => 0];
        }

        foreach ($rows as $row) {
            $key = (string) $row->month_key;
            if (isset($byMonth[$key])) {
                $byMonth[$key][$row->type] = (int) $row->total;
                $byMonth[$key]['net'] = $byMonth[$key]['income'] - $byMonth[$key]['expense'];
            }
        }

        return [
            'months' => $monthsCount,
            'series' => array_values($byMonth),
        ];
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return array<string, mixed>
     */
    private function buildTypeReport(User $user, string $type, array $filters): array
    {
        [$startUtc, $endUtc, $periodLabel] = $this->resolveDateRange($user, $filters);

        $categories = $this->getCategoryTotals($user->id, $type, $startUtc, $endUtc);
        $total = (int) collect($categories)->sum('total');

        return [
            'period' => $periodLabel,
            'type' => $type,
            'total' => $total,
            'categories' => $categories,
        ];
    }

    /**
     * @return array{income: int, expense: int}
     */
    private function getIncomeAndExpenseTotals(string $userId, Carbon $startUtc, Carbon $endUtc): array
    {
        $rows = Transaction::query()
            ->where('user_id', $userId)
            ->where('status', 'posted')
            ->whereIn('type', ['income', 'expense'])
            ->whereBetween('transaction_date', [$startUtc, $endUtc])
            ->selectRaw('type, COALESCE(SUM(amount), 0) as total')
            ->groupBy('type')
            ->pluck('total', 'type');

        return [
            'income' => (int) ($rows->get('income') ?? 0),
            'expense' => (int) ($rows->get('expense') ?? 0),
        ];
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function getCategoryTotals(string $userId, string $type, Carbon $startUtc, Carbon $endUtc): array
    {
        $rows = Transaction::query()
            ->join('categories', 'transactions.category_id', '=', 'categories.id')
            ->where('transactions.user_id', $userId)
            ->where('transactions.type', $type)
            ->where('transactions.status', 'posted')
            ->whereBetween('transactions.transaction_date', [$startUtc, $endUtc])
            ->selectRaw('categories.id as category_id, categories.name, categories.icon, categories.color, COALESCE(SUM(transactions.amount), 0) as total, COUNT(transactions.id) as transaction_count')
            ->groupBy('categories.id', 'categories.name', 'categories.icon', 'categories.color')
            ->orderByDesc('total')
            ->get();

        $grandTotal = (int) $rows->sum('total');

        return $rows->map(function ($row) use ($grandTotal) {
            $total = (int) $row->total;

            return [
                'category_id' => $row->category_id,
                'name' => $row->name,
                'icon' => $row->icon,
                'color' => $row->color,
                'total' => $total,
                'transaction_count' => (int) $row->transaction_count,
                'percentage' => $grandTotal > 0 ? round(($total / $grandTotal) * 100, 2) : 0.0,
            ];
        })->values()->all();
    }

    /**
     * @param  array<string, mixed>  $filters
     * @return array{0: Carbon, 1: Carbon, 2: string}
     */
    private function resolveDateRange(User $user, array $filters): array
    {
        $timezone = $user->settings?->timezone ?? 'Asia/Jakarta';
        $now = Carbon::now($timezone);

        if (! empty($filters['start_date']) && ! empty($filters['end_date'])) {
            $start = Carbon::parse((string) $filters['start_date'], $timezone)->startOfDay()->utc();
            $end = Carbon::parse((string) $filters['end_date'], $timezone)->endOfDay()->utc();

            return [$start, $end, 'custom'];
        }

        $period = (string) ($filters['period'] ?? 'this_month');

        return match ($period) {
            'today' => [$now->copy()->startOfDay()->utc(), $now->copy()->endOfDay()->utc(), 'today'],
            'this_week' => [$now->copy()->startOfWeek()->utc(), $now->copy()->endOfWeek()->utc(), 'this_week'],
            'previous_month' => [
                $now->copy()->subMonthNoOverflow()->startOfMonth()->utc(),
                $now->copy()->subMonthNoOverflow()->endOfMonth()->utc(),
                'previous_month',
            ],
            'this_year' => [$now->copy()->startOfYear()->utc(), $now->copy()->endOfYear()->utc(), 'this_year'],
            default => [$now->copy()->startOfMonth()->utc(), $now->copy()->endOfMonth()->utc(), 'this_month'],
        };
    }
}


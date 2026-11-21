<?php

namespace App\Http\Controllers\Api\V1;

use App\Services\ReportService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReportController extends ApiController
{
    public function __construct(
        private readonly ReportService $reportService,
    ) {}

    public function overview(Request $request): JsonResponse
    {
        return $this->success(
            data: $this->reportService->getOverview($request->user(), $request->query()),
            message: 'Financial overview retrieved',
        );
    }

    public function income(Request $request): JsonResponse
    {
        return $this->success(
            data: $this->reportService->getIncomeReport($request->user(), $request->query()),
            message: 'Income report retrieved',
        );
    }

    public function expense(Request $request): JsonResponse
    {
        return $this->success(
            data: $this->reportService->getExpenseReport($request->user(), $request->query()),
            message: 'Expense report retrieved',
        );
    }

    public function cashFlow(Request $request): JsonResponse
    {
        return $this->success(
            data: $this->reportService->getCashFlowReport($request->user(), $request->query()),
            message: 'Cash flow report retrieved',
        );
    }

    public function categories(Request $request): JsonResponse
    {
        return $this->success(
            data: $this->reportService->getCategoryReport($request->user(), $request->query()),
            message: 'Category analysis report retrieved',
        );
    }

    public function accounts(Request $request): JsonResponse
    {
        return $this->success(
            data: $this->reportService->getAccountReport($request->user(), $request->query()),
            message: 'Account report retrieved',
        );
    }

    public function budgets(Request $request): JsonResponse
    {
        return $this->success(
            data: $this->reportService->getBudgetReport($request->user(), $request->query()),
            message: 'Budget report retrieved',
        );
    }

    public function monthlyComparison(Request $request): JsonResponse
    {
        return $this->success(
            data: $this->reportService->getMonthlyComparisonReport($request->user(), $request->query()),
            message: 'Monthly comparison report retrieved',
        );
    }
}


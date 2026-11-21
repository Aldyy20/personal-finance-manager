<?php

namespace App\Http\Controllers\Api\V1;

use App\Exceptions\OwnershipViolationException;
use App\Http\Requests\Api\V1\Budget\StoreBudgetRequest;
use App\Http\Requests\Api\V1\Budget\UpdateBudgetRequest;
use App\Http\Resources\Api\V1\BudgetResource;
use App\Models\Budget;
use App\Services\BudgetService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class BudgetController extends ApiController
{
    public function __construct(
        private readonly BudgetService $budgetService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $query = Budget::query()
            ->where('user_id', $request->user()->id)
            ->with('budgetCategories.category')
            ->orderByDesc('start_date');

        if ($request->has('is_active')) {
            $query->where('is_active', filter_var($request->query('is_active'), FILTER_VALIDATE_BOOLEAN));
        }

        return $this->success(
            data: BudgetResource::collection($query->get()),
            message: 'Budgets retrieved',
        );
    }

    public function store(StoreBudgetRequest $request): JsonResponse
    {
        $budget = $this->budgetService->createBudget($request->user(), $request->validated());

        return $this->success(
            data: new BudgetResource($budget),
            message: 'Budget created',
            status: 201,
        );
    }

    public function show(Request $request, string $id): JsonResponse
    {
        $budget = Budget::query()->with('budgetCategories.category')->find($id);
        if ($budget === null) {
            throw new NotFoundHttpException('Budget not found.');
        }

        if ($budget->user_id !== $request->user()->id) {
            throw new OwnershipViolationException('You do not have access to this budget.');
        }

        return $this->success(
            data: new BudgetResource($budget),
            message: 'Budget retrieved',
        );
    }

    public function update(UpdateBudgetRequest $request, string $id): JsonResponse
    {
        $validated = $request->validated();
        $baseVersion = isset($validated['base_version']) ? (int) $validated['base_version'] : null;

        $budget = $this->budgetService->updateBudget($request->user(), $id, $validated, $baseVersion);

        return $this->success(
            data: new BudgetResource($budget),
            message: 'Budget updated',
        );
    }

    public function archive(Request $request, string $id): JsonResponse
    {
        $baseVersion = $request->filled('base_version') ? (int) $request->input('base_version') : null;
        $budget = $this->budgetService->archiveBudget($request->user(), $id, $baseVersion);

        return $this->success(
            data: new BudgetResource($budget),
            message: 'Budget archived',
        );
    }

    public function summary(Request $request, string $id): JsonResponse
    {
        $summary = $this->budgetService->getBudgetSummary($request->user(), $id);

        return $this->success(
            data: $summary,
            message: 'Budget summary retrieved',
        );
    }
}


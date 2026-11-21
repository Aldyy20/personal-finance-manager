<?php

namespace App\Http\Controllers\Api\V1;

use App\Exceptions\OwnershipViolationException;
use App\Http\Requests\Api\V1\Category\StoreCategoryRequest;
use App\Http\Requests\Api\V1\Category\UpdateCategoryRequest;
use App\Http\Resources\Api\V1\CategoryResource;
use App\Models\Category;
use App\Services\CategoryService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class CategoryController extends ApiController
{
    public function __construct(
        private readonly CategoryService $categoryService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $query = Category::query()
            ->where('user_id', $request->user()->id)
            ->orderBy('type')
            ->orderBy('sort_order')
            ->orderBy('name');

        if ($request->filled('type')) {
            $query->where('type', (string) $request->query('type'));
        }

        if ($request->has('is_active')) {
            $query->where('is_active', filter_var($request->query('is_active'), FILTER_VALIDATE_BOOLEAN));
        }

        return $this->success(
            data: CategoryResource::collection($query->get()),
            message: 'Categories retrieved',
        );
    }

    public function store(StoreCategoryRequest $request): JsonResponse
    {
        $category = $this->categoryService->createCategory($request->user(), $request->validated());

        return $this->success(
            data: new CategoryResource($category),
            message: 'Category created',
            status: 201,
        );
    }

    public function show(Request $request, string $id): JsonResponse
    {
        $category = Category::query()->find($id);
        if ($category === null) {
            throw new NotFoundHttpException('Category not found.');
        }

        if ($category->user_id !== $request->user()->id) {
            throw new OwnershipViolationException('You do not have access to this category.');
        }

        return $this->success(
            data: new CategoryResource($category),
            message: 'Category retrieved',
        );
    }

    public function update(UpdateCategoryRequest $request, string $id): JsonResponse
    {
        $validated = $request->validated();
        $baseVersion = isset($validated['base_version']) ? (int) $validated['base_version'] : null;

        $category = $this->categoryService->updateCategory($request->user(), $id, $validated, $baseVersion);

        return $this->success(
            data: new CategoryResource($category),
            message: 'Category updated',
        );
    }

    public function archive(Request $request, string $id): JsonResponse
    {
        $baseVersion = $request->filled('base_version') ? (int) $request->input('base_version') : null;
        $category = $this->categoryService->archiveCategory($request->user(), $id, $baseVersion);

        return $this->success(
            data: new CategoryResource($category),
            message: 'Category disabled',
        );
    }

    public function restore(Request $request, string $id): JsonResponse
    {
        $baseVersion = $request->filled('base_version') ? (int) $request->input('base_version') : null;
        $category = $this->categoryService->restoreCategory($request->user(), $id, $baseVersion);

        return $this->success(
            data: new CategoryResource($category),
            message: 'Category restored',
        );
    }
}


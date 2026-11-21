<?php

namespace App\Http\Controllers\Api\V1;

use App\Exceptions\OwnershipViolationException;
use App\Http\Requests\Api\V1\Transaction\StoreTransactionRequest;
use App\Http\Requests\Api\V1\Transaction\UpdateTransactionRequest;
use App\Http\Resources\Api\V1\TransactionResource;
use App\Http\Resources\Api\V1\TransactionRevisionResource;
use App\Models\Transaction;
use App\Services\TransactionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class TransactionController extends ApiController
{
    public function __construct(
        private readonly TransactionService $transactionService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $query = Transaction::query()
            ->where('user_id', $request->user()->id)
            ->with(['category', 'movements']);

        if ($request->filled('type')) {
            $query->where('type', (string) $request->query('type'));
        }

        if ($request->filled('status')) {
            $query->where('status', (string) $request->query('status'));
        }

        if ($request->filled('category_id')) {
            $query->where('category_id', (string) $request->query('category_id'));
        }

        if ($request->filled('account_id')) {
            $accountId = (string) $request->query('account_id');
            $query->whereHas('movements', fn ($q) => $q->where('account_id', $accountId));
        }

        if ($request->filled('start_date')) {
            $query->where('transaction_date', '>=', (string) $request->query('start_date'));
        }

        if ($request->filled('end_date')) {
            $query->where('transaction_date', '<=', (string) $request->query('end_date'));
        }

        if ($request->filled('search')) {
            $search = '%'.str_replace(['%', '_'], ['\\%', '\\_'], (string) $request->query('search')).'%';
            $query->where(function ($q) use ($search) {
                $q->where('description', 'like', $search)
                    ->orWhere('notes', 'like', $search);
            });
        }

        $sortBy = in_array($request->query('sort_by'), ['transaction_date', 'amount', 'created_at'], true)
            ? (string) $request->query('sort_by')
            : 'transaction_date';
        $sortDir = strtolower((string) $request->query('sort_dir', 'desc')) === 'asc' ? 'asc' : 'desc';

        $perPage = max(1, min(100, (int) $request->query('per_page', 20)));
        $paginated = $query->orderBy($sortBy, $sortDir)->paginate($perPage);

        return $this->success(
            data: TransactionResource::collection($paginated->items()),
            message: 'Transactions retrieved',
            meta: [
                'current_page' => $paginated->currentPage(),
                'per_page' => $paginated->perPage(),
                'total' => $paginated->total(),
                'last_page' => $paginated->lastPage(),
            ],
        );
    }

    public function store(StoreTransactionRequest $request): JsonResponse
    {
        $transaction = $this->transactionService->createTransaction($request->user(), $request->validated());

        return $this->success(
            data: new TransactionResource($transaction),
            message: 'Transaction created',
            status: 201,
        );
    }

    public function show(Request $request, string $id): JsonResponse
    {
        $transaction = $this->findOwnedTransaction($request, $id);
        $transaction->load(['category', 'movements']);

        return $this->success(
            data: new TransactionResource($transaction),
            message: 'Transaction retrieved',
        );
    }

    public function update(UpdateTransactionRequest $request, string $id): JsonResponse
    {
        $validated = $request->validated();
        $baseVersion = isset($validated['base_version']) ? (int) $validated['base_version'] : null;

        $transaction = $this->transactionService->updateTransaction(
            $request->user(),
            $id,
            $validated,
            $baseVersion
        );

        return $this->success(
            data: new TransactionResource($transaction),
            message: 'Transaction updated',
        );
    }

    public function void(Request $request, string $id): JsonResponse
    {
        $validated = $request->validate([
            'reason' => ['nullable', 'string', 'max:255'],
            'device_id' => ['nullable', 'uuid'],
            'base_version' => ['nullable', 'integer', 'min:1'],
        ]);

        $transaction = $this->transactionService->voidTransaction(
            $request->user(),
            $id,
            $validated['reason'] ?? null,
            $validated['device_id'] ?? null,
            isset($validated['base_version']) ? (int) $validated['base_version'] : null
        );

        return $this->success(
            data: new TransactionResource($transaction),
            message: 'Transaction voided',
        );
    }

    public function revisions(Request $request, string $id): JsonResponse
    {
        $transaction = $this->findOwnedTransaction($request, $id);
        $revisions = $transaction->revisions()->orderBy('revision_number')->get();

        return $this->success(
            data: TransactionRevisionResource::collection($revisions),
            message: 'Transaction revisions retrieved',
        );
    }

    private function findOwnedTransaction(Request $request, string $id): Transaction
    {
        $transaction = Transaction::query()->find($id);
        if ($transaction === null) {
            throw new NotFoundHttpException('Transaction not found.');
        }

        if ($transaction->user_id !== $request->user()->id) {
            throw new OwnershipViolationException('You do not have access to this transaction.');
        }

        return $transaction;
    }
}


<?php

namespace App\Http\Controllers\Api\V1;

use App\Exceptions\OwnershipViolationException;
use App\Http\Requests\Api\V1\Transfer\StoreTransferRequest;
use App\Http\Requests\Api\V1\Transfer\UpdateTransferRequest;
use App\Http\Resources\Api\V1\TransactionResource;
use App\Models\Transaction;
use App\Services\TransferService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class TransferController extends ApiController
{
    public function __construct(
        private readonly TransferService $transferService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $perPage = max(1, min(100, (int) $request->query('per_page', 20)));

        $transfers = Transaction::query()
            ->where('user_id', $request->user()->id)
            ->where('type', 'transfer')
            ->with('movements')
            ->orderByDesc('transaction_date')
            ->paginate($perPage);

        return $this->success(
            data: TransactionResource::collection($transfers->items()),
            message: 'Transfers retrieved',
            meta: [
                'current_page' => $transfers->currentPage(),
                'per_page' => $transfers->perPage(),
                'total' => $transfers->total(),
                'last_page' => $transfers->lastPage(),
            ],
        );
    }

    public function store(StoreTransferRequest $request): JsonResponse
    {
        $transfer = $this->transferService->createTransfer($request->user(), $request->validated());

        return $this->success(
            data: new TransactionResource($transfer),
            message: 'Transfer created',
            status: 201,
        );
    }

    public function show(Request $request, string $id): JsonResponse
    {
        $transfer = Transaction::query()->where('type', 'transfer')->find($id);
        if ($transfer === null) {
            throw new NotFoundHttpException('Transfer not found.');
        }

        if ($transfer->user_id !== $request->user()->id) {
            throw new OwnershipViolationException('You do not have access to this transfer.');
        }

        $transfer->load('movements');

        return $this->success(
            data: new TransactionResource($transfer),
            message: 'Transfer retrieved',
        );
    }

    public function update(UpdateTransferRequest $request, string $id): JsonResponse
    {
        $validated = $request->validated();
        $baseVersion = isset($validated['base_version']) ? (int) $validated['base_version'] : null;

        $transfer = $this->transferService->updateTransfer(
            $request->user(),
            $id,
            $validated,
            $baseVersion
        );

        return $this->success(
            data: new TransactionResource($transfer),
            message: 'Transfer updated',
        );
    }

    public function void(Request $request, string $id): JsonResponse
    {
        $validated = $request->validate([
            'reason' => ['nullable', 'string', 'max:255'],
            'device_id' => ['nullable', 'uuid'],
            'base_version' => ['nullable', 'integer', 'min:1'],
        ]);

        $transfer = $this->transferService->voidTransfer(
            $request->user(),
            $id,
            $validated['reason'] ?? null,
            $validated['device_id'] ?? null,
            isset($validated['base_version']) ? (int) $validated['base_version'] : null
        );

        return $this->success(
            data: new TransactionResource($transfer),
            message: 'Transfer voided',
        );
    }
}


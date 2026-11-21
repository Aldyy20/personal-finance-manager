<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Requests\Api\V1\Sync\SyncPushRequest;
use App\Services\SyncService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SyncController extends ApiController
{
    public function __construct(
        private readonly SyncService $syncService,
    ) {}

    public function push(SyncPushRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $result = $this->syncService->push(
            $request->user(),
            (string) $validated['device_id'],
            $validated['operations']
        );

        return $this->success(
            data: $result,
            message: 'Sync push processed',
        );
    }

    public function pull(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'device_id' => ['nullable', 'uuid'],
            'cursor' => ['nullable', 'integer', 'min:0'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:200'],
        ]);

        $result = $this->syncService->pull(
            $request->user(),
            $validated['device_id'] ?? null,
            (int) ($validated['cursor'] ?? 0),
            (int) ($validated['limit'] ?? 100)
        );

        return $this->success(
            data: $result,
            message: 'Changes retrieved',
        );
    }

    public function status(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'device_id' => ['nullable', 'uuid'],
        ]);

        $result = $this->syncService->status(
            $request->user(),
            $validated['device_id'] ?? null
        );

        return $this->success(
            data: $result,
            message: 'Sync status retrieved',
        );
    }
}


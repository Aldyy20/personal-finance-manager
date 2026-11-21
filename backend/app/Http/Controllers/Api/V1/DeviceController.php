<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Requests\Api\V1\Device\RegisterDeviceRequest;
use App\Http\Resources\Api\V1\DeviceResource;
use App\Models\Device;
use App\Services\UserBootstrapService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DeviceController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        $devices = $request->user()
            ->devices()
            ->orderByDesc('created_at')
            ->get();

        return $this->success(
            data: DeviceResource::collection($devices),
            message: 'Devices retrieved',
        );
    }

    public function register(RegisterDeviceRequest $request, UserBootstrapService $bootstrapService): JsonResponse
    {
        $device = $bootstrapService->registerOrUpdateDevice(
            $request->user(),
            $request->validated()
        );

        return $this->success(
            data: new DeviceResource($device),
            message: 'Device registered',
        );
    }

    public function revoke(Request $request, string $id): JsonResponse
    {
        $device = Device::query()->find($id);

        if ($device === null) {
            return $this->error(
                message: 'Device not found',
                code: 'NOT_FOUND',
                status: 404,
            );
        }

        if ($device->user_id !== $request->user()->id) {
            return $this->error(
                message: 'You are not allowed to revoke this device',
                code: 'FORBIDDEN',
                status: 403,
            );
        }

        DB::transaction(function () use ($device, $request) {
            $device->update(['is_active' => false]);
            $request->user()->tokens()->where('name', $device->id)->delete();
        });

        return $this->success(
            data: new DeviceResource($device->fresh()),
            message: 'Device revoked',
        );
    }
}


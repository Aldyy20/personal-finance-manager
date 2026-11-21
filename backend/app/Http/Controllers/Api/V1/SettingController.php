<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Requests\Api\V1\Setting\UpdateSettingsRequest;
use App\Http\Resources\Api\V1\UserSettingResource;
use App\Models\UserSetting;
use App\Services\UserBootstrapService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SettingController extends ApiController
{
    public function show(Request $request): JsonResponse
    {
        $settings = UserSetting::query()
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        return $this->success(
            data: new UserSettingResource($settings),
            message: 'Settings retrieved',
        );
    }

    public function update(UpdateSettingsRequest $request, UserBootstrapService $bootstrapService): JsonResponse
    {
        $validated = $request->validated();
        $user = $request->user();

        $settings = DB::transaction(function () use ($user, $validated, $bootstrapService) {
            $settings = UserSetting::query()
                ->where('user_id', $user->id)
                ->lockForUpdate()
                ->firstOrFail();

            $settings->fill($validated);
            $settings->version = $settings->version + 1;
            $settings->save();

            $bootstrapService->recordSyncChange(
                $user->id,
                'user_settings',
                $settings->id,
                'update',
                $settings->version
            );

            return $settings;
        });

        return $this->success(
            data: new UserSettingResource($settings),
            message: 'Settings updated',
        );
    }
}


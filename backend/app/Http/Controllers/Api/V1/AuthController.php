<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Requests\Api\V1\Auth\LoginRequest;
use App\Http\Requests\Api\V1\Auth\RegisterRequest;
use App\Http\Resources\Api\V1\DeviceResource;
use App\Http\Resources\Api\V1\UserResource;
use App\Http\Resources\Api\V1\UserSettingResource;
use App\Models\SyncCursor;
use App\Models\SyncSequence;
use App\Models\User;
use App\Services\UserBootstrapService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AuthController extends ApiController
{
    public function register(RegisterRequest $request, UserBootstrapService $bootstrapService): JsonResponse
    {
        $validated = $request->validated();
        $email = strtolower(trim($validated['email']));

        $result = DB::transaction(function () use ($validated, $email, $bootstrapService) {
            $user = User::query()->create([
                'name' => trim($validated['name']),
                'email' => $email,
                'password' => $validated['password'],
            ]);

            $bootstrapped = $bootstrapService->bootstrapNewUser(
                $user,
                $validated['device'] ?? null
            );

            $device = $bootstrapped['device'];
            $tokenName = $device?->id ?? 'mobile-client';
            $accessToken = $user->createToken($tokenName)->plainTextToken;

            return [
                'user' => $user,
                'settings' => $bootstrapped['settings'],
                'device' => $device,
                'last_sequence' => $bootstrapped['last_sequence'],
                'access_token' => $accessToken,
            ];
        });

        return $this->success(
            data: [
                'user' => new UserResource($result['user']),
                'settings' => new UserSettingResource($result['settings']),
                'device' => $result['device'] ? new DeviceResource($result['device']) : null,
                'access_token' => $result['access_token'],
                'token_type' => 'Bearer',
                'sync_meta' => [
                    'last_sequence' => $result['last_sequence'],
                    'device_cursor' => $result['device'] ? 0 : null,
                    'server_time' => now()->utc()->toIso8601ZuluString('millisecond'),
                ],
            ],
            message: 'Registration successful',
            status: 201,
        );
    }

    public function login(LoginRequest $request, UserBootstrapService $bootstrapService): JsonResponse
    {
        $validated = $request->validated();
        $email = strtolower(trim($validated['email']));

        $user = User::query()->where('email', $email)->first();

        if ($user === null || ! Hash::check($validated['password'], $user->password)) {
            return $this->error(
                message: 'Invalid email or password',
                code: 'UNAUTHENTICATED',
                status: 401,
            );
        }

        $device = null;
        $deviceCursor = null;

        if (isset($validated['device'])) {
            $device = $bootstrapService->registerOrUpdateDevice($user, $validated['device']);
            $deviceCursor = SyncCursor::query()
                ->where('user_id', $user->id)
                ->where('device_id', $device->id)
                ->value('last_cursor') ?? 0;
        }

        $tokenName = $device?->id ?? 'mobile-client';
        $accessToken = $user->createToken($tokenName)->plainTextToken;
        $lastSequence = SyncSequence::query()
            ->where('user_id', $user->id)
            ->value('last_sequence') ?? 0;

        $user->load('settings');

        return $this->success(
            data: [
                'user' => new UserResource($user),
                'settings' => $user->settings ? new UserSettingResource($user->settings) : null,
                'device' => $device ? new DeviceResource($device) : null,
                'access_token' => $accessToken,
                'token_type' => 'Bearer',
                'sync_meta' => [
                    'last_sequence' => (int) $lastSequence,
                    'device_cursor' => $deviceCursor !== null ? (int) $deviceCursor : null,
                    'server_time' => now()->utc()->toIso8601ZuluString('millisecond'),
                ],
            ],
            message: 'Login successful',
        );
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()?->currentAccessToken()?->delete();

        return $this->success(message: 'Logout successful');
    }

    public function refresh(Request $request): JsonResponse
    {
        $user = $request->user();
        $currentToken = $user?->currentAccessToken();
        $tokenName = $currentToken?->name ?? 'mobile-client';

        $currentToken?->delete();
        $newToken = $user->createToken($tokenName)->plainTextToken;

        return $this->success(
            data: [
                'access_token' => $newToken,
                'token_type' => 'Bearer',
            ],
            message: 'Session refreshed',
        );
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load('settings');

        return $this->success(
            data: [
                'user' => new UserResource($user),
                'settings' => $user->settings ? new UserSettingResource($user->settings) : null,
            ],
            message: 'Authenticated user retrieved',
        );
    }
}


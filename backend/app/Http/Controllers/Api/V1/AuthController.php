<?php

namespace App\Http\Controllers\Api\V1;

use App\Exceptions\FinancialValidationException;
use App\Http\Requests\Api\V1\Auth\LoginRequest;
use App\Http\Requests\Api\V1\Auth\RegisterRequest;
use App\Http\Requests\Api\V1\Auth\ResetPasswordWithOtpRequest;
use App\Http\Requests\Api\V1\Auth\SendPasswordResetOtpRequest;
use App\Http\Requests\Api\V1\Auth\SendRegisterOtpRequest;
use App\Http\Requests\Api\V1\Auth\VerifyPasswordResetOtpRequest;
use App\Http\Resources\Api\V1\DeviceResource;
use App\Http\Resources\Api\V1\UserResource;
use App\Http\Resources\Api\V1\UserSettingResource;
use App\Models\SyncCursor;
use App\Models\SyncSequence;
use App\Models\User;
use App\Services\EmailOtpService;
use App\Services\UserBootstrapService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends ApiController
{
    public function sendRegisterOtp(SendRegisterOtpRequest $request, EmailOtpService $otpService): JsonResponse
    {
        $email = strtolower(trim($request->validated('email')));

        if (User::query()->where('email', $email)->exists()) {
            throw new FinancialValidationException(
                'Email sudah terdaftar. Silakan masuk atau gunakan email lain.',
                ['email' => ['Email sudah terdaftar. Silakan masuk atau gunakan email lain.']]
            );
        }

        $meta = $otpService->sendOtp($email, EmailOtpService::PURPOSE_REGISTER);

        return $this->success(
            data: [
                'email' => $email,
                ...$meta,
            ],
            message: 'Kode OTP telah dikirim ke email Anda.',
        );
    }

    public function register(
        RegisterRequest $request,
        UserBootstrapService $bootstrapService,
        EmailOtpService $otpService,
    ): JsonResponse {
        $validated = $request->validated();
        $email = strtolower(trim($validated['email']));
        $otpCode = trim((string) $validated['otp_code']);

        // Validate OTP before transaction so failed attempts persist outside rollback
        $otpService->verifyOtp($email, EmailOtpService::PURPOSE_REGISTER, $otpCode, consume: false);

        $rawName = trim((string) ($validated['name'] ?? ''));
        if ($rawName === '') {
            $localPart = Str::before($email, '@');
            $derived = trim(Str::headline(str_replace(['.', '_', '-'], ' ', $localPart)));
            $rawName = $derived !== '' ? Str::limit($derived, 100, '') : 'Pengguna';
        }

        $result = DB::transaction(function () use ($validated, $email, $rawName, $otpCode, $bootstrapService, $otpService) {
            $otpService->verifyOtp($email, EmailOtpService::PURPOSE_REGISTER, $otpCode, consume: true);

            $user = User::query()->create([
                'name' => $rawName,
                'email' => $email,
                'email_verified_at' => now(),
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

    public function sendPasswordResetOtp(
        SendPasswordResetOtpRequest $request,
        EmailOtpService $otpService,
    ): JsonResponse {
        $email = strtolower(trim($request->validated('email')));

        if (! User::query()->where('email', $email)->exists()) {
            throw new FinancialValidationException(
                'Email tidak terdaftar.',
                ['email' => ['Email tidak terdaftar pada sistem.']]
            );
        }

        $meta = $otpService->sendOtp($email, EmailOtpService::PURPOSE_PASSWORD_RESET);

        return $this->success(
            data: [
                'email' => $email,
                ...$meta,
            ],
            message: 'Kode OTP reset kata sandi telah dikirim ke email Anda.',
        );
    }

    public function verifyPasswordResetOtp(
        VerifyPasswordResetOtpRequest $request,
        EmailOtpService $otpService,
    ): JsonResponse {
        $validated = $request->validated();
        $email = strtolower(trim($validated['email']));

        if (! User::query()->where('email', $email)->exists()) {
            throw new FinancialValidationException(
                'Email tidak terdaftar.',
                ['email' => ['Email tidak terdaftar pada sistem.']]
            );
        }

        $otpService->verifyOtp(
            $email,
            EmailOtpService::PURPOSE_PASSWORD_RESET,
            trim((string) $validated['otp_code']),
            consume: false,
        );

        return $this->success(
            data: [
                'email' => $email,
                'verified' => true,
            ],
            message: 'Kode OTP terverifikasi.',
        );
    }

    public function resetPasswordWithOtp(
        ResetPasswordWithOtpRequest $request,
        EmailOtpService $otpService,
    ): JsonResponse {
        $validated = $request->validated();
        $email = strtolower(trim($validated['email']));
        $otpCode = trim((string) $validated['otp_code']);

        $user = User::query()->where('email', $email)->first();
        if ($user === null) {
            throw new FinancialValidationException(
                'Email tidak terdaftar.',
                ['email' => ['Email tidak terdaftar pada sistem.']]
            );
        }

        $otpService->verifyOtp($email, EmailOtpService::PURPOSE_PASSWORD_RESET, $otpCode, consume: false);

        DB::transaction(function () use ($user, $email, $otpCode, $validated, $otpService) {
            $otpService->verifyOtp($email, EmailOtpService::PURPOSE_PASSWORD_RESET, $otpCode, consume: true);
            $user->password = $validated['password'];
            $user->save();
            $user->tokens()->delete();
        });

        return $this->success(
            data: ['email' => $email],
            message: 'Kata sandi berhasil diperbarui. Silakan masuk dengan kata sandi baru.',
        );
    }

    public function login(LoginRequest $request, UserBootstrapService $bootstrapService): JsonResponse
    {
        $validated = $request->validated();
        $email = strtolower(trim($validated['email']));

        $user = User::query()->where('email', $email)->first();

        if ($user === null || ! Hash::check($validated['password'], $user->password)) {
            return $this->error(
                message: 'Email atau kata sandi salah.',
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


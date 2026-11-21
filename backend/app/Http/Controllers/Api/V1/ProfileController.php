<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Requests\Api\V1\Profile\ChangePasswordRequest;
use App\Http\Requests\Api\V1\Profile\UpdateProfileRequest;
use App\Http\Resources\Api\V1\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class ProfileController extends ApiController
{
    public function show(Request $request): JsonResponse
    {
        return $this->success(
            data: new UserResource($request->user()),
            message: 'Profile retrieved',
        );
    }

    public function update(UpdateProfileRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $user = $request->user();

        $user->update([
            'name' => trim($validated['name']),
            'email' => strtolower(trim($validated['email'])),
        ]);

        return $this->success(
            data: new UserResource($user->fresh()),
            message: 'Profile updated',
        );
    }

    public function updatePassword(ChangePasswordRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $user = $request->user();

        if (! Hash::check($validated['current_password'], $user->password)) {
            return $this->error(
                message: 'Current password is incorrect',
                code: 'VALIDATION_ERROR',
                status: 422,
                errors: ['current_password' => ['Current password is incorrect.']],
            );
        }

        $user->update([
            'password' => $validated['password'],
        ]);

        $currentTokenId = $user->currentAccessToken()?->id;
        if ($currentTokenId !== null) {
            $user->tokens()->where('id', '!=', $currentTokenId)->delete();
        }

        return $this->success(message: 'Password updated successfully');
    }
}


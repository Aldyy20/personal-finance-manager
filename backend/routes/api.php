<?php

use App\Http\Controllers\Api\V1\HealthController;
use App\Support\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::get('/health', HealthController::class)->name('api.v1.health');

    Route::middleware('auth:sanctum')->group(function () {
        // Placeholder authenticated endpoint for Phase 1 foundation auth check.
        // Full auth endpoints (/register, /login, /logout, /refresh, /me) will be implemented in Phase 2.
        Route::get('/auth/me', function (Request $request) {
            $user = $request->user();

            return ApiResponse::success([
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ], 'Authenticated user retrieved');
        })->name('api.v1.auth.me');
    });
});


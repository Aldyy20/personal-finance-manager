<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\DeviceController;
use App\Http\Controllers\Api\V1\HealthController;
use App\Http\Controllers\Api\V1\ProfileController;
use App\Http\Controllers\Api\V1\SettingController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::get('/health', HealthController::class)->name('api.v1.health');

    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register'])
            ->middleware('throttle:10,1')
            ->name('api.v1.auth.register');
        Route::post('/login', [AuthController::class, 'login'])
            ->middleware('throttle:10,1')
            ->name('api.v1.auth.login');
    });

    Route::middleware('auth:sanctum')->group(function () {
        Route::prefix('auth')->group(function () {
            Route::post('/logout', [AuthController::class, 'logout'])->name('api.v1.auth.logout');
            Route::post('/refresh', [AuthController::class, 'refresh'])->name('api.v1.auth.refresh');
            Route::get('/me', [AuthController::class, 'me'])->name('api.v1.auth.me');
        });

        Route::get('/profile', [ProfileController::class, 'show'])->name('api.v1.profile.show');
        Route::put('/profile', [ProfileController::class, 'update'])->name('api.v1.profile.update');
        Route::put('/profile/password', [ProfileController::class, 'updatePassword'])->name('api.v1.profile.password');

        Route::get('/settings', [SettingController::class, 'show'])->name('api.v1.settings.show');
        Route::put('/settings', [SettingController::class, 'update'])->name('api.v1.settings.update');

        Route::get('/devices', [DeviceController::class, 'index'])->name('api.v1.devices.index');
        Route::post('/devices/register', [DeviceController::class, 'register'])->name('api.v1.devices.register');
        Route::post('/devices/{id}/revoke', [DeviceController::class, 'revoke'])->name('api.v1.devices.revoke');
    });
});

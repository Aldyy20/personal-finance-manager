<?php

use App\Http\Controllers\Api\V1\AccountController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\BudgetController;
use App\Http\Controllers\Api\V1\CategoryController;
use App\Http\Controllers\Api\V1\DeviceController;
use App\Http\Controllers\Api\V1\HealthController;
use App\Http\Controllers\Api\V1\ProfileController;
use App\Http\Controllers\Api\V1\ReceiptController;
use App\Http\Controllers\Api\V1\ReportController;
use App\Http\Controllers\Api\V1\SettingController;
use App\Http\Controllers\Api\V1\SyncController;
use App\Http\Controllers\Api\V1\TransactionController;
use App\Http\Controllers\Api\V1\TransferController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::get('/health', HealthController::class)->name('api.v1.health');

    Route::prefix('auth')->group(function () {
        Route::post('/register/send-otp', [AuthController::class, 'sendRegisterOtp'])
            ->middleware('throttle:5,1')
            ->name('api.v1.auth.register.send-otp');
        Route::post('/register', [AuthController::class, 'register'])
            ->middleware('throttle:10,1')
            ->name('api.v1.auth.register');
        Route::post('/login', [AuthController::class, 'login'])
            ->middleware('throttle:10,1')
            ->name('api.v1.auth.login');
        Route::post('/password/send-otp', [AuthController::class, 'sendPasswordResetOtp'])
            ->middleware('throttle:5,1')
            ->name('api.v1.auth.password.send-otp');
        Route::post('/password/verify-otp', [AuthController::class, 'verifyPasswordResetOtp'])
            ->middleware('throttle:10,1')
            ->name('api.v1.auth.password.verify-otp');
        Route::post('/password/reset', [AuthController::class, 'resetPasswordWithOtp'])
            ->middleware('throttle:10,1')
            ->name('api.v1.auth.password.reset');
    });

    Route::middleware('auth:sanctum')->group(function () {
        // Authentication & Session
        Route::prefix('auth')->group(function () {
            Route::post('/logout', [AuthController::class, 'logout'])->name('api.v1.auth.logout');
            Route::post('/refresh', [AuthController::class, 'refresh'])->name('api.v1.auth.refresh');
            Route::get('/me', [AuthController::class, 'me'])->name('api.v1.auth.me');
        });

        // Profile & Settings
        Route::get('/profile', [ProfileController::class, 'show'])->name('api.v1.profile.show');
        Route::put('/profile', [ProfileController::class, 'update'])->name('api.v1.profile.update');
        Route::put('/profile/password', [ProfileController::class, 'updatePassword'])->name('api.v1.profile.password');
        Route::get('/settings', [SettingController::class, 'show'])->name('api.v1.settings.show');
        Route::put('/settings', [SettingController::class, 'update'])->name('api.v1.settings.update');

        // Devices
        Route::get('/devices', [DeviceController::class, 'index'])->name('api.v1.devices.index');
        Route::post('/devices/register', [DeviceController::class, 'register'])->name('api.v1.devices.register');
        Route::post('/devices/{id}/revoke', [DeviceController::class, 'revoke'])->name('api.v1.devices.revoke');

        // Accounts & Adjustments
        Route::get('/accounts', [AccountController::class, 'index'])->name('api.v1.accounts.index');
        Route::post('/accounts', [AccountController::class, 'store'])->name('api.v1.accounts.store');
        Route::get('/accounts/{id}', [AccountController::class, 'show'])->name('api.v1.accounts.show');
        Route::put('/accounts/{id}', [AccountController::class, 'update'])->name('api.v1.accounts.update');
        Route::post('/accounts/{id}/archive', [AccountController::class, 'archive'])->name('api.v1.accounts.archive');
        Route::post('/accounts/{id}/restore', [AccountController::class, 'restore'])->name('api.v1.accounts.restore');
        Route::get('/accounts/{id}/movements', [AccountController::class, 'movements'])->name('api.v1.accounts.movements');
        Route::get('/accounts/{id}/balance', [AccountController::class, 'balance'])->name('api.v1.accounts.balance');
        Route::post('/accounts/{id}/adjustments', [AccountController::class, 'storeAdjustment'])->name('api.v1.accounts.adjustments.store');

        // Categories
        Route::get('/categories', [CategoryController::class, 'index'])->name('api.v1.categories.index');
        Route::post('/categories', [CategoryController::class, 'store'])->name('api.v1.categories.store');
        Route::get('/categories/{id}', [CategoryController::class, 'show'])->name('api.v1.categories.show');
        Route::put('/categories/{id}', [CategoryController::class, 'update'])->name('api.v1.categories.update');
        Route::post('/categories/{id}/archive', [CategoryController::class, 'archive'])->name('api.v1.categories.archive');
        Route::post('/categories/{id}/restore', [CategoryController::class, 'restore'])->name('api.v1.categories.restore');

        // Transactions (Income & Expense)
        Route::get('/transactions', [TransactionController::class, 'index'])->name('api.v1.transactions.index');
        Route::post('/transactions', [TransactionController::class, 'store'])->name('api.v1.transactions.store');
        Route::get('/transactions/{id}', [TransactionController::class, 'show'])->name('api.v1.transactions.show');
        Route::put('/transactions/{id}', [TransactionController::class, 'update'])->name('api.v1.transactions.update');
        Route::post('/transactions/{id}/void', [TransactionController::class, 'void'])->name('api.v1.transactions.void');
        Route::get('/transactions/{id}/revisions', [TransactionController::class, 'revisions'])->name('api.v1.transactions.revisions');

        // Transfers
        Route::get('/transfers', [TransferController::class, 'index'])->name('api.v1.transfers.index');
        Route::post('/transfers', [TransferController::class, 'store'])->name('api.v1.transfers.store');
        Route::get('/transfers/{id}', [TransferController::class, 'show'])->name('api.v1.transfers.show');
        Route::put('/transfers/{id}', [TransferController::class, 'update'])->name('api.v1.transfers.update');
        Route::post('/transfers/{id}/void', [TransferController::class, 'void'])->name('api.v1.transfers.void');

        // Receipts
        Route::post('/receipts/scan-ai', [ReceiptController::class, 'scanAi'])
            ->middleware('throttle:20,1')
            ->name('api.v1.receipts.scan-ai');
        Route::post('/receipts', [ReceiptController::class, 'store'])->name('api.v1.receipts.store');
        Route::get('/receipts/{id}', [ReceiptController::class, 'show'])->name('api.v1.receipts.show');
        Route::get('/receipts/{id}/download', [ReceiptController::class, 'download'])->name('api.v1.receipts.download');
        Route::delete('/receipts/{id}', [ReceiptController::class, 'destroy'])->name('api.v1.receipts.destroy');

        // Budgets
        Route::get('/budgets', [BudgetController::class, 'index'])->name('api.v1.budgets.index');
        Route::post('/budgets', [BudgetController::class, 'store'])->name('api.v1.budgets.store');
        Route::get('/budgets/{id}', [BudgetController::class, 'show'])->name('api.v1.budgets.show');
        Route::put('/budgets/{id}', [BudgetController::class, 'update'])->name('api.v1.budgets.update');
        Route::post('/budgets/{id}/archive', [BudgetController::class, 'archive'])->name('api.v1.budgets.archive');
        Route::get('/budgets/{id}/summary', [BudgetController::class, 'summary'])->name('api.v1.budgets.summary');

        // Reports
        Route::prefix('reports')->group(function () {
            Route::get('/overview', [ReportController::class, 'overview'])->name('api.v1.reports.overview');
            Route::get('/income', [ReportController::class, 'income'])->name('api.v1.reports.income');
            Route::get('/expense', [ReportController::class, 'expense'])->name('api.v1.reports.expense');
            Route::get('/cash-flow', [ReportController::class, 'cashFlow'])->name('api.v1.reports.cash_flow');
            Route::get('/categories', [ReportController::class, 'categories'])->name('api.v1.reports.categories');
            Route::get('/accounts', [ReportController::class, 'accounts'])->name('api.v1.reports.accounts');
            Route::get('/budgets', [ReportController::class, 'budgets'])->name('api.v1.reports.budgets');
            Route::get('/monthly-comparison', [ReportController::class, 'monthlyComparison'])->name('api.v1.reports.monthly_comparison');
        });

        // Synchronization
        Route::post('/sync/push', [SyncController::class, 'push'])->name('api.v1.sync.push');
        Route::get('/sync/pull', [SyncController::class, 'pull'])->name('api.v1.sync.pull');
        Route::get('/sync/status', [SyncController::class, 'status'])->name('api.v1.sync.status');
    });
});

<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Throwable;

class HealthController extends ApiController
{
    public function __invoke(): JsonResponse
    {
        $dbStatus = 'disconnected';
        $dbError = null;

        try {
            DB::connection()->getPdo();
            DB::select('SELECT 1');
            $dbStatus = 'connected';
        } catch (Throwable $e) {
            $dbError = config('app.debug') ? $e->getMessage() : 'Database connection unavailable';
        }

        $isHealthy = $dbStatus === 'connected';

        return $this->success(
            data: array_filter([
                'status' => $isHealthy ? 'ok' : 'degraded',
                'version' => 'v1',
                'database' => $dbStatus,
                'database_error' => $dbError,
                'timestamp' => now()->utc()->toIso8601ZuluString('millisecond'),
            ], fn ($v) => $v !== null),
            message: $isHealthy ? 'Service is healthy' : 'Service degraded',
            status: $isHealthy ? 200 : 503,
        );
    }
}


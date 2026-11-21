<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;

abstract class ApiController extends Controller
{
    protected function success(
        mixed $data = null,
        string $message = 'Operation successful',
        int $status = 200,
        array $meta = []
    ): JsonResponse {
        return ApiResponse::success($data, $message, $status, $meta);
    }

    protected function error(
        string $message,
        string $code = 'ERROR',
        int $status = 400,
        mixed $errors = null
    ): JsonResponse {
        return ApiResponse::error($message, $code, $status, $errors);
    }
}


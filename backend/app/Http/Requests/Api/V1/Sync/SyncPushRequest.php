<?php

namespace App\Http\Requests\Api\V1\Sync;

use App\Http\Requests\Api\V1\BaseApiRequest;

class SyncPushRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'device_id' => ['required', 'uuid'],
            'operations' => ['required', 'array', 'min:1', 'max:100'],
            'operations.*.operation_id' => ['required', 'uuid'],
            'operations.*.entity_type' => ['required', 'string', 'max:50'],
            'operations.*.entity_id' => ['required', 'uuid'],
            'operations.*.operation_type' => ['required', 'string', 'max:20'],
            'operations.*.base_version' => ['nullable', 'integer', 'min:0'],
            'operations.*.payload' => ['required', 'array'],
        ];
    }
}


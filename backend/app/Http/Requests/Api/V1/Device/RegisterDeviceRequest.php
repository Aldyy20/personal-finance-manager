<?php

namespace App\Http\Requests\Api\V1\Device;

use App\Http\Requests\Api\V1\BaseApiRequest;

class RegisterDeviceRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'id' => ['nullable', 'uuid'],
            'device_name' => ['required_without:name', 'string', 'max:100'],
            'name' => ['required_without:device_name', 'string', 'max:100'],
            'platform' => ['nullable', 'string', 'in:android'],
            'app_version' => ['nullable', 'string', 'max:30'],
        ];
    }
}


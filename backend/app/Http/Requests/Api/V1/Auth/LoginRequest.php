<?php

namespace App\Http\Requests\Api\V1\Auth;

use App\Http\Requests\Api\V1\BaseApiRequest;

class LoginRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
            'device' => ['nullable', 'array'],
            'device.id' => ['required_with:device', 'uuid'],
            'device.name' => ['required_with:device', 'string', 'max:100'],
            'device.platform' => ['nullable', 'string', 'in:android'],
            'device.app_version' => ['nullable', 'string', 'max:30'],
        ];
    }
}


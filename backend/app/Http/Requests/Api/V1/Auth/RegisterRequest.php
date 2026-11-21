<?php

namespace App\Http\Requests\Api\V1\Auth;

use App\Http\Requests\Api\V1\BaseApiRequest;

class RegisterRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:100'],
            'email' => ['required', 'string', 'email', 'max:191', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'device' => ['nullable', 'array'],
            'device.id' => ['required_with:device', 'uuid'],
            'device.name' => ['required_with:device', 'string', 'max:100'],
            'device.platform' => ['nullable', 'string', 'in:android'],
            'device.app_version' => ['nullable', 'string', 'max:30'],
        ];
    }
}


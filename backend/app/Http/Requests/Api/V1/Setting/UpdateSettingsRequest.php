<?php

namespace App\Http\Requests\Api\V1\Setting;

use App\Http\Requests\Api\V1\BaseApiRequest;

class UpdateSettingsRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'theme_mode' => ['sometimes', 'string', 'in:light,dark,system'],
            'timezone' => ['sometimes', 'string', 'timezone', 'max:50'],
            'budget_warning_percent' => ['sometimes', 'integer', 'min:1', 'max:100'],
            'notifications_enabled' => ['sometimes', 'boolean'],
        ];
    }
}


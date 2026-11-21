<?php

namespace App\Http\Requests\Api\V1\Category;

use App\Http\Requests\Api\V1\BaseApiRequest;

class UpdateCategoryRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:100'],
            'type' => ['sometimes', 'string', 'in:income,expense'],
            'icon' => ['nullable', 'string', 'max:50'],
            'color' => ['nullable', 'string', 'max:20'],
            'sort_order' => ['sometimes', 'integer'],
            'is_active' => ['sometimes', 'boolean'],
            'description' => ['nullable', 'string', 'max:255'],
            'base_version' => ['nullable', 'integer', 'min:1'],
        ];
    }
}


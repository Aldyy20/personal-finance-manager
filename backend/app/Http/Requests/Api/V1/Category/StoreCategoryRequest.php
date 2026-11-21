<?php

namespace App\Http\Requests\Api\V1\Category;

use App\Http\Requests\Api\V1\BaseApiRequest;

class StoreCategoryRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'id' => ['nullable', 'uuid'],
            'name' => ['required', 'string', 'max:100'],
            'type' => ['required', 'string', 'in:income,expense'],
            'icon' => ['nullable', 'string', 'max:50'],
            'color' => ['nullable', 'string', 'max:20'],
            'sort_order' => ['nullable', 'integer'],
        ];
    }
}


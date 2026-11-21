<?php

namespace App\Http\Requests\Api\V1\Budget;

use App\Http\Requests\Api\V1\BaseApiRequest;

class UpdateBudgetRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:100'],
            'period_type' => ['sometimes', 'string', 'in:monthly,custom,weekly'],
            'start_date' => ['sometimes', 'date_format:Y-m-d'],
            'end_date' => ['sometimes', 'date_format:Y-m-d'],
            'total_limit' => ['nullable', 'integer', 'min:1'],
            'warning_percent' => ['sometimes', 'integer', 'min:1', 'max:100'],
            'is_active' => ['sometimes', 'boolean'],
            'base_version' => ['nullable', 'integer', 'min:1'],
            'categories' => ['sometimes', 'array'],
            'categories.*.id' => ['nullable', 'uuid'],
            'categories.*.category_id' => ['required', 'uuid'],
            'categories.*.amount_limit' => ['required', 'integer', 'min:1'],
        ];
    }
}


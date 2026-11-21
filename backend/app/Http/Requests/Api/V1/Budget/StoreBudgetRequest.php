<?php

namespace App\Http\Requests\Api\V1\Budget;

use App\Http\Requests\Api\V1\BaseApiRequest;

class StoreBudgetRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'id' => ['nullable', 'uuid'],
            'name' => ['required', 'string', 'max:100'],
            'period_type' => ['nullable', 'string', 'in:monthly,custom,weekly'],
            'start_date' => ['required', 'date_format:Y-m-d'],
            'end_date' => ['required', 'date_format:Y-m-d', 'after_or_equal:start_date'],
            'total_limit' => ['nullable', 'integer', 'min:1'],
            'warning_percent' => ['nullable', 'integer', 'min:1', 'max:100'],
            'is_active' => ['nullable', 'boolean'],
            'categories' => ['nullable', 'array'],
            'categories.*.id' => ['nullable', 'uuid'],
            'categories.*.category_id' => ['required', 'uuid'],
            'categories.*.amount_limit' => ['required', 'integer', 'min:1'],
        ];
    }
}


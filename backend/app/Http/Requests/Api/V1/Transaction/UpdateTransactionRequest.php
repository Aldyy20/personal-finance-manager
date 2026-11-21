<?php

namespace App\Http\Requests\Api\V1\Transaction;

use App\Http\Requests\Api\V1\BaseApiRequest;

class UpdateTransactionRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'type' => ['sometimes', 'string', 'in:income,expense'],
            'account_id' => ['sometimes', 'uuid'],
            'category_id' => ['sometimes', 'uuid'],
            'amount' => ['sometimes', 'integer', 'min:1'],
            'transaction_date' => ['sometimes', 'date'],
            'description' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string'],
            'reason' => ['nullable', 'string', 'max:255'],
            'device_id' => ['nullable', 'uuid'],
            'base_version' => ['nullable', 'integer', 'min:1'],
        ];
    }
}


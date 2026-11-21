<?php

namespace App\Http\Requests\Api\V1\Transaction;

use App\Http\Requests\Api\V1\BaseApiRequest;

class StoreTransactionRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'id' => ['nullable', 'uuid'],
            'type' => ['required', 'string', 'in:income,expense'],
            'account_id' => ['required', 'uuid'],
            'category_id' => ['required', 'uuid'],
            'amount' => ['required', 'integer', 'min:1'],
            'transaction_date' => ['required', 'date'],
            'description' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string'],
            'created_by_device_id' => ['nullable', 'uuid'],
        ];
    }
}


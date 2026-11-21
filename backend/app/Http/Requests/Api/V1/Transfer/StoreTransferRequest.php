<?php

namespace App\Http\Requests\Api\V1\Transfer;

use App\Http\Requests\Api\V1\BaseApiRequest;

class StoreTransferRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'id' => ['nullable', 'uuid'],
            'source_account_id' => ['required', 'uuid'],
            'destination_account_id' => ['required', 'uuid', 'different:source_account_id'],
            'amount' => ['required', 'integer', 'min:1'],
            'transaction_date' => ['required', 'date'],
            'description' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string'],
            'created_by_device_id' => ['nullable', 'uuid'],
        ];
    }
}


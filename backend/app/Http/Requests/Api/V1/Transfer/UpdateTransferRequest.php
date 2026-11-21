<?php

namespace App\Http\Requests\Api\V1\Transfer;

use App\Http\Requests\Api\V1\BaseApiRequest;

class UpdateTransferRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'source_account_id' => ['sometimes', 'uuid'],
            'destination_account_id' => ['sometimes', 'uuid'],
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


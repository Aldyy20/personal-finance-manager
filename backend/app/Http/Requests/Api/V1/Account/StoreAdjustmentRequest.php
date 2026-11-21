<?php

namespace App\Http\Requests\Api\V1\Account;

use App\Http\Requests\Api\V1\BaseApiRequest;

class StoreAdjustmentRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'id' => ['nullable', 'uuid'],
            'amount_signed' => ['required', 'integer', 'not_in:0'],
            'reason' => ['required', 'string', 'max:255'],
            'created_by_device_id' => ['nullable', 'uuid'],
        ];
    }
}


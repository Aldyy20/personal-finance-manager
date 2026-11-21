<?php

namespace App\Http\Requests\Api\V1\Account;

use App\Http\Requests\Api\V1\BaseApiRequest;

class StoreAccountRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'id' => ['nullable', 'uuid'],
            'name' => ['required', 'string', 'max:100'],
            'account_type' => ['required', 'string', 'in:cash,bank,e_wallet,other'],
            'institution_name' => ['nullable', 'string', 'max:100'],
            'account_number' => ['nullable', 'string', 'max:50'],
            'opening_balance' => ['required', 'integer'],
            'opening_balance_date' => ['required', 'date_format:Y-m-d'],
            'icon' => ['nullable', 'string', 'max:50'],
            'color' => ['nullable', 'string', 'max:20'],
        ];
    }
}


<?php

namespace App\Http\Requests\Api\V1\Account;

use App\Http\Requests\Api\V1\BaseApiRequest;

class UpdateAccountRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:100'],
            'account_type' => ['sometimes', 'string', 'in:cash,bank,e_wallet,other'],
            'institution_name' => ['nullable', 'string', 'max:100'],
            'account_number' => ['nullable', 'string', 'max:50'],
            'opening_balance' => ['sometimes', 'integer'],
            'icon' => ['nullable', 'string', 'max:50'],
            'color' => ['nullable', 'string', 'max:20'],
            'base_version' => ['nullable', 'integer', 'min:1'],
        ];
    }
}


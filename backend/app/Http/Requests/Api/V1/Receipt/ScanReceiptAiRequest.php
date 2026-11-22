<?php

namespace App\Http\Requests\Api\V1\Receipt;

use App\Http\Requests\Api\V1\BaseApiRequest;

class ScanReceiptAiRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'file' => ['required', 'file', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
            'categories' => ['nullable', 'array', 'max:50'],
            'categories.*' => ['string', 'max:80'],
        ];
    }
}


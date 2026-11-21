<?php

namespace App\Http\Requests\Api\V1\Receipt;

use App\Http\Requests\Api\V1\BaseApiRequest;

class UploadReceiptRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'id' => ['nullable', 'uuid'],
            'transaction_id' => ['required', 'uuid'],
            'file' => ['required', 'file', 'max:5120'],
            'checksum' => ['nullable', 'string', 'size:64'],
            'ocr_text' => ['nullable', 'string'],
            'extracted_data' => ['nullable'],
        ];
    }
}


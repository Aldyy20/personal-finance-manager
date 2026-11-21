<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;

class ReceiptResource extends BaseJsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'transaction_id' => $this->transaction_id,
            'user_id' => $this->user_id,
            'file_name' => $this->file_name,
            'mime_type' => $this->mime_type,
            'file_size' => (int) $this->file_size,
            'checksum' => $this->checksum,
            'ocr_text' => $this->ocr_text,
            'extracted_data' => $this->extracted_data,
            'version' => (int) $this->version,
            'download_url' => route('api.v1.receipts.download', ['id' => $this->id], false),
            'created_at' => $this->created_at?->utc()->toIso8601ZuluString('millisecond'),
            'updated_at' => $this->updated_at?->utc()->toIso8601ZuluString('millisecond'),
            'deleted_at' => $this->deleted_at?->utc()->toIso8601ZuluString('millisecond'),
        ];
    }
}


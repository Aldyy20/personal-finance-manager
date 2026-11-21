<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;

class TransactionRevisionResource extends BaseJsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'transaction_id' => $this->transaction_id,
            'revision_number' => (int) $this->revision_number,
            'action' => $this->action,
            'before_data' => $this->before_data,
            'after_data' => $this->after_data,
            'reason' => $this->reason,
            'device_id' => $this->device_id,
            'created_at' => $this->created_at?->utc()->toIso8601ZuluString('millisecond'),
        ];
    }
}


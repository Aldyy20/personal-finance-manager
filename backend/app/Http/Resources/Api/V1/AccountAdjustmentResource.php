<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;

class AccountAdjustmentResource extends BaseJsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'account_id' => $this->account_id,
            'amount_signed' => (int) $this->amount_signed,
            'reason' => $this->reason,
            'created_by_device_id' => $this->created_by_device_id,
            'created_at' => $this->created_at?->utc()->toIso8601ZuluString('millisecond'),
        ];
    }
}


<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;

class AccountMovementResource extends BaseJsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'account_id' => $this->account_id,
            'transaction_id' => $this->transaction_id,
            'adjustment_id' => $this->adjustment_id,
            'posting_group_id' => $this->posting_group_id,
            'movement_type' => $this->movement_type,
            'amount_signed' => (int) $this->amount_signed,
            'reversal_of_id' => $this->reversal_of_id,
            'created_at' => $this->created_at?->utc()->toIso8601ZuluString('millisecond'),
        ];
    }
}


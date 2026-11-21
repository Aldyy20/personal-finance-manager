<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;

class AccountResource extends BaseJsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'name' => $this->name,
            'account_type' => $this->account_type,
            'institution_name' => $this->institution_name,
            'account_number' => $this->account_number,
            'opening_balance' => (int) $this->opening_balance,
            'opening_balance_date' => $this->opening_balance_date?->format('Y-m-d'),
            'balance_cache' => (int) $this->balance_cache,
            'icon' => $this->icon,
            'color' => $this->color,
            'is_active' => (bool) $this->is_active,
            'version' => (int) $this->version,
            'created_at' => $this->created_at?->utc()->toIso8601ZuluString('millisecond'),
            'updated_at' => $this->updated_at?->utc()->toIso8601ZuluString('millisecond'),
            'deleted_at' => $this->deleted_at?->utc()->toIso8601ZuluString('millisecond'),
        ];
    }
}


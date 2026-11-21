<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;

class TransactionResource extends BaseJsonResource
{
    public function toArray(Request $request): array
    {
        $accountId = null;
        $sourceAccountId = null;
        $destinationAccountId = null;

        if ($this->relationLoaded('movements')) {
            $reversedIds = $this->movements->pluck('reversal_of_id')->filter();
            $activeMovements = $this->movements
                ->where('movement_type', 'transaction')
                ->reject(fn ($m) => $reversedIds->contains($m->id));

            if ($this->type === 'transfer') {
                $sourceAccountId = $activeMovements->firstWhere('amount_signed', '<', 0)?->account_id;
                $destinationAccountId = $activeMovements->firstWhere('amount_signed', '>', 0)?->account_id;
            } else {
                $accountId = $activeMovements->first()?->account_id;
            }
        }

        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'type' => $this->type,
            'category_id' => $this->category_id,
            'category_type' => $this->category_type,
            'account_id' => $accountId,
            'source_account_id' => $sourceAccountId,
            'destination_account_id' => $destinationAccountId,
            'amount' => (int) $this->amount,
            'transaction_date' => $this->transaction_date?->utc()->toIso8601ZuluString('millisecond'),
            'description' => $this->description,
            'notes' => $this->notes,
            'status' => $this->status,
            'created_by_device_id' => $this->created_by_device_id,
            'version' => (int) $this->version,
            'category' => $this->whenLoaded('category', fn () => $this->category ? new CategoryResource($this->category) : null),
            'movements' => AccountMovementResource::collection($this->whenLoaded('movements')),
            'created_at' => $this->created_at?->utc()->toIso8601ZuluString('millisecond'),
            'updated_at' => $this->updated_at?->utc()->toIso8601ZuluString('millisecond'),
            'deleted_at' => $this->deleted_at?->utc()->toIso8601ZuluString('millisecond'),
        ];
    }
}


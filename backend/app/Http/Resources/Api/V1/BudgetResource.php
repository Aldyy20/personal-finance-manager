<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;

class BudgetResource extends BaseJsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'name' => $this->name,
            'period_type' => $this->period_type,
            'start_date' => $this->start_date?->format('Y-m-d'),
            'end_date' => $this->end_date?->format('Y-m-d'),
            'total_limit' => $this->total_limit !== null ? (int) $this->total_limit : null,
            'warning_percent' => (int) $this->warning_percent,
            'is_active' => (bool) $this->is_active,
            'version' => (int) $this->version,
            'categories' => $this->whenLoaded('budgetCategories', fn () => $this->budgetCategories->map(fn ($bc) => [
                'id' => $bc->id,
                'category_id' => $bc->category_id,
                'category_type' => $bc->category_type,
                'amount_limit' => (int) $bc->amount_limit,
                'version' => (int) $bc->version,
                'category' => $bc->relationLoaded('category') && $bc->category
                    ? new CategoryResource($bc->category)
                    : null,
            ])->values()->all()),
            'created_at' => $this->created_at?->utc()->toIso8601ZuluString('millisecond'),
            'updated_at' => $this->updated_at?->utc()->toIso8601ZuluString('millisecond'),
            'deleted_at' => $this->deleted_at?->utc()->toIso8601ZuluString('millisecond'),
        ];
    }
}


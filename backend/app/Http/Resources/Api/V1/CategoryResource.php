<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;

class CategoryResource extends BaseJsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'name' => $this->name,
            'type' => $this->type,
            'icon' => $this->icon,
            'color' => $this->color,
            'is_default' => (bool) $this->is_default,
            'is_active' => (bool) $this->is_active,
            'sort_order' => (int) $this->sort_order,
            'version' => (int) $this->version,
            'created_at' => $this->created_at?->utc()->toIso8601ZuluString('millisecond'),
            'updated_at' => $this->updated_at?->utc()->toIso8601ZuluString('millisecond'),
            'deleted_at' => $this->deleted_at?->utc()->toIso8601ZuluString('millisecond'),
        ];
    }
}


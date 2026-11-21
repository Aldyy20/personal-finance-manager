<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;

class DeviceResource extends BaseJsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'device_name' => $this->device_name,
            'platform' => $this->platform,
            'app_version' => $this->app_version,
            'is_active' => $this->is_active,
            'last_sync_at' => $this->last_sync_at?->utc()->toIso8601ZuluString('millisecond'),
            'created_at' => $this->created_at?->utc()->toIso8601ZuluString('millisecond'),
            'updated_at' => $this->updated_at?->utc()->toIso8601ZuluString('millisecond'),
        ];
    }
}


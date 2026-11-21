<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;

class UserSettingResource extends BaseJsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'theme_mode' => $this->theme_mode,
            'currency' => $this->currency,
            'timezone' => $this->timezone,
            'budget_warning_percent' => $this->budget_warning_percent,
            'notifications_enabled' => $this->notifications_enabled,
            'version' => $this->version,
            'updated_at' => $this->updated_at?->utc()->toIso8601ZuluString('millisecond'),
        ];
    }
}


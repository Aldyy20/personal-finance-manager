<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserSetting extends Model
{
    use HasUuids;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'user_id',
        'theme_mode',
        'currency',
        'timezone',
        'budget_warning_percent',
        'notifications_enabled',
        'version',
    ];

    protected function casts(): array
    {
        return [
            'budget_warning_percent' => 'integer',
            'notifications_enabled' => 'boolean',
            'version' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}


<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SyncChange extends Model
{
    public const UPDATED_AT = null;

    public $incrementing = false;

    protected $primaryKey = 'sequence';

    protected $fillable = [
        'user_id',
        'sequence',
        'entity_type',
        'entity_id',
        'operation',
        'entity_version',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'sequence' => 'integer',
            'entity_version' => 'integer',
            'created_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}


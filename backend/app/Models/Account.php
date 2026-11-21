<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Account extends Model
{
    use HasUuids, SoftDeletes;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'user_id',
        'name',
        'account_type',
        'institution_name',
        'account_number',
        'opening_balance',
        'opening_balance_date',
        'balance_cache',
        'icon',
        'color',
        'is_active',
        'version',
    ];

    protected function casts(): array
    {
        return [
            'opening_balance' => 'integer',
            'opening_balance_date' => 'date:Y-m-d',
            'balance_cache' => 'integer',
            'is_active' => 'boolean',
            'version' => 'integer',
            'deleted_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function movements(): HasMany
    {
        return $this->hasMany(AccountMovement::class);
    }

    public function adjustments(): HasMany
    {
        return $this->hasMany(AccountAdjustment::class);
    }
}


<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use LogicException;

class AccountAdjustment extends Model
{
    use HasUuids;

    public const UPDATED_AT = null;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'user_id',
        'account_id',
        'amount_signed',
        'reason',
        'created_by_device_id',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'amount_signed' => 'integer',
            'created_at' => 'datetime',
        ];
    }

    protected static function booted(): void
    {
        static::updating(function (): void {
            throw new LogicException('Account adjustments are immutable and cannot be updated.');
        });

        static::deleting(function (): void {
            throw new LogicException('Account adjustments are immutable and cannot be deleted.');
        });
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function account(): BelongsTo
    {
        return $this->belongsTo(Account::class);
    }

    public function createdByDevice(): BelongsTo
    {
        return $this->belongsTo(Device::class, 'created_by_device_id');
    }

    public function movement(): HasOne
    {
        return $this->hasOne(AccountMovement::class, 'adjustment_id');
    }
}


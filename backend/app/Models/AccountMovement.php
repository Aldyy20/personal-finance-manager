<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use LogicException;

class AccountMovement extends Model
{
    use HasUuids;

    public const UPDATED_AT = null;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'user_id',
        'account_id',
        'transaction_id',
        'adjustment_id',
        'posting_group_id',
        'movement_type',
        'amount_signed',
        'reversal_of_id',
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
            throw new LogicException('Posted account movements are immutable and cannot be updated.');
        });

        static::deleting(function (): void {
            throw new LogicException('Posted account movements are immutable and cannot be deleted.');
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

    public function transaction(): BelongsTo
    {
        return $this->belongsTo(Transaction::class);
    }

    public function adjustment(): BelongsTo
    {
        return $this->belongsTo(AccountAdjustment::class, 'adjustment_id');
    }

    public function reversalOf(): BelongsTo
    {
        return $this->belongsTo(self::class, 'reversal_of_id');
    }
}


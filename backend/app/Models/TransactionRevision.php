<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use LogicException;

class TransactionRevision extends Model
{
    use HasUuids;

    public const UPDATED_AT = null;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'transaction_id',
        'user_id',
        'revision_number',
        'action',
        'before_data',
        'after_data',
        'reason',
        'device_id',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'revision_number' => 'integer',
            'before_data' => 'array',
            'after_data' => 'array',
            'created_at' => 'datetime',
        ];
    }

    protected static function booted(): void
    {
        static::updating(function (): void {
            throw new LogicException('Transaction revisions are immutable audit records and cannot be updated.');
        });

        static::deleting(function (): void {
            throw new LogicException('Transaction revisions are immutable audit records and cannot be deleted.');
        });
    }

    public function transaction(): BelongsTo
    {
        return $this->belongsTo(Transaction::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function device(): BelongsTo
    {
        return $this->belongsTo(Device::class);
    }
}


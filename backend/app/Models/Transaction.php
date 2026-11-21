<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Transaction extends Model
{
    use HasUuids, SoftDeletes;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'user_id',
        'type',
        'category_id',
        'category_type',
        'amount',
        'transaction_date',
        'description',
        'notes',
        'status',
        'created_by_device_id',
        'version',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'integer',
            'transaction_date' => 'datetime',
            'version' => 'integer',
            'deleted_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function createdByDevice(): BelongsTo
    {
        return $this->belongsTo(Device::class, 'created_by_device_id');
    }

    public function movements(): HasMany
    {
        return $this->hasMany(AccountMovement::class);
    }

    public function revisions(): HasMany
    {
        return $this->hasMany(TransactionRevision::class);
    }

    public function receipts(): HasMany
    {
        return $this->hasMany(Receipt::class);
    }
}


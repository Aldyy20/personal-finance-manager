<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Receipt extends Model
{
    use HasUuids, SoftDeletes;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'transaction_id',
        'user_id',
        'file_path',
        'file_name',
        'mime_type',
        'file_size',
        'checksum',
        'ocr_text',
        'extracted_data',
        'version',
    ];

    protected function casts(): array
    {
        return [
            'file_size' => 'integer',
            'extracted_data' => 'array',
            'version' => 'integer',
            'deleted_at' => 'datetime',
        ];
    }

    public function transaction(): BelongsTo
    {
        return $this->belongsTo(Transaction::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}


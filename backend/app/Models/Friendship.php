<?php
// app/Models/Friendship.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class Friendship extends Model
{
    public $incrementing = false;
    protected $keyType   = 'string';

    protected $fillable = [
        'id', 'requester_id', 'addressee_id', 'status',
    ];

    protected static function booted(): void
    {
        static::creating(function (Friendship $f) {
            if (empty($f->id)) {
                $f->id = (string) Str::uuid();
            }
        });
    }

    public function requester(): BelongsTo
    {
        return $this->belongsTo(User::class, 'requester_id');
    }

    public function addressee(): BelongsTo
    {
        return $this->belongsTo(User::class, 'addressee_id');
    }

    // ─── Scopes ───────────────────────────────────────────────────────────────

    public function scopeAccepted($query)
    {
        return $query->where('status', 'accepted');
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeInvolving($query, int $userId)
    {
        return $query->where('requester_id', $userId)
            ->orWhere('addressee_id', $userId);
    }
}

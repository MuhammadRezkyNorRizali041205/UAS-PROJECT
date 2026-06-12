<?php
// app/Models/Friendship.php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Friendship extends Model
{
    use HasUuid;

    protected $fillable = [
        'requester_id', 'addressee_id', 'status',
    ];

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

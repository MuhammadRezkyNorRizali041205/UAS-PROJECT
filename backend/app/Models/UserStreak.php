<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserStreak extends Model
{
    protected $fillable = [
        'user_id',
        'current_streak',
        'longest_streak',
        'last_activity_date',
    ];

    protected $casts = [
        'current_streak'     => 'integer',
        'longest_streak'     => 'integer',
        'last_activity_date' => 'date',
    ];

    // ─── Accessors ────────────────────────────────────────────────────────────

    public function getStreakEmojiAttribute(): string
    {
        return match (true) {
            $this->current_streak >= 100 => '🔥💎',
            $this->current_streak >= 30  => '🔥🌟',
            $this->current_streak >= 7   => '🔥',
            $this->current_streak >= 3   => '🔥',
            $this->current_streak >= 1   => '🔥',
            default                      => '❄️',
        };
    }

    public function getIsActiveToday(): bool
    {
        return $this->last_activity_date?->isToday() ?? false;
    }

    // ─── Relationships ────────────────────────────────────────────────────────

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class UserPoint extends Model
{
    protected $fillable = [
        'user_id',
        'total_points',
        'level',
        'current_level_points',
        'next_level_threshold',
    ];

    protected $casts = [
        'total_points'          => 'integer',
        'current_level_points'  => 'integer',
        'next_level_threshold'  => 'integer',
    ];

    // ─── Level configuration ──────────────────────────────────────────────────

    public const LEVEL_THRESHOLDS = [
        'bronze'   => 0,
        'silver'   => 500,
        'gold'     => 2000,
        'platinum' => 5000,
        'diamond'  => 10000,
    ];

    public const LEVEL_LABELS = [
        'bronze'   => 'Bronze',
        'silver'   => 'Silver',
        'gold'     => 'Gold',
        'platinum' => 'Platinum',
        'diamond'  => 'Diamond',
    ];

    public const LEVEL_COLORS = [
        'bronze'   => '#CD7F32',
        'silver'   => '#C0C0C0',
        'gold'     => '#FFD700',
        'platinum' => '#E5E4E2',
        'diamond'  => '#B9F2FF',
    ];

    // ─── Accessors ────────────────────────────────────────────────────────────

    public function getLevelLabelAttribute(): string
    {
        return self::LEVEL_LABELS[$this->level] ?? 'Bronze';
    }

    public function getLevelColorAttribute(): string
    {
        return self::LEVEL_COLORS[$this->level] ?? '#CD7F32';
    }

    public function getProgressPercentageAttribute(): float
    {
        $levels = array_keys(self::LEVEL_THRESHOLDS);
        $currentIdx = array_search($this->level, $levels);

        if ($currentIdx === false || $currentIdx >= count($levels) - 1) {
            return 100.0; // Max level
        }

        $currentThreshold = self::LEVEL_THRESHOLDS[$this->level];
        $nextThreshold    = self::LEVEL_THRESHOLDS[$levels[$currentIdx + 1]];
        $range            = $nextThreshold - $currentThreshold;

        if ($range <= 0) return 100.0;

        $progress = $this->total_points - $currentThreshold;
        return round(min(($progress / $range) * 100, 100), 2);
    }

    // ─── Relationships ────────────────────────────────────────────────────────

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function histories(): HasMany
    {
        return $this->hasMany(PointHistory::class, 'user_id', 'user_id');
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class DailyQuest extends Model
{
    protected $fillable = [
        'key',
        'title',
        'description',
        'icon',
        'activity_type',
        'target_count',
        'points_reward',
        'is_active',
    ];

    protected $casts = [
        'target_count'  => 'integer',
        'points_reward' => 'integer',
        'is_active'     => 'boolean',
    ];

    // ─── Scopes ───────────────────────────────────────────────────────────────

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    // ─── Relationships ────────────────────────────────────────────────────────

    public function userQuests(): HasMany
    {
        return $this->hasMany(UserQuest::class, 'quest_id');
    }
}

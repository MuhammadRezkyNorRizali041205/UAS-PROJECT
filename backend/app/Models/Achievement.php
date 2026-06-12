<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Achievement extends Model
{
    protected $fillable = [
        'key',
        'title',
        'description',
        'icon',
        'badge_color',
        'category',
        'condition_type',
        'condition_value',
        'points_reward',
    ];

    protected $casts = [
        'condition_value' => 'integer',
        'points_reward'   => 'integer',
    ];

    // ─── Relationships ────────────────────────────────────────────────────────

    public function userAchievements(): HasMany
    {
        return $this->hasMany(UserAchievement::class);
    }

    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'user_achievements')
            ->withPivot('earned_at')
            ->withTimestamps();
    }
}

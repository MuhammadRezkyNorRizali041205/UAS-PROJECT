<?php
// app/Models/SocialFeed.php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SocialFeed extends Model
{
    use HasUuid;

    protected $fillable = [
        'user_id', 'type', 'title', 'description',
        'achievement_data', 'visibility', 'likes_count',
    ];

    protected function casts(): array
    {
        return [
            'achievement_data' => 'array',
            'likes_count'      => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function feedLikes(): HasMany
    {
        return $this->hasMany(FeedLike::class, 'feed_id');
    }

    public function getIsLikedByMeAttribute(): bool
    {
        $userId = auth()->id();
        if (!$userId) return false;
        return $this->feedLikes()->where('user_id', $userId)->exists();
    }
}

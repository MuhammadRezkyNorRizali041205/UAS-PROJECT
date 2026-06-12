<?php
// app/Models/SocialFeed.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class SocialFeed extends Model
{
    public $incrementing = false;
    protected $keyType   = 'string';

    protected $fillable = [
        'id', 'user_id', 'type', 'title', 'description',
        'achievement_data', 'visibility', 'likes_count',
    ];

    protected function casts(): array
    {
        return [
            'achievement_data' => 'array',
            'likes_count'      => 'integer',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (SocialFeed $feed) {
            if (empty($feed->id)) {
                $feed->id = (string) Str::uuid();
            }
        });
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

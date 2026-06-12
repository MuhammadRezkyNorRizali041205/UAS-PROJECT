<?php
// app/Models/FeedLike.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class FeedLike extends Model
{
    public $incrementing = false;
    public $timestamps   = false;
    protected $keyType   = 'string';

    protected $fillable = ['id', 'feed_id', 'user_id'];

    const CREATED_AT = 'created_at';
    const UPDATED_AT = null;

    protected function casts(): array
    {
        return ['created_at' => 'datetime'];
    }

    protected static function booted(): void
    {
        static::creating(function (FeedLike $like) {
            if (empty($like->id)) {
                $like->id = (string) Str::uuid();
            }
        });
    }

    public function feed(): BelongsTo
    {
        return $this->belongsTo(SocialFeed::class, 'feed_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

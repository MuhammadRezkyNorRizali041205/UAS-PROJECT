<?php
// app/Models/FeedLike.php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FeedLike extends Model
{
    use HasUuid;

    public $timestamps   = false;

    const CREATED_AT = 'created_at';
    const UPDATED_AT = null;

    protected $fillable = ['feed_id', 'user_id'];

    protected function casts(): array
    {
        return ['created_at' => 'datetime'];
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

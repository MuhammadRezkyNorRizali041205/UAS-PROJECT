<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Builder;

class Announcement extends Model
{
    protected $fillable = [
        'author_id', 'title', 'body', 'category',
        'is_urgent', 'is_published', 'published_at',
    ];

    protected function casts(): array
    {
        return [
            'is_urgent'    => 'boolean',
            'is_published' => 'boolean',
            'published_at' => 'datetime',
        ];
    }

    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'author_id');
    }

    public function bookmarkedByUsers(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'announcement_bookmarks')
            ->withPivot('created_at');
    }

    public function scopePublished(Builder $query): Builder
    {
        return $query->where('is_published', true)
            ->orderBy('published_at', 'desc');
    }

    public function scopeByCategory(Builder $query, string $category): Builder
    {
        return $query->where('category', $category);
    }
}

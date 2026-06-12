<?php
// app/Services/SocialFeedService.php

namespace App\Services;

use App\Models\FeedLike;
use App\Models\SocialFeed;
use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Str;

class SocialFeedService
{
    public function getFeed(User $viewer, int $perPage = 20): LengthAwarePaginator
    {
        return SocialFeed::with('user:id,name')
            ->where(function ($q) use ($viewer) {
                $q->where('visibility', 'public')
                  ->orWhere('user_id', $viewer->id);
            })
            ->orderByDesc('created_at')
            ->paginate($perPage);
    }

    public function getMyFeed(User $user, int $perPage = 20): LengthAwarePaginator
    {
        return SocialFeed::with('user:id,name')
            ->where('user_id', $user->id)
            ->orderByDesc('created_at')
            ->paginate($perPage);
    }

    public function createFeedPost(User $user, array $data): SocialFeed
    {
        return SocialFeed::create([
            'id'               => Str::uuid(),
            'user_id'          => $user->id,
            'type'             => $data['type'],
            'title'            => $data['title'],
            'description'      => $data['description'] ?? '',
            'achievement_data' => $data['achievement_data'] ?? null,
            'visibility'       => $data['visibility'] ?? 'public',
        ]);
    }

    public function toggleLike(User $user, string $feedId): array
    {
        $feed = SocialFeed::findOrFail($feedId);

        $existing = FeedLike::where('feed_id', $feedId)
            ->where('user_id', $user->id)
            ->first();

        if ($existing) {
            $existing->delete();
            $feed->decrement('likes_count');
            $liked = false;
        } else {
            FeedLike::create([
                'id'      => Str::uuid(),
                'feed_id' => $feedId,
                'user_id' => $user->id,
            ]);
            $feed->increment('likes_count');
            $liked = true;
        }

        return [
            'liked'       => $liked,
            'likes_count' => $feed->fresh()->likes_count,
        ];
    }

    public function formatPost(SocialFeed $post, User $viewer): array
    {
        return [
            'id'               => $post->id,
            'user'             => [
                'id'   => $post->user->id,
                'name' => $post->user->name,
            ],
            'type'             => $post->type,
            'title'            => $post->title,
            'description'      => $post->description,
            'achievement_data' => $post->achievement_data,
            'visibility'       => $post->visibility,
            'likes_count'      => $post->likes_count,
            'is_liked'         => FeedLike::where('feed_id', $post->id)
                ->where('user_id', $viewer->id)
                ->exists(),
            'created_at'       => $post->created_at,
        ];
    }
}

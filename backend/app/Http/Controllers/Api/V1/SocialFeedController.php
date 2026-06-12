<?php
// app/Http/Controllers/Api/V1/SocialFeedController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\SocialFeedService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SocialFeedController extends Controller
{
    public function __construct(private readonly SocialFeedService $feed) {}

    // GET /api/v1/feed
    public function index(Request $request): JsonResponse
    {
        $paginator = $this->feed->getFeed($request->user(), 20);
        $viewer    = $request->user();

        return response()->json([
            'data'         => $paginator->map(fn($p) => $this->feed->formatPost($p, $viewer)),
            'current_page' => $paginator->currentPage(),
            'last_page'    => $paginator->lastPage(),
            'per_page'     => $paginator->perPage(),
            'total'        => $paginator->total(),
        ]);
    }

    // GET /api/v1/feed/my
    public function myFeed(Request $request): JsonResponse
    {
        $paginator = $this->feed->getMyFeed($request->user(), 20);
        $viewer    = $request->user();

        return response()->json([
            'data'         => $paginator->map(fn($p) => $this->feed->formatPost($p, $viewer)),
            'current_page' => $paginator->currentPage(),
            'last_page'    => $paginator->lastPage(),
        ]);
    }

    // POST /api/v1/feed
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'type'             => 'required|in:task_completed,streak_milestone,badge_earned,level_up',
            'title'            => 'required|string|max:200',
            'description'      => 'sometimes|string|max:1000',
            'achievement_data' => 'sometimes|array',
            'visibility'       => 'sometimes|in:public,friends',
        ]);

        $post = $this->feed->createFeedPost($request->user(), $request->all());

        return response()->json([
            'message' => 'Post created',
            'data'    => $this->feed->formatPost($post->load('user'), $request->user()),
        ], 201);
    }

    // POST /api/v1/feed/{id}/like
    public function like(Request $request, string $id): JsonResponse
    {
        $result = $this->feed->toggleLike($request->user(), $id);

        return response()->json($result);
    }
}

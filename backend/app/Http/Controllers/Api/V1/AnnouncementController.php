<?php
// app/Http/Controllers/Api/V1/AnnouncementController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\AnnouncementResource;
use App\Models\Announcement;
use App\Models\UserActivity;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AnnouncementController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $category = $request->query('category', 'all');

        $query = Announcement::with('author')
            ->where('is_published', true)
            ->where(function ($q) {
                $q->whereNull('expires_at')
                  ->orWhere('expires_at', '>', now());
            })
            ->orderByDesc('is_urgent')
            ->orderByDesc('published_at');

        if ($category && $category !== 'all') {
            $query->where('category', $category);
        }

        $items = $query->paginate(15);

        // Log activity when reading announcements
        UserActivity::create([
            'user_id'       => $request->user()->id,
            'type'          => 'read_announcement',
            'activity_date' => now()->toDateString(),
            'meta'          => ['source' => 'feed'],
        ]);

        return $this->success(
            AnnouncementResource::collection($items)->response()->getData(true),
            'Daftar pengumuman.',
        );
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $announcement = Announcement::with('author')
            ->where('is_published', true)
            ->find($id);

        if (!$announcement) {
            return $this->error('Pengumuman tidak ditemukan.', 404);
        }

        return $this->success(
            new AnnouncementResource($announcement, full: true),
        );
    }

    public function store(Request $request): JsonResponse
    {
        // Only admin and org_admin may post
        if (!in_array($request->user()->role, ['admin', 'org_admin'])) {
            return $this->error('Tidak memiliki akses.', 403);
        }

        $validated = $request->validate([
            'title'      => ['required', 'string', 'max:255'],
            'body'       => ['required', 'string'],
            'category'   => ['required', 'in:academic,event,seminar,urgent,general'],
            'is_urgent'  => ['boolean'],
            'expires_at' => ['nullable', 'date', 'after:now'],
        ]);

        $announcement = Announcement::create(array_merge($validated, [
            'author_id'    => $request->user()->id,
            'is_published' => true,
            'published_at' => now(),
        ]));

        return $this->success(
            new AnnouncementResource($announcement->load('author'), full: true),
            'Pengumuman berhasil dibuat.',
            201,
        );
    }
}

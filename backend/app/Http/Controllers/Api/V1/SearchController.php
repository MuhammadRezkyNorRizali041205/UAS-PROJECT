<?php
// app/Http/Controllers/Api/V1/SearchController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Announcement;
use App\Models\Schedule;
use App\Models\Task;
use App\Models\User;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class SearchController extends Controller
{
    use ApiResponse;

    private const DAY_NAMES = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

    public function search(Request $request): JsonResponse
    {
        $query = trim((string) $request->query('q', ''));
        $type  = $request->query('type', 'all');
        $user  = $request->user();

        if (mb_strlen($query) < 2) {
            return $this->error('Kata kunci minimal 2 karakter.', 422);
        }

        $cacheKey = "search:{$user->id}:{$type}:" . md5($query);

        $results = Cache::remember($cacheKey, 60, function () use ($query, $type, $user) {
            $like = "%{$query}%";
            return [
                'schedules'     => $this->searchSchedules($like, $user->id, $type),
                'tasks'         => $this->searchTasks($like, $user->id, $type),
                'users'         => $this->searchUsers($like, $user->id, $type),
                'announcements' => $this->searchAnnouncements($like, $type),
            ];
        });

        $total = array_sum(array_map('count', $results));

        return $this->success(data: [
            'query'   => $query,
            'results' => $results,
            'total'   => $total,
        ]);
    }

    private function searchSchedules(string $like, int $userId, string $type): array
    {
        if ($type !== 'all' && $type !== 'schedule') return [];

        return Schedule::where('user_id', $userId)
            ->where('is_active', true)
            ->where(fn ($q) => $q
                ->where('title', 'like', $like)
                ->orWhere('lecturer', 'like', $like)
                ->orWhere('room', 'like', $like)
            )
            ->limit(8)
            ->get()
            ->map(fn ($s) => [
                'id'         => $s->id,
                'title'      => $s->title,
                'category'   => $s->category,
                'day_name'   => self::DAY_NAMES[$s->day_of_week] ?? '-',
                'start_time' => $s->start_time,
                'end_time'   => $s->end_time,
                'room'       => $s->room,
                'lecturer'   => $s->lecturer,
                'type'       => 'schedule',
            ])
            ->toArray();
    }

    private function searchTasks(string $like, int $userId, string $type): array
    {
        if ($type !== 'all' && $type !== 'task') return [];

        return Task::where('user_id', $userId)
            ->where(fn ($q) => $q
                ->where('title', 'like', $like)
                ->orWhere('description', 'like', $like)
            )
            ->orderBy('deadline')
            ->limit(8)
            ->get()
            ->map(fn ($t) => [
                'id'       => $t->id,
                'title'    => $t->title,
                'priority' => $t->priority,
                'deadline' => $t->deadline?->toIso8601String(),
                'status'   => $t->status,
                'type'     => 'task',
            ])
            ->toArray();
    }

    private function searchUsers(string $like, int $userId, string $type): array
    {
        if ($type !== 'all' && $type !== 'user') return [];

        return User::with('profile')
            ->where('id', '!=', $userId)
            ->where('is_active', true)
            ->where(fn ($q) => $q
                ->where('name', 'like', $like)
                ->orWhere('email', 'like', $like)
                ->orWhereHas('profile', fn ($p) => $p->where('student_id', 'like', $like))
            )
            ->limit(8)
            ->get()
            ->map(fn ($u) => [
                'id'         => $u->id,
                'name'       => $u->name,
                'nim'        => $u->profile?->student_id,
                'avatar_url' => $u->profile?->avatar_url,
                'role'       => $u->role,
                'type'       => 'user',
            ])
            ->toArray();
    }

    private function searchAnnouncements(string $like, string $type): array
    {
        if ($type !== 'all' && $type !== 'announcement') return [];

        return Announcement::published()
            ->where(fn ($q) => $q
                ->where('title', 'like', $like)
                ->orWhere('body', 'like', $like)
            )
            ->limit(8)
            ->get()
            ->map(fn ($a) => [
                'id'           => $a->id,
                'title'        => $a->title,
                'category'     => $a->category,
                'is_urgent'    => $a->is_urgent,
                'published_at' => $a->published_at?->toIso8601String(),
                'type'         => 'announcement',
            ])
            ->toArray();
    }
}

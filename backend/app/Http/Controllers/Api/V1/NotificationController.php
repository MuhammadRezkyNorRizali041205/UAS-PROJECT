<?php
// app/Http/Controllers/Api/V1/NotificationController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\NotificationLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $type = $request->query('type');

        $query = NotificationLog::where('user_id', $request->user()->id)
            ->orderByDesc('sent_at');

        if ($type && $type !== 'all') {
            $query->where('type', $type);
        }

        $items = $query->paginate(20);

        return $this->success(
            $items->through(fn ($n) => $this->formatNotification($n))
                  ->toArray(),
            'Daftar notifikasi.',
        );
    }

    public function unreadCount(Request $request): JsonResponse
    {
        $count = NotificationLog::where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->count();

        return $this->success(['count' => $count]);
    }

    public function markRead(Request $request, int $id): JsonResponse
    {
        $notification = NotificationLog::where('user_id', $request->user()->id)
            ->find($id);

        if (!$notification) {
            return $this->error('Notifikasi tidak ditemukan.', 404);
        }

        if (!$notification->read_at) {
            $notification->update(['read_at' => now()]);
        }

        return $this->success($this->formatNotification($notification));
    }

    public function markAllRead(Request $request): JsonResponse
    {
        NotificationLog::where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return $this->success(null, 'Semua notifikasi telah ditandai dibaca.');
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $notification = NotificationLog::where('user_id', $request->user()->id)
            ->find($id);

        if (!$notification) {
            return $this->error('Notifikasi tidak ditemukan.', 404);
        }

        $notification->delete();

        return $this->success(null, 'Notifikasi dihapus.');
    }

    private function formatNotification(NotificationLog $n): array
    {
        return [
            'id'           => $n->id,
            'type'         => $n->type,
            'title'        => $n->title,
            'body'         => $n->body,
            'data'         => $n->data,
            'is_read'      => (bool) $n->read_at,
            'read_at'      => $n->read_at?->toIso8601String(),
            'sent_at'      => $n->sent_at?->toIso8601String(),
            'sent_at_human'=> $n->sent_at?->diffForHumans(),
        ];
    }
}

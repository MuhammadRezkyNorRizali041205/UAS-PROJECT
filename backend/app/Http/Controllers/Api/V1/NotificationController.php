<?php
// app/Http/Controllers/Api/V1/NotificationController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\NotificationLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\StreamedResponse;

class NotificationController extends Controller
{
    // ── SSE Stream ────────────────────────────────────────────────────────────

    public function stream(Request $request): StreamedResponse
    {
        $userId  = $request->user()->id;
        $lastId  = (int) $request->header('Last-Event-ID', 0);

        return response()->stream(function () use ($userId, $lastId) {
            // Konfirmasi koneksi
            echo "event: connected\n";
            echo "data: {\"message\":\"SSE connected\"}\n\n";
            ob_flush();
            flush();

            $iteration = 0;

            while (true) {
                if (connection_aborted()) break;

                $notifications = NotificationLog::where('user_id', $userId)
                    ->when($lastId > 0, fn ($q) => $q->where('id', '>', $lastId))
                    ->whereNull('read_at')
                    ->orderBy('id')
                    ->limit(10)
                    ->get();

                foreach ($notifications as $notif) {
                    echo "id: {$notif->id}\n";
                    echo "event: notification\n";
                    echo 'data: ' . json_encode([
                        'id'       => $notif->id,
                        'type'     => $notif->type,
                        'title'    => $notif->title,
                        'body'     => $notif->body,
                        'data'     => $notif->data,
                        'sent_at'  => $notif->sent_at?->toIso8601String(),
                    ]) . "\n\n";
                    $lastId = $notif->id;
                    ob_flush();
                    flush();
                }

                // Heartbeat setiap ~30 detik agar koneksi tidak putus
                if ($iteration % 15 === 0) {
                    echo ": heartbeat\n\n";
                    ob_flush();
                    flush();
                }

                $iteration++;
                sleep(2);
            }
        }, 200, [
            'Content-Type'      => 'text/event-stream',
            'Cache-Control'     => 'no-cache',
            'X-Accel-Buffering' => 'no',
            'Connection'        => 'keep-alive',
        ]);
    }

    // ── REST ─────────────────────────────────────────────────────────────────

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

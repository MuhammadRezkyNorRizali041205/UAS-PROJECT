<?php
// app/Repositories/Eloquent/AttendanceRepository.php

namespace App\Repositories\Eloquent;

use App\Models\AttendanceLog;
use App\Models\AttendanceSession;
use App\Models\User;
use App\Repositories\Contracts\AttendanceRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class AttendanceRepository implements AttendanceRepositoryInterface
{
    public function createSession(array $data): AttendanceSession
    {
        return AttendanceSession::create($data);
    }

    public function findSessionByCode(string $code): ?AttendanceSession
    {
        return AttendanceSession::with('creator')
            ->where('session_code', $code)
            ->first();
    }

    public function findSessionById(int $id): ?AttendanceSession
    {
        return AttendanceSession::with('creator')->find($id);
    }

    public function hasScanned(int $sessionId, int $userId): bool
    {
        return AttendanceLog::where('session_id', $sessionId)
            ->where('user_id', $userId)
            ->exists();
    }

    public function recordScan(int $sessionId, int $userId, ?string $ip): AttendanceLog
    {
        return AttendanceLog::create([
            'session_id' => $sessionId,
            'user_id'    => $userId,
            'ip_address' => $ip,
        ]);
    }

    public function getActiveSessions(): Collection
    {
        return AttendanceSession::with('creator')
            ->where('is_active', true)
            ->where('ends_at', '>=', now())
            ->orderByDesc('starts_at')
            ->get();
    }

    public function getHistory(User $user): Collection
    {
        return AttendanceLog::with('session')
            ->where('user_id', $user->id)
            ->orderByDesc('scanned_at')
            ->get();
    }

    public function getStats(User $user): array
    {
        $total      = AttendanceLog::where('user_id', $user->id)->count();
        $thisMonth  = AttendanceLog::where('user_id', $user->id)
            ->whereMonth('scanned_at', now()->month)
            ->whereYear('scanned_at', now()->year)
            ->count();
        $thisWeek   = AttendanceLog::where('user_id', $user->id)
            ->whereBetween('scanned_at', [now()->startOfWeek(), now()->endOfWeek()])
            ->count();

        return compact('total', 'thisMonth', 'thisWeek');
    }

    public function getSessionAttendees(AttendanceSession $session): Collection
    {
        return AttendanceLog::with('user')
            ->where('session_id', $session->id)
            ->orderBy('scanned_at')
            ->get();
    }
}

<?php
// app/Services/AttendanceService.php

namespace App\Services;

use App\Models\AttendanceLog;
use App\Models\AttendanceSession;
use App\Models\User;
use App\Repositories\Contracts\AttendanceRepositoryInterface;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Validation\ValidationException;

class AttendanceService
{
    public function __construct(private readonly AttendanceRepositoryInterface $repo) {}

    public function createSession(User $user, array $data): AttendanceSession
    {
        return $this->repo->createSession(array_merge($data, [
            'creator_id' => $user->id,
        ]));
    }

    public function getSession(string $code): AttendanceSession
    {
        $session = $this->repo->findSessionByCode($code);

        if (!$session) {
            throw new AuthorizationException('Sesi tidak ditemukan.');
        }

        return $session;
    }

    public function scan(User $user, string $code): AttendanceLog
    {
        $session = $this->getSession($code);

        if (!$session->isActive()) {
            throw ValidationException::withMessages([
                'code' => ['Sesi presensi tidak aktif atau sudah berakhir.'],
            ]);
        }

        if ($this->repo->hasScanned($session->id, $user->id)) {
            throw ValidationException::withMessages([
                'code' => ['Kamu sudah melakukan presensi untuk sesi ini.'],
            ]);
        }

        return $this->repo->recordScan($session->id, $user->id, request()->ip());
    }

    public function listSessions(): Collection
    {
        return $this->repo->getActiveSessions();
    }

    public function getHistory(User $user): Collection
    {
        return $this->repo->getHistory($user);
    }

    public function getStats(User $user): array
    {
        return $this->repo->getStats($user);
    }

    public function getSessionAttendees(User $user, int $sessionId): Collection
    {
        $session = $this->repo->findSessionById($sessionId);

        if (!$session || $session->creator_id !== $user->id) {
            throw new AuthorizationException('Sesi tidak ditemukan.');
        }

        return $this->repo->getSessionAttendees($session);
    }
}

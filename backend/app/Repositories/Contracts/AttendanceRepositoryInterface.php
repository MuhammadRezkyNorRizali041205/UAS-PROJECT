<?php
// app/Repositories/Contracts/AttendanceRepositoryInterface.php

namespace App\Repositories\Contracts;

use App\Models\AttendanceLog;
use App\Models\AttendanceSession;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

interface AttendanceRepositoryInterface
{
    public function createSession(array $data): AttendanceSession;

    public function findSessionByCode(string $code): ?AttendanceSession;

    public function findSessionById(int $id): ?AttendanceSession;

    public function hasScanned(int $sessionId, int $userId): bool;

    public function recordScan(int $sessionId, int $userId, ?string $ip): AttendanceLog;

    public function getActiveSessions(): Collection;

    public function getHistory(User $user): Collection;

    public function getStats(User $user): array;

    public function getSessionAttendees(AttendanceSession $session): Collection;
}

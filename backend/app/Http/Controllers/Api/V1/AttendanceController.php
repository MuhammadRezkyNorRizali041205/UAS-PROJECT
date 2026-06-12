<?php
// app/Http/Controllers/Api/V1/AttendanceController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Attendance\StoreSessionRequest;
use App\Http\Resources\AttendanceResource;
use App\Http\Resources\SessionResource;
use App\Services\AttendanceService;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class AttendanceController extends Controller
{
    public function __construct(private readonly AttendanceService $service) {}

    public function listSessions(Request $request): JsonResponse
    {
        $sessions = $this->service->listSessions();

        return $this->success(SessionResource::collection($sessions), 'Daftar sesi presensi aktif.');
    }

    public function createSession(StoreSessionRequest $request): JsonResponse
    {
        $session = $this->service->createSession($request->user(), $request->validated());

        return $this->success(new SessionResource($session), 'Sesi presensi dibuat.', 201);
    }

    public function showSession(Request $request, string $code): JsonResponse
    {
        try {
            $session = $this->service->getSession($code);
            return $this->success(new SessionResource($session->loadMissing('creator', 'logs')));
        } catch (AuthorizationException $e) {
            return $this->error($e->getMessage(), 404);
        }
    }

    public function scan(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'code' => ['required', 'string'],
            ]);

            $log = $this->service->scan($request->user(), $validated['code']);

            return $this->success(
                new AttendanceResource($log->load('session')),
                'Presensi berhasil dicatat.',
                201,
            );
        } catch (ValidationException $e) {
            return $this->error(
                collect($e->errors())->flatten()->first() ?? 'Validasi gagal.',
                422,
            );
        } catch (AuthorizationException $e) {
            return $this->error($e->getMessage(), 404);
        }
    }

    public function history(Request $request): JsonResponse
    {
        $logs = $this->service->getHistory($request->user());

        return $this->success(
            AttendanceResource::collection($logs),
            'Riwayat presensi.',
        );
    }

    public function stats(Request $request): JsonResponse
    {
        $stats = $this->service->getStats($request->user());

        return $this->success($stats, 'Statistik presensi.');
    }

    public function sessionAttendees(Request $request, int $id): JsonResponse
    {
        try {
            $logs = $this->service->getSessionAttendees($request->user(), $id);

            return $this->success(
                $logs->map(fn ($log) => [
                    'user'       => ['id' => $log->user->id, 'name' => $log->user->name],
                    'scanned_at' => $log->scanned_at->toIso8601String(),
                ]),
                'Daftar hadir.',
            );
        } catch (AuthorizationException $e) {
            return $this->error($e->getMessage(), 404);
        }
    }
}

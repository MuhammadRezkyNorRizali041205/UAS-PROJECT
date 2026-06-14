<?php
// app/Http/Controllers/Api/V1/Lecturer/LecturerAttendanceController.php

namespace App\Http\Controllers\Api\V1\Lecturer;

use App\Http\Controllers\Controller;
use App\Models\AttendanceSession;
use App\Models\ClassRoom;
use App\Services\LecturerService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LecturerAttendanceController extends Controller
{
    use ApiResponse;

    public function __construct(private LecturerService $service) {}

    public function index(Request $request, string $classId): JsonResponse
    {
        $class    = ClassRoom::where('lecturer_id', $request->user()->id)->findOrFail($classId);
        $sessions = $this->service->getAttendanceSessions($class);
        return $this->success(data: $sessions);
    }

    public function store(Request $request, string $classId): JsonResponse
    {
        $class = ClassRoom::where('lecturer_id', $request->user()->id)->findOrFail($classId);

        $data = $request->validate([
            'title'       => 'required|string|max:255',
            'valid_from'  => 'nullable|date',
            'valid_until' => 'nullable|date',
        ]);

        $session = $this->service->createAttendanceSession($class, $request->user(), $data);
        $detail  = $this->service->getAttendanceDetail($session);
        return $this->success(data: $detail, message: 'Sesi absensi dimulai.', code: 201);
    }

    public function show(Request $request, int $sessionId): JsonResponse
    {
        $session = AttendanceSession::findOrFail($sessionId);

        $class = $session->class_id ? ClassRoom::find($session->class_id) : null;
        if ($class && $class->lecturer_id !== $request->user()->id) {
            return $this->error('Akses ditolak.', 403);
        }

        $detail = $this->service->getAttendanceDetail($session);
        return $this->success(data: $detail);
    }

    public function close(Request $request, int $sessionId): JsonResponse
    {
        $session = AttendanceSession::findOrFail($sessionId);

        $class = $session->class_id ? ClassRoom::find($session->class_id) : null;
        if ($class && $class->lecturer_id !== $request->user()->id) {
            return $this->error('Akses ditolak.', 403);
        }

        $this->service->closeAttendanceSession($session);
        return $this->success(message: 'Sesi absensi ditutup.');
    }
}

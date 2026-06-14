<?php
// app/Http/Controllers/Api/V1/Lecturer/LecturerStudentController.php

namespace App\Http\Controllers\Api\V1\Lecturer;

use App\Http\Controllers\Controller;
use App\Models\ClassRoom;
use App\Models\User;
use App\Services\LecturerService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LecturerStudentController extends Controller
{
    use ApiResponse;

    public function __construct(private LecturerService $service) {}

    public function index(Request $request, string $classId): JsonResponse
    {
        $class    = ClassRoom::where('lecturer_id', $request->user()->id)->findOrFail($classId);
        $students = $this->service->getStudentsWithRisk($class);
        return $this->success(data: $students);
    }

    public function progress(Request $request, string $classId, string $studentId): JsonResponse
    {
        $class    = ClassRoom::where('lecturer_id', $request->user()->id)->findOrFail($classId);
        $student  = User::with('profile')->findOrFail($studentId);
        $progress = $this->service->getStudentProgress($class, $student);
        return $this->success(data: $progress);
    }
}

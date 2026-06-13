<?php
// app/Http/Controllers/Api/V1/Lecturer/LecturerClassController.php

namespace App\Http\Controllers\Api\V1\Lecturer;

use App\Http\Controllers\Controller;
use App\Models\ClassRoom;
use App\Services\LecturerService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LecturerClassController extends Controller
{
    use ApiResponse;

    public function __construct(private LecturerService $service) {}

    public function index(Request $request): JsonResponse
    {
        $classes = $this->service->getClasses($request->user());
        return $this->success(data: $classes);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name'          => 'required|string|max:255',
            'course_name'   => 'required|string|max:255',
            'course_code'   => 'required|string|max:20',
            'semester'      => 'required|integer|min:1|max:8',
            'academic_year' => 'required|string|max:20',
            'description'   => 'nullable|string',
            'max_students'  => 'nullable|integer|min:1|max:200',
        ]);

        $class = $this->service->createClass($request->user(), $data);
        return $this->success(data: $class, message: 'Kelas berhasil dibuat.', statusCode: 201);
    }

    public function show(Request $request, string $id): JsonResponse
    {
        $class = ClassRoom::where('lecturer_id', $request->user()->id)
            ->findOrFail($id);

        $detail = $this->service->getClassDetail($class);
        return $this->success(data: $detail);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $class = ClassRoom::where('lecturer_id', $request->user()->id)->findOrFail($id);

        $data = $request->validate([
            'name'          => 'sometimes|string|max:255',
            'course_name'   => 'sometimes|string|max:255',
            'course_code'   => 'sometimes|string|max:20',
            'semester'      => 'sometimes|integer|min:1|max:8',
            'academic_year' => 'sometimes|string|max:20',
            'description'   => 'nullable|string',
            'max_students'  => 'nullable|integer|min:1|max:200',
            'is_active'     => 'sometimes|boolean',
        ]);

        $class->update($data);
        return $this->success(data: $class, message: 'Kelas berhasil diperbarui.');
    }

    public function destroy(Request $request, string $id): JsonResponse
    {
        $class = ClassRoom::where('lecturer_id', $request->user()->id)->findOrFail($id);
        $class->delete();
        return $this->success(message: 'Kelas berhasil dihapus.');
    }

    public function enrollStudent(Request $request, string $id): JsonResponse
    {
        $class = ClassRoom::where('lecturer_id', $request->user()->id)->findOrFail($id);

        $request->validate(['identifier' => 'required|string']);

        try {
            $enrollment = $this->service->enrollStudent($class, $request->identifier);
            return $this->success(data: $enrollment, message: 'Mahasiswa berhasil ditambahkan.', statusCode: 201);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException) {
            return $this->error('Mahasiswa tidak ditemukan.', 404);
        }
    }

    public function removeStudent(Request $request, string $id, string $studentId): JsonResponse
    {
        $class = ClassRoom::where('lecturer_id', $request->user()->id)->findOrFail($id);

        $enrollment = $class->enrollments()
            ->where('student_id', $studentId)
            ->firstOrFail();

        $enrollment->update(['status' => 'dropped']);

        return $this->success(message: 'Mahasiswa berhasil dikeluarkan dari kelas.');
    }
}

<?php
// app/Http/Controllers/Api/V1/Lecturer/LecturerTaskController.php

namespace App\Http\Controllers\Api\V1\Lecturer;

use App\Http\Controllers\Controller;
use App\Models\ClassRoom;
use App\Models\ClassTask;
use App\Models\ClassTaskSubmission;
use App\Services\LecturerService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LecturerTaskController extends Controller
{
    use ApiResponse;

    public function __construct(private LecturerService $service) {}

    public function index(Request $request, string $classId): JsonResponse
    {
        $class = ClassRoom::where('lecturer_id', $request->user()->id)->findOrFail($classId);

        $tasks = $class->classTasks()
            ->withCount(['submissions as submitted_count' => fn ($q) =>
                $q->whereIn('status', ['submitted', 'graded', 'late'])
            ])
            ->withCount(['submissions as graded_count' => fn ($q) =>
                $q->where('status', 'graded')
            ])
            ->orderBy('deadline')
            ->get();

        return $this->success(data: $tasks);
    }

    public function store(Request $request, string $classId): JsonResponse
    {
        $class = ClassRoom::where('lecturer_id', $request->user()->id)->findOrFail($classId);

        $data = $request->validate([
            'title'          => 'required|string|max:255',
            'description'    => 'nullable|string',
            'deadline'       => 'required|date|after:now',
            'max_score'      => 'nullable|integer|min:1|max:100',
            'attachment_url' => 'nullable|url',
        ]);

        $task = $this->service->createClassTask($class, $request->user(), $data);
        return $this->success(data: $task, message: 'Tugas berhasil dibuat.', code: 201);
    }

    public function show(Request $request, string $id): JsonResponse
    {
        $task = ClassTask::whereHas('classRoom', fn ($q) =>
            $q->where('lecturer_id', $request->user()->id)
        )->findOrFail($id);

        return $this->success(data: array_merge($task->toArray(), [
            'submitted_count' => $task->submitted_count,
            'graded_count'    => $task->graded_count,
        ]));
    }

    public function submissions(Request $request, string $id): JsonResponse
    {
        $task = ClassTask::whereHas('classRoom', fn ($q) =>
            $q->where('lecturer_id', $request->user()->id)
        )->findOrFail($id);

        $result      = $this->service->getSubmissions($task);
        $submissions = $result['submissions'];

        $filter = $request->query('filter');
        if ($filter === 'ungraded') {
            $submissions = array_values(array_filter($submissions, fn ($s) => $s['status'] === 'submitted'));
        } elseif ($filter === 'graded') {
            $submissions = array_values(array_filter($submissions, fn ($s) => $s['status'] === 'graded'));
        } elseif ($filter === 'late') {
            $submissions = array_values(array_filter($submissions, fn ($s) => $s['status'] === 'late'));
        } elseif ($filter === 'pending') {
            $submissions = array_values(array_filter($submissions, fn ($s) => $s['status'] === 'pending'));
        }

        return $this->success(data: ['submissions' => $submissions, 'summary' => $result['summary']]);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $task = ClassTask::whereHas('classRoom', fn ($q) =>
            $q->where('lecturer_id', $request->user()->id)
        )->findOrFail($id);

        $data = $request->validate([
            'title'          => 'sometimes|string|max:255',
            'description'    => 'nullable|string',
            'deadline'       => 'sometimes|date',
            'max_score'      => 'nullable|integer|min:1|max:1000',
            'attachment_url' => 'nullable|url',
        ]);

        $task->update($data);
        return $this->success(data: $task->fresh(), message: 'Tugas berhasil diperbarui.');
    }

    public function destroy(Request $request, string $id): JsonResponse
    {
        $task = ClassTask::whereHas('classRoom', fn ($q) =>
            $q->where('lecturer_id', $request->user()->id)
        )->findOrFail($id);

        $task->delete();
        return $this->success(message: 'Tugas berhasil dihapus.');
    }

    public function grade(Request $request, string $submissionId): JsonResponse
    {
        $submission = ClassTaskSubmission::whereHas('classTask.classRoom', fn ($q) =>
            $q->where('lecturer_id', $request->user()->id)
        )->findOrFail($submissionId);

        $data = $request->validate([
            'score'    => 'required|integer|min:0|max:' . $submission->classTask->max_score,
            'feedback' => 'nullable|string|max:1000',
        ]);

        $this->service->gradeSubmission($submission, $data['score'], $data['feedback'] ?? null);

        return $this->success(data: $submission->fresh(), message: 'Penilaian berhasil disimpan.');
    }
}

<?php
// app/Http/Controllers/Api/V1/StudentClassController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ClassRoom;
use App\Models\ClassTask;
use App\Models\ClassTaskSubmission;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudentClassController extends Controller
{
    use ApiResponse;

    public function myClasses(Request $request): JsonResponse
    {
        $classes = ClassRoom::whereHas('enrollments', fn ($q) =>
            $q->where('student_id', $request->user()->id)->where('status', 'active')
        )->with('lecturer.profile')->get()->map(fn ($c) => [
            'id'            => $c->id,
            'name'          => $c->name,
            'course_name'   => $c->course_name,
            'course_code'   => $c->course_code,
            'semester'      => $c->semester,
            'academic_year' => $c->academic_year,
            'lecturer_name' => $c->lecturer->name,
            'pending_tasks' => $this->pendingTaskCount($c, $request->user()->id),
        ]);

        return $this->success(data: $classes);
    }

    public function classDetail(Request $request, string $classId): JsonResponse
    {
        $class = ClassRoom::whereHas('enrollments', fn ($q) =>
            $q->where('student_id', $request->user()->id)->where('status', 'active')
        )->with('lecturer.profile')->findOrFail($classId);

        $tasks = $class->classTasks()->orderBy('deadline')->get()->map(function ($task) use ($request) {
            $submission = ClassTaskSubmission::where('class_task_id', $task->id)
                ->where('student_id', $request->user()->id)
                ->first();

            return [
                'id'             => $task->id,
                'title'          => $task->title,
                'description'    => $task->description,
                'deadline'       => $task->deadline->toIso8601String(),
                'max_score'      => $task->max_score,
                'attachment_url' => $task->attachment_url,
                'status'         => $submission?->status ?? 'pending',
                'submission'     => $submission ? [
                    'id'             => $submission->id,
                    'content'        => $submission->content,
                    'attachment_url' => $submission->attachment_url,
                    'score'          => $submission->score,
                    'feedback'       => $submission->feedback,
                    'submitted_at'   => $submission->submitted_at?->toIso8601String(),
                    'letter_grade'   => $submission->letter_grade,
                ] : null,
            ];
        });

        return $this->success(data: [
            'class'  => [
                'id'            => $class->id,
                'name'          => $class->name,
                'course_name'   => $class->course_name,
                'course_code'   => $class->course_code,
                'semester'      => $class->semester,
                'academic_year' => $class->academic_year,
                'description'   => $class->description,
                'lecturer_name' => $class->lecturer->name,
            ],
            'tasks'  => $tasks,
        ]);
    }

    public function submitTask(Request $request, string $taskId): JsonResponse
    {
        $task = ClassTask::whereHas('classRoom.enrollments', fn ($q) =>
            $q->where('student_id', $request->user()->id)->where('status', 'active')
        )->findOrFail($taskId);

        $data = $request->validate([
            'content'        => 'nullable|string',
            'attachment_url' => 'nullable|url',
        ]);

        if (empty($data['content']) && empty($data['attachment_url'])) {
            return $this->error('Konten atau attachment wajib diisi.', 422);
        }

        $isLate   = now()->isAfter($task->deadline);
        $status   = $isLate ? 'late' : 'submitted';

        $submission = ClassTaskSubmission::updateOrCreate(
            ['class_task_id' => $taskId, 'student_id' => $request->user()->id],
            array_merge($data, [
                'status'       => $status,
                'submitted_at' => now(),
            ])
        );

        return $this->success(
            data:       $submission,
            message:    $isLate ? 'Tugas dikumpulkan (terlambat).' : 'Tugas berhasil dikumpulkan.',
            statusCode: 201
        );
    }

    private function pendingTaskCount(ClassRoom $class, int $studentId): int
    {
        return $class->classTasks()
            ->whereDoesntHave('submissions', fn ($q) =>
                $q->where('student_id', $studentId)
                  ->whereIn('status', ['submitted', 'graded', 'late'])
            )
            ->where('deadline', '>', now())
            ->count();
    }
}

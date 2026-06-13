<?php
// app/Services/LecturerService.php

namespace App\Services;

use App\Models\ClassRoom;
use App\Models\ClassEnrollment;
use App\Models\ClassTask;
use App\Models\ClassTaskSubmission;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class LecturerService
{
    public function getDashboardStats(User $lecturer): array
    {
        $classIds = ClassRoom::where('lecturer_id', $lecturer->id)
            ->where('is_active', true)
            ->pluck('id');

        $totalStudents = ClassEnrollment::whereIn('class_id', $classIds)
            ->where('status', 'active')
            ->distinct('student_id')
            ->count();

        $pendingGrading = ClassTaskSubmission::whereIn(
            'class_task_id',
            ClassTask::whereIn('class_id', $classIds)->pluck('id')
        )->where('status', 'submitted')->count();

        $recentSubmissions = ClassTaskSubmission::with(['student.profile', 'classTask'])
            ->whereIn(
                'class_task_id',
                ClassTask::whereIn('class_id', $classIds)->pluck('id')
            )
            ->where('status', 'submitted')
            ->orderByDesc('submitted_at')
            ->limit(5)
            ->get()
            ->map(fn ($s) => [
                'id'            => $s->id,
                'student_name'  => $s->student->name,
                'student_avatar'=> $s->student->profile?->avatar_url,
                'task_title'    => $s->classTask->title,
                'submitted_at'  => $s->submitted_at?->toIso8601String(),
            ]);

        $classPerformance = ClassRoom::where('lecturer_id', $lecturer->id)
            ->where('is_active', true)
            ->get()
            ->map(function ($class) {
                $taskIds       = $class->classTasks()->pluck('id');
                $totalTasks    = $taskIds->count();
                $gradedCount   = ClassTaskSubmission::whereIn('class_task_id', $taskIds)
                    ->where('status', 'graded')->count();
                $avgScore      = ClassTaskSubmission::whereIn('class_task_id', $taskIds)
                    ->where('status', 'graded')->avg('score') ?? 0;
                $studentCount  = $class->enrollments()->where('status', 'active')->count();
                $completionRate = $studentCount > 0 && $totalTasks > 0
                    ? round(($gradedCount / ($studentCount * $totalTasks)) * 100, 1)
                    : 0;

                return [
                    'class_id'        => $class->id,
                    'class_name'      => $class->course_name,
                    'student_count'   => $studentCount,
                    'avg_score'       => round($avgScore, 1),
                    'completion_rate' => $completionRate,
                ];
            });

        return [
            'total_classes'              => $classIds->count(),
            'total_students'             => $totalStudents,
            'pending_grading'            => $pendingGrading,
            'today_attendance_sessions'  => 0,
            'recent_submissions'         => $recentSubmissions,
            'class_performance'          => $classPerformance,
        ];
    }

    public function getClasses(User $lecturer): Collection
    {
        return ClassRoom::where('lecturer_id', $lecturer->id)
            ->orderByDesc('is_active')
            ->orderByDesc('created_at')
            ->get()
            ->each(function ($class) {
                $class->append(['student_count', 'pending_submissions_count']);
            });
    }

    public function getClassDetail(ClassRoom $class): array
    {
        $taskIds = $class->classTasks()->pluck('id');

        $students = $class->students()
            ->with('profile')
            ->wherePivot('status', 'active')
            ->get()
            ->map(function ($student) use ($taskIds) {
                $submissions = ClassTaskSubmission::where('student_id', $student->id)
                    ->whereIn('class_task_id', $taskIds)
                    ->get();

                $submitted = $submissions->whereIn('status', ['submitted', 'graded', 'late'])->count();
                $graded    = $submissions->where('status', 'graded')->count();
                $late      = $submissions->where('status', 'late')->count();
                $total     = $taskIds->count();

                return [
                    'id'              => $student->id,
                    'name'            => $student->name,
                    'nim'             => $student->profile?->student_id,
                    'avatar_url'      => $student->profile?->avatar_url,
                    'tasks_submitted' => $submitted,
                    'tasks_graded'    => $graded,
                    'tasks_pending'   => max(0, $total - $submitted),
                    'tasks_late'      => $late,
                    'completion_rate' => $total > 0 ? round(($submitted / $total) * 100, 1) : 0,
                ];
            });

        $tasks = $class->classTasks()
            ->withCount(['submissions as submitted_count' => fn ($q) =>
                $q->whereIn('status', ['submitted', 'graded', 'late'])
            ])
            ->withCount(['submissions as graded_count' => fn ($q) =>
                $q->where('status', 'graded')
            ])
            ->orderBy('deadline')
            ->get();

        return [
            'class'    => array_merge($class->toArray(), [
                'student_count'              => $class->student_count,
                'pending_submissions_count'  => $class->pending_submissions_count,
            ]),
            'students' => $students,
            'tasks'    => $tasks,
        ];
    }

    public function getStudentProgress(ClassRoom $class, User $student): array
    {
        $tasks = $class->classTasks()->orderBy('deadline')->get()->map(function ($task) use ($student) {
            $submission = ClassTaskSubmission::where('class_task_id', $task->id)
                ->where('student_id', $student->id)
                ->first();

            return [
                'task_id'      => $task->id,
                'title'        => $task->title,
                'deadline'     => $task->deadline->toIso8601String(),
                'max_score'    => $task->max_score,
                'status'       => $submission?->status ?? 'pending',
                'score'        => $submission?->score,
                'feedback'     => $submission?->feedback,
                'submitted_at' => $submission?->submitted_at?->toIso8601String(),
                'letter_grade' => $submission?->letter_grade ?? '-',
            ];
        });

        $gradedTasks = $tasks->where('status', 'graded');
        $overallScore = $gradedTasks->count() > 0
            ? round($gradedTasks->avg('score'), 1)
            : null;

        $grade = match (true) {
            $overallScore === null => '-',
            $overallScore >= 85   => 'A',
            $overallScore >= 70   => 'B',
            $overallScore >= 55   => 'C',
            $overallScore >= 40   => 'D',
            default               => 'E',
        };

        return [
            'student'       => [
                'id'        => $student->id,
                'name'      => $student->name,
                'nim'       => $student->profile?->student_id,
                'avatar_url'=> $student->profile?->avatar_url,
            ],
            'tasks'         => $tasks,
            'overall_score' => $overallScore,
            'grade'         => $grade,
        ];
    }

    public function createClass(User $lecturer, array $data): ClassRoom
    {
        return ClassRoom::create(array_merge($data, [
            'lecturer_id' => $lecturer->id,
        ]));
    }

    public function enrollStudent(ClassRoom $class, string $identifier): ClassEnrollment
    {
        $student = User::where('email', $identifier)
            ->orWhereHas('profile', fn ($q) => $q->where('student_id', $identifier))
            ->where('role', 'student')
            ->firstOrFail();

        return ClassEnrollment::firstOrCreate(
            ['class_id' => $class->id, 'student_id' => $student->id],
            ['enrolled_at' => now(), 'status' => 'active']
        );
    }

    public function createClassTask(ClassRoom $class, User $lecturer, array $data): ClassTask
    {
        return ClassTask::create(array_merge($data, [
            'class_id'   => $class->id,
            'created_by' => $lecturer->id,
        ]));
    }

    public function getSubmissions(ClassTask $task): array
    {
        $enrolled = $task->classRoom->students()->wherePivot('status', 'active')->pluck('users.id');

        $submissions = ClassTaskSubmission::with('student.profile')
            ->where('class_task_id', $task->id)
            ->get()
            ->keyBy('student_id');

        return $enrolled->map(function ($studentId) use ($submissions, $task) {
            $s       = $submissions->get($studentId);
            $student = User::with('profile')->find($studentId);
            return [
                'student'        => [
                    'id'         => $student->id,
                    'name'       => $student->name,
                    'nim'        => $student->profile?->student_id,
                    'avatar_url' => $student->profile?->avatar_url,
                ],
                'submission_id'  => $s?->id,
                'status'         => $s?->status ?? 'pending',
                'score'          => $s?->score,
                'feedback'       => $s?->feedback,
                'submitted_at'   => $s?->submitted_at?->toIso8601String(),
                'content'        => $s?->content,
                'attachment_url' => $s?->attachment_url,
            ];
        })->values()->toArray();
    }

    public function gradeSubmission(ClassTaskSubmission $submission, int $score, ?string $feedback): void
    {
        $submission->update([
            'score'      => $score,
            'feedback'   => $feedback,
            'status'     => 'graded',
            'graded_at'  => now(),
        ]);
    }
}

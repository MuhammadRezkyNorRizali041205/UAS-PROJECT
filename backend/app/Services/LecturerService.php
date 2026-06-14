<?php
// app/Services/LecturerService.php

namespace App\Services;

use App\Models\AttendanceLog;
use App\Models\AttendanceSession;
use App\Models\ClassEnrollment;
use App\Models\ClassRoom;
use App\Models\ClassTask;
use App\Models\ClassTaskSubmission;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;

class LecturerService
{
    // ─── Dashboard ───────────────────────────────────────────────────────────

    public function getDashboardStats(User $lecturer): array
    {
        $classIds = ClassRoom::where('lecturer_id', $lecturer->id)
            ->where('is_active', true)->pluck('id');

        $totalStudents = ClassEnrollment::whereIn('class_id', $classIds)
            ->where('status', 'active')->distinct('student_id')->count();

        $pendingGrading = ClassTaskSubmission::whereIn(
            'class_task_id',
            ClassTask::whereIn('class_id', $classIds)->pluck('id')
        )->where('status', 'submitted')->count();

        $todaySessions = AttendanceSession::whereIn('class_id', $classIds)
            ->whereDate('starts_at', today())->count();

        $recentSubmissions = ClassTaskSubmission::with(['student.profile', 'classTask.classRoom'])
            ->whereIn('class_task_id', ClassTask::whereIn('class_id', $classIds)->pluck('id'))
            ->where('status', 'submitted')
            ->orderByDesc('submitted_at')
            ->limit(5)
            ->get()
            ->map(fn ($s) => [
                'submission_id'  => $s->id,
                'student_name'   => $s->student->name,
                'student_avatar' => $s->student->profile?->avatar_url,
                'task_title'     => $s->classTask->title,
                'class_name'     => $s->classTask->classRoom->course_name,
                'submitted_at'   => $s->submitted_at?->toIso8601String(),
            ]);

        $classPerformance = ClassRoom::where('lecturer_id', $lecturer->id)
            ->where('is_active', true)->get()
            ->map(function ($class) {
                $taskIds       = $class->classTasks()->pluck('id');
                $studentCount  = $class->enrollments()->where('status', 'active')->count();
                $totalPossible = $taskIds->count() * max($studentCount, 1);
                $gradedCount   = ClassTaskSubmission::whereIn('class_task_id', $taskIds)
                    ->where('status', 'graded')->count();
                $avgScore      = ClassTaskSubmission::whereIn('class_task_id', $taskIds)
                    ->where('status', 'graded')->avg('score') ?? 0;
                return [
                    'class_id'        => $class->id,
                    'class_name'      => $class->course_name,
                    'student_count'   => $studentCount,
                    'task_count'      => $taskIds->count(),
                    'avg_score'       => round($avgScore, 1),
                    'completion_rate' => $totalPossible > 0
                        ? round(($gradedCount / $totalPossible) * 100, 1) : 0,
                    'pending_submissions' => ClassTaskSubmission::whereIn('class_task_id', $taskIds)
                        ->where('status', 'submitted')->count(),
                ];
            });

        return [
            'total_classes'             => $classIds->count(),
            'total_students'            => $totalStudents,
            'pending_grading'           => $pendingGrading,
            'today_attendance_sessions' => $todaySessions,
            'recent_submissions'        => $recentSubmissions,
            'class_performance'         => $classPerformance,
        ];
    }

    // ─── Classes ─────────────────────────────────────────────────────────────

    public function getClasses(User $lecturer): array
    {
        return ClassRoom::where('lecturer_id', $lecturer->id)
            ->orderByDesc('is_active')->orderByDesc('created_at')
            ->get()
            ->map(function ($class) {
                $taskIds      = $class->classTasks()->pluck('id');
                $studentCount = $class->enrollments()->where('status', 'active')->count();
                $submitted    = ClassTaskSubmission::whereIn('class_task_id', $taskIds)
                    ->whereIn('status', ['submitted', 'graded', 'late'])->count();
                $graded       = ClassTaskSubmission::whereIn('class_task_id', $taskIds)
                    ->where('status', 'graded')->count();
                $pending      = ClassTaskSubmission::whereIn('class_task_id', $taskIds)
                    ->where('status', 'submitted')->count();
                $totalPossible = $taskIds->count() * max($studentCount, 1);

                return array_merge($class->toArray(), [
                    'student_count'       => $studentCount,
                    'task_count'          => $taskIds->count(),
                    'pending_submissions' => $pending,
                    'completion_rate'     => $totalPossible > 0
                        ? round(($graded / $totalPossible) * 100, 1) : 0,
                    'is_full'             => $class->max_students &&
                        $studentCount >= $class->max_students,
                ]);
            })->toArray();
    }

    public function createClass(User $lecturer, array $data): ClassRoom
    {
        return ClassRoom::create(array_merge($data, ['lecturer_id' => $lecturer->id]));
    }

    public function updateClass(ClassRoom $class, array $data): ClassRoom
    {
        $class->update($data);
        return $class->fresh();
    }

    // ─── Class Detail ─────────────────────────────────────────────────────────

    public function getClassDetail(ClassRoom $class): array
    {
        $taskIds = $class->classTasks()->pluck('id');

        $students = $class->students()
            ->with('profile')->wherePivot('status', 'active')
            ->get()
            ->map(function ($student) use ($taskIds) {
                $submissions   = ClassTaskSubmission::where('student_id', $student->id)
                    ->whereIn('class_task_id', $taskIds)->get();
                $submitted     = $submissions->whereIn('status', ['submitted', 'graded', 'late'])->count();
                $graded        = $submissions->where('status', 'graded')->count();
                $total         = $taskIds->count();
                $avgScore      = $submissions->where('status', 'graded')->avg('score') ?? 0;
                return [
                    'id'              => $student->id,
                    'name'            => $student->name,
                    'nim'             => $student->profile?->student_id,
                    'avatar_url'      => $student->profile?->avatar_url,
                    'tasks_submitted' => $submitted,
                    'tasks_graded'    => $graded,
                    'tasks_pending'   => max(0, $total - $submitted),
                    'completion_rate' => $total > 0
                        ? round(($submitted / $total) * 100, 1) : 0,
                    'avg_score'       => round($avgScore, 1),
                ];
            });

        $tasks = $class->classTasks()
            ->withCount(['submissions as submitted_count' => fn ($q) =>
                $q->whereIn('status', ['submitted', 'graded', 'late'])])
            ->withCount(['submissions as graded_count' => fn ($q) =>
                $q->where('status', 'graded')])
            ->withCount(['submissions as pending_count' => fn ($q) =>
                $q->where('status', 'submitted')])
            ->orderBy('deadline')->get()
            ->map(function ($t) use ($class) {
                $studentCount = $class->enrollments()->where('status', 'active')->count();
                return array_merge($t->toArray(), [
                    'submission_rate' => $studentCount > 0
                        ? round(($t->submitted_count / $studentCount) * 100, 1) : 0,
                    'is_expired'      => now()->gt($t->deadline),
                ]);
            });

        $attendanceSessions = AttendanceSession::where('class_id', $class->id)
            ->orderByDesc('created_at')->take(5)
            ->get()
            ->map(fn ($s) => [
                'id'            => $s->id,
                'title'         => $s->course_name,
                'starts_at'     => $s->starts_at->toIso8601String(),
                'ends_at'       => $s->ends_at->toIso8601String(),
                'is_active'     => $s->isActive(),
                'present_count' => $s->logs()->count(),
            ]);

        return [
            'class' => array_merge($class->toArray(), [
                'student_count'       => $students->count(),
                'task_count'          => $taskIds->count(),
                'pending_submissions' => ClassTaskSubmission::whereIn('class_task_id', $taskIds)
                    ->where('status', 'submitted')->count(),
            ]),
            'students'            => $students->values(),
            'tasks'               => $tasks->values(),
            'attendance_sessions' => $attendanceSessions->values(),
        ];
    }

    // ─── Enroll / Remove ────────────────────────────────────────────────────

    public function enrollStudent(ClassRoom $class, string $identifier): ClassEnrollment
    {
        $student = User::where('email', $identifier)
            ->orWhereHas('profile', fn ($q) => $q->where('student_id', $identifier))
            ->where('role', 'student')->firstOrFail();

        return ClassEnrollment::firstOrCreate(
            ['class_id' => $class->id, 'student_id' => $student->id],
            ['enrolled_at' => now(), 'status' => 'active']
        )->tap(function ($enrollment) {
            if ($enrollment->status !== 'active') {
                $enrollment->update(['status' => 'active']);
            }
        });
    }

    // ─── Tasks ────────────────────────────────────────────────────────────────

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
            ->get()->keyBy('student_id');

        $notSubmittedIds = $enrolled->diff($submissions->keys());
        $notSubmitted = User::with('profile')->whereIn('id', $notSubmittedIds)->get()
            ->map(fn ($u) => [
                'student'       => ['id' => $u->id, 'name' => $u->name, 'nim' => $u->profile?->student_id, 'avatar_url' => $u->profile?->avatar_url],
                'submission_id' => null,
                'status'        => 'pending',
                'score'         => null,
                'feedback'      => null,
                'submitted_at'  => null,
                'content'       => null,
                'is_late'       => false,
            ]);

        $submitted = $submissions->map(function ($s) {
            $student = $s->student;
            return [
                'student'        => ['id' => $student->id, 'name' => $student->name, 'nim' => $student->profile?->student_id, 'avatar_url' => $student->profile?->avatar_url],
                'submission_id'  => $s->id,
                'status'         => $s->status,
                'score'          => $s->score,
                'feedback'       => $s->feedback,
                'submitted_at'   => $s->submitted_at?->toIso8601String(),
                'content'        => $s->content,
                'attachment_url' => $s->attachment_url,
                'is_late'        => $s->submitted_at && $s->classTask->deadline < $s->submitted_at,
            ];
        })->values();

        $all = $submitted->concat($notSubmitted)->values()->toArray();

        $summary = [
            'total'         => count($all),
            'submitted'     => $submissions->whereIn('status', ['submitted'])->count(),
            'graded'        => $submissions->where('status', 'graded')->count(),
            'late'          => $submissions->where('status', 'late')->count(),
            'not_submitted' => $notSubmittedIds->count(),
        ];

        return ['submissions' => $all, 'summary' => $summary];
    }

    public function gradeSubmission(ClassTaskSubmission $submission, int $score, ?string $feedback): ClassTaskSubmission
    {
        $submission->update([
            'score'     => $score,
            'feedback'  => $feedback,
            'status'    => 'graded',
            'graded_at' => now(),
        ]);
        return $submission->fresh();
    }

    // ─── Grading (all pending) ────────────────────────────────────────────────

    public function getAllPendingGrading(User $lecturer): array
    {
        $classIds = ClassRoom::where('lecturer_id', $lecturer->id)->pluck('id');
        $taskIds  = ClassTask::whereIn('class_id', $classIds)->pluck('id');

        return ClassTaskSubmission::with(['student.profile', 'classTask.classRoom'])
            ->whereIn('class_task_id', $taskIds)
            ->where('status', 'submitted')
            ->orderBy('submitted_at')
            ->get()
            ->map(fn ($s) => [
                'submission_id'  => $s->id,
                'student'        => [
                    'id'         => $s->student->id,
                    'name'       => $s->student->name,
                    'nim'        => $s->student->profile?->student_id,
                    'avatar_url' => $s->student->profile?->avatar_url,
                ],
                'task'           => [
                    'id'         => $s->classTask->id,
                    'title'      => $s->classTask->title,
                    'deadline'   => $s->classTask->deadline->toIso8601String(),
                    'max_score'  => $s->classTask->max_score,
                ],
                'class'          => [
                    'id'   => $s->classTask->classRoom->id,
                    'name' => $s->classTask->classRoom->course_name,
                ],
                'submitted_at' => $s->submitted_at?->toIso8601String(),
                'is_late'      => $s->submitted_at && $s->classTask->deadline < $s->submitted_at,
            ])->toArray();
    }

    // ─── Attendance ────────────────────────────────────────────────────────────

    public function getAttendanceSessions(ClassRoom $class): array
    {
        $totalStudents = $class->enrollments()->where('status', 'active')->count();

        return AttendanceSession::where('class_id', $class->id)
            ->orderByDesc('created_at')->get()
            ->map(fn ($s) => [
                'id'              => $s->id,
                'title'           => $s->course_name,
                'session_code'    => $s->session_code,
                'starts_at'       => $s->starts_at->toIso8601String(),
                'ends_at'         => $s->ends_at->toIso8601String(),
                'is_active'       => $s->isActive(),
                'present_count'   => $s->logs()->count(),
                'total_students'  => $totalStudents,
                'attendance_rate' => $totalStudents > 0
                    ? round(($s->logs()->count() / $totalStudents) * 100, 1) : 0,
            ])->toArray();
    }

    public function createAttendanceSession(ClassRoom $class, User $creator, array $data): AttendanceSession
    {
        $from  = isset($data['valid_from'])  ? Carbon::parse($data['valid_from'])  : now();
        $until = isset($data['valid_until']) ? Carbon::parse($data['valid_until']) : now()->addMinutes(90);

        return AttendanceSession::create([
            'creator_id'  => $creator->id,
            'class_id'    => $class->id,
            'course_name' => $data['title'],
            'starts_at'   => $from,
            'ends_at'     => $until,
            'is_active'   => true,
        ]);
    }

    public function getAttendanceDetail(AttendanceSession $session): array
    {
        $class = $session->class_id ? ClassRoom::find($session->class_id) : null;
        $enrolledStudents = $class
            ? $class->students()->with('profile')->wherePivot('status', 'active')->get()
            : collect();

        $logs = $session->logs()->with('user.profile')->get()->keyBy('user_id');

        $present = [];
        $absent  = [];

        foreach ($enrolledStudents as $student) {
            $log = $logs->get($student->id);
            if ($log) {
                $present[] = [
                    'student'    => ['id' => $student->id, 'name' => $student->name, 'nim' => $student->profile?->student_id, 'avatar_url' => $student->profile?->avatar_url],
                    'scanned_at' => $log->scanned_at->toIso8601String(),
                ];
            } else {
                $absent[] = [
                    'id'         => $student->id,
                    'name'       => $student->name,
                    'nim'        => $student->profile?->student_id,
                    'avatar_url' => $student->profile?->avatar_url,
                ];
            }
        }

        return [
            'session' => [
                'id'            => $session->id,
                'title'         => $session->course_name,
                'qr_token'      => $session->session_code,
                'starts_at'     => $session->starts_at->toIso8601String(),
                'ends_at'       => $session->ends_at->toIso8601String(),
                'is_active'     => $session->isActive(),
                'minutes_left'  => max(0, now()->diffInMinutes($session->ends_at, false)),
            ],
            'present'        => $present,
            'absent'         => $absent,
            'present_count'  => count($present),
            'total_students' => $enrolledStudents->count(),
        ];
    }

    public function closeAttendanceSession(AttendanceSession $session): void
    {
        $session->update(['is_active' => false, 'ends_at' => now()]);
    }

    // ─── Students ────────────────────────────────────────────────────────────

    public function getStudentsWithRisk(ClassRoom $class): array
    {
        $taskIds       = $class->classTasks()->pluck('id');
        $totalTasks    = $taskIds->count();
        $totalSessions = AttendanceSession::where('class_id', $class->id)->count();

        return $class->students()
            ->with('profile')->wherePivot('status', 'active')
            ->get()
            ->map(function ($student) use ($taskIds, $totalTasks, $class, $totalSessions) {
                $submissions   = ClassTaskSubmission::where('student_id', $student->id)
                    ->whereIn('class_task_id', $taskIds)->get();
                $submitted     = $submissions->whereIn('status', ['submitted', 'graded', 'late'])->count();
                $late          = $submissions->where('status', 'late')->count();
                $avgScore      = $submissions->where('status', 'graded')->avg('score') ?? 0;
                $completionRate = $totalTasks > 0
                    ? round(($submitted / $totalTasks) * 100, 1) : 100;

                $presentCount   = AttendanceLog::whereIn(
                    'session_id',
                    AttendanceSession::where('class_id', $class->id)->pluck('id')
                )->where('user_id', $student->id)->count();
                $attendanceRate = $totalSessions > 0
                    ? round(($presentCount / $totalSessions) * 100, 1) : 100;

                $riskLevel = match (true) {
                    $completionRate >= 75 && $attendanceRate >= 75 => 'good',
                    $completionRate >= 50 && $attendanceRate >= 50 => 'warning',
                    default                                         => 'at_risk',
                };

                $grade = match (true) {
                    $avgScore >= 85 => 'A',
                    $avgScore >= 70 => 'B',
                    $avgScore >= 55 => 'C',
                    $avgScore >= 40 => 'D',
                    $avgScore > 0  => 'E',
                    default        => 'N/A',
                };

                return [
                    'id'              => $student->id,
                    'name'            => $student->name,
                    'nim'             => $student->profile?->student_id,
                    'avatar_url'      => $student->profile?->avatar_url,
                    'tasks_completed' => $submitted,
                    'tasks_total'     => $totalTasks,
                    'tasks_late'      => $late,
                    'completion_rate' => $completionRate,
                    'attendance_rate' => $attendanceRate,
                    'average_score'   => round($avgScore, 1),
                    'grade'           => $grade,
                    'risk_level'      => $riskLevel,
                ];
            })->toArray();
    }

    public function getStudentProgress(ClassRoom $class, User $student): array
    {
        $tasks = $class->classTasks()->orderBy('deadline')->get()
            ->map(function ($task) use ($student) {
                $submission = ClassTaskSubmission::where('class_task_id', $task->id)
                    ->where('student_id', $student->id)->first();
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
                    'is_late'      => $submission?->submitted_at && $task->deadline < $submission->submitted_at,
                ];
            });

        $sessions = AttendanceSession::where('class_id', $class->id)
            ->orderBy('starts_at')->get()
            ->map(function ($session) use ($student) {
                $log = $session->logs()->where('user_id', $student->id)->first();
                return [
                    'session_id'  => $session->id,
                    'title'       => $session->course_name,
                    'date'        => $session->starts_at->toIso8601String(),
                    'status'      => $log ? 'present' : 'absent',
                    'scanned_at'  => $log?->scanned_at->toIso8601String(),
                ];
            });

        $gradedTasks  = $tasks->where('status', 'graded');
        $overallScore = $gradedTasks->count() > 0 ? round($gradedTasks->avg('score'), 1) : null;
        $grade        = match (true) {
            $overallScore === null => '-',
            $overallScore >= 85   => 'A',
            $overallScore >= 70   => 'B',
            $overallScore >= 55   => 'C',
            $overallScore >= 40   => 'D',
            default               => 'E',
        };

        $totalSessions = $sessions->count();
        $presentCount  = $sessions->where('status', 'present')->count();

        return [
            'student'      => [
                'id'         => $student->id,
                'name'       => $student->name,
                'nim'        => $student->profile?->student_id,
                'avatar_url' => $student->profile?->avatar_url,
            ],
            'tasks'        => $tasks->values(),
            'attendance'   => $sessions->values(),
            'summary'      => [
                'overall_score'   => $overallScore,
                'grade'           => $grade,
                'attendance_rate' => $totalSessions > 0
                    ? round(($presentCount / $totalSessions) * 100, 1) : 100,
                'completion_rate' => $tasks->count() > 0
                    ? round(($tasks->whereIn('status', ['submitted', 'graded', 'late'])->count() / $tasks->count()) * 100, 1)
                    : 0,
            ],
        ];
    }
}

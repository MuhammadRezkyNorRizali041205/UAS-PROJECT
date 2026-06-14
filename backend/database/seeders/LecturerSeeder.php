<?php
// database/seeders/LecturerSeeder.php

namespace Database\Seeders;

use App\Models\AttendanceLog;
use App\Models\AttendanceSession;
use App\Models\ClassEnrollment;
use App\Models\ClassRoom;
use App\Models\ClassTask;
use App\Models\ClassTaskSubmission;
use App\Models\Organization;
use App\Models\OrganizationEvent;
use App\Models\OrganizationMember;
use App\Models\Profile;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class LecturerSeeder extends Seeder
{
    public function run(): void
    {
        // ── Lecturer ──────────────────────────────────────────────────────────
        $lecturer = User::updateOrCreate(
            ['email' => 'dosen@poliban.ac.id'],
            [
                'name'      => 'Dr. Rizky Ananda, M.Kom',
                'password'  => Hash::make('password123'),
                'role'      => 'lecturer',
                'is_active' => true,
            ]
        );
        Profile::updateOrCreate(['user_id' => $lecturer->id], [
            'faculty'   => 'Teknologi Informasi',
            'major'     => 'Teknik Informatika',
            'phone'     => '082345678901',
            'bio'       => 'Dosen Pemrograman Bergerak dan Basis Data',
        ]);

        // ── Organization ──────────────────────────────────────────────────────
        $org = User::updateOrCreate(
            ['email' => 'bem@poliban.ac.id'],
            [
                'name'      => 'BEM Poliban',
                'password'  => Hash::make('password123'),
                'role'      => 'organization',
                'is_active' => true,
            ]
        );
        Profile::updateOrCreate(['user_id' => $org->id], [
            'faculty' => 'Umum',
            'major'   => 'Organisasi Mahasiswa',
            'bio'     => 'Badan Eksekutif Mahasiswa Politeknik Negeri Banjarmasin',
        ]);

        // ── Organization record ───────────────────────────────────────────────
        $orgRecord = Organization::updateOrCreate(
            ['leader_id' => $org->id],
            [
                'name'         => 'BEM Politeknik Negeri Banjarmasin',
                'description'  => 'Badan Eksekutif Mahasiswa (BEM) Politeknik Negeri Banjarmasin adalah organisasi kemahasiswaan tertinggi di Poliban yang bertugas sebagai wadah aspirasi mahasiswa.',
                'category'     => 'bem',
                'is_verified'  => true,
                'member_count' => 0,
            ]
        );

        // Leader as member
        OrganizationMember::updateOrCreate(
            ['organization_id' => $orgRecord->id, 'user_id' => $org->id],
            ['role' => 'leader', 'joined_at' => now()->subYear(), 'is_active' => true]
        );

        // Events
        $eventData = [
            [
                'title'                 => 'Seminar Nasional Teknologi Informasi 2026',
                'description'           => 'Seminar nasional dengan tema "Transformasi Digital menuju Indonesia Emas 2045". Menghadirkan pembicara dari industri teknologi terkemuka.',
                'event_date'            => now()->addDays(14)->setTime(8, 0),
                'end_date'              => now()->addDays(14)->setTime(17, 0),
                'location'             => 'Aula Utama Poliban, Banjarmasin',
                'max_participants'      => 300,
                'registration_deadline' => now()->addDays(10)->setTime(23, 59),
                'status'               => 'published',
            ],
            [
                'title'                 => 'Lomba Karya Tulis Ilmiah 2026',
                'description'           => 'Kompetisi karya tulis ilmiah tingkat mahasiswa se-Kalimantan Selatan. Tema: "Inovasi Teknologi untuk Keberlanjutan".',
                'event_date'            => now()->addDays(30)->setTime(8, 0),
                'end_date'              => now()->addDays(31)->setTime(17, 0),
                'location'             => 'Gedung Serbaguna Poliban',
                'max_participants'      => 150,
                'registration_deadline' => now()->addDays(25)->setTime(23, 59),
                'status'               => 'published',
            ],
            [
                'title'                 => 'Workshop UI/UX Design',
                'description'           => 'Workshop praktis desain antarmuka pengguna menggunakan Figma. Cocok untuk mahasiswa yang ingin berkarir di bidang desain produk digital.',
                'event_date'            => now()->subDays(7)->setTime(9, 0),
                'end_date'              => now()->subDays(7)->setTime(16, 0),
                'location'             => 'Lab Komputer Gedung C Poliban',
                'max_participants'      => 50,
                'registration_deadline' => now()->subDays(10)->setTime(23, 59),
                'status'               => 'completed',
            ],
        ];

        OrganizationEvent::where('organization_id', $orgRecord->id)->forceDelete();
        foreach ($eventData as $ed) {
            OrganizationEvent::create(array_merge($ed, [
                'organization_id' => $orgRecord->id,
                'created_by'      => $org->id,
            ]));
        }

        // ── Students (5 students for the classes) ────────────────────────────
        $studentData = [
            ['email' => 'mahasiswa1@poliban.ac.id', 'name' => 'Ahmad Fauzan',   'nim' => 'D010422001', 'phone' => '081234567890'],
            ['email' => 'mahasiswa2@poliban.ac.id', 'name' => 'Siti Rahayu',    'nim' => 'D010422002', 'phone' => '081234567891'],
            ['email' => 'mahasiswa3@poliban.ac.id', 'name' => 'Budi Prasetyo',  'nim' => 'D010422003', 'phone' => '081234567892'],
            ['email' => 'mahasiswa4@poliban.ac.id', 'name' => 'Dewi Lestari',   'nim' => 'D010422004', 'phone' => '081234567893'],
            ['email' => 'mahasiswa5@poliban.ac.id', 'name' => 'Eko Santoso',    'nim' => 'D010422005', 'phone' => '081234567894'],
        ];

        $students = [];
        foreach ($studentData as $sd) {
            $s = User::updateOrCreate(['email' => $sd['email']], [
                'name'      => $sd['name'],
                'password'  => Hash::make('password123'),
                'role'      => 'student',
                'is_active' => true,
            ]);
            Profile::updateOrCreate(['user_id' => $s->id], [
                'student_id' => $sd['nim'],
                'faculty'    => 'Teknologi Informasi',
                'major'      => 'Teknik Informatika',
                'year_entry' => 2022,
                'phone'      => $sd['phone'],
                'notification_prefs' => [
                    'schedule' => true, 'task' => true,
                    'announcement' => true, 'attendance' => true,
                ],
            ]);
            $students[] = $s;
        }

        // ── Class 1: Pemrograman Bergerak ─────────────────────────────────────
        $class1 = $this->seedClass($lecturer, [
            'name'          => 'Kelas A – Pemrograman Bergerak',
            'course_name'   => 'Pemrograman Bergerak',
            'course_code'   => 'TI401',
            'semester'      => 4,
            'academic_year' => '2025/2026',
            'description'   => 'Pemrograman aplikasi mobile menggunakan Flutter',
            'max_students'  => 30,
            'is_active'     => true,
        ], $students, [
            [
                'title'       => 'Tugas 1 – Hello World Flutter',
                'description' => 'Buat aplikasi Flutter pertama: tampilkan nama, NIM, dan foto profil.',
                'deadline'    => now()->subDays(10)->setTime(23, 59),
                'max_score'   => 100,
            ],
            [
                'title'       => 'Tugas 2 – State Management Riverpod',
                'description' => 'Implementasikan state management Riverpod pada aplikasi counter sederhana.',
                'deadline'    => now()->subDays(3)->setTime(23, 59),
                'max_score'   => 100,
            ],
            [
                'title'       => 'Tugas 3 – Integrasi REST API',
                'description' => 'Buat aplikasi yang mengambil data dari public API (JSONPlaceholder) dan tampilkan dengan ListView.',
                'deadline'    => now()->addDays(7)->setTime(23, 59),
                'max_score'   => 100,
            ],
        ], 3);

        // ── Class 2: Basis Data ───────────────────────────────────────────────
        $class2 = $this->seedClass($lecturer, [
            'name'          => 'Kelas B – Basis Data',
            'course_name'   => 'Basis Data',
            'course_code'   => 'TI301',
            'semester'      => 3,
            'academic_year' => '2025/2026',
            'description'   => 'Perancangan dan implementasi basis data relasional',
            'max_students'  => 25,
            'is_active'     => true,
        ], array_slice($students, 0, 4), [
            [
                'title'       => 'Tugas 1 – ER Diagram',
                'description' => 'Buat ER Diagram sistem perpustakaan dengan minimal 5 entitas.',
                'deadline'    => now()->subDays(14)->setTime(23, 59),
                'max_score'   => 100,
            ],
            [
                'title'       => 'Tugas 2 – Normalisasi Database',
                'description' => 'Normalisasikan tabel yang diberikan hingga 3NF, sertakan penjelasan langkah-langkahnya.',
                'deadline'    => now()->addDays(5)->setTime(23, 59),
                'max_score'   => 100,
            ],
        ], 2);

        $this->command->info('LecturerSeeder selesai:');
        $this->command->info("  Dosen   : dosen@poliban.ac.id / password123");
        $this->command->info("  Org     : bem@poliban.ac.id / password123 → {$orgRecord->name}");
        $this->command->info("  Mhs 1-5 : mahasiswa1-5@poliban.ac.id / password123");
        $this->command->info("  Kelas 1 : {$class1->course_name} ({$class1->id})");
        $this->command->info("  Kelas 2 : {$class2->course_name} ({$class2->id})");
        $this->command->info("  Events  : 3 event (2 published, 1 completed)");
    }

    private function seedClass(
        User $lecturer,
        array $classData,
        array $students,
        array $tasks,
        int $attendanceCount
    ): ClassRoom {
        // Delete existing class with same course_code + lecturer
        ClassRoom::where('lecturer_id', $lecturer->id)
            ->where('course_code', $classData['course_code'])
            ->forceDelete();

        $class = ClassRoom::create(array_merge($classData, ['lecturer_id' => $lecturer->id]));

        // Enroll students
        foreach ($students as $student) {
            ClassEnrollment::create([
                'class_id'    => $class->id,
                'student_id'  => $student->id,
                'enrolled_at' => now()->subDays(30),
                'status'      => 'active',
            ]);
        }

        // Create tasks with submissions
        $taskModels = [];
        foreach ($tasks as $taskData) {
            $task = ClassTask::create(array_merge($taskData, [
                'class_id'   => $class->id,
                'created_by' => $lecturer->id,
            ]));
            $taskModels[] = $task;
        }

        // Seed submissions for past tasks
        foreach ($taskModels as $index => $task) {
            $isPast = $task->deadline->isPast();
            foreach ($students as $si => $student) {
                if (!$isPast) continue; // only submit for past tasks

                // Vary submission status per student
                $scenario = ($si + $index) % 5;
                match ($scenario) {
                    0 => $this->createSubmission($task, $student, 'graded', 88, 'Sangat bagus!'),
                    1 => $this->createSubmission($task, $student, 'graded', 72, 'Perlu diperbaiki di bagian normalisasi.'),
                    2 => $this->createSubmission($task, $student, 'submitted'),
                    3 => $this->createSubmission($task, $student, 'late',     null, null, true),
                    4 => null, // not submitted
                };
            }
        }

        // Seed attendance sessions
        for ($i = $attendanceCount; $i >= 1; $i--) {
            $from  = now()->subDays($i * 7)->setTime(9, 0);
            $until = $from->copy()->addMinutes(90);

            $session = AttendanceSession::create([
                'creator_id'  => $lecturer->id,
                'class_id'    => $class->id,
                'course_name' => "Pertemuan ke-$i – {$class->course_name}",
                'starts_at'   => $from,
                'ends_at'     => $until,
                'is_active'   => false,
            ]);

            // 60-80% of students attend each session
            $attendingCount = max(1, (int) round(count($students) * (rand(60, 85) / 100)));
            $attending      = array_slice($students, 0, $attendingCount);
            foreach ($attending as $student) {
                AttendanceLog::create([
                    'session_id' => $session->id,
                    'user_id'    => $student->id,
                    'scanned_at' => $from->copy()->addMinutes(rand(1, 15)),
                ]);
            }
        }

        return $class;
    }

    private function createSubmission(
        ClassTask $task,
        User $student,
        string $status,
        ?int $score     = null,
        ?string $feedback = null,
        bool $isLate    = false
    ): ClassTaskSubmission {
        $submittedAt = $isLate
            ? $task->deadline->copy()->addHours(rand(1, 48))
            : $task->deadline->copy()->subHours(rand(2, 72));

        return ClassTaskSubmission::create([
            'class_task_id' => $task->id,
            'student_id'    => $student->id,
            'content'       => 'Pengumpulan tugas ' . $task->title,
            'status'        => $isLate ? 'late' : $status,
            'score'         => $score,
            'feedback'      => $feedback,
            'submitted_at'  => $submittedAt,
            'graded_at'     => $score !== null ? $submittedAt->copy()->addHours(24) : null,
        ]);
    }
}

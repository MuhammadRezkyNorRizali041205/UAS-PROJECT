<?php
// database/seeders/RoleSeeder.php

namespace Database\Seeders;

use App\Models\ClassEnrollment;
use App\Models\ClassRoom;
use App\Models\ClassTask;
use App\Models\ClassTaskSubmission;
use App\Models\Organization;
use App\Models\OrganizationEvent;
use App\Models\OrganizationMember;
use App\Models\Profile;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        // ── Extra student users ───────────────────────────────────────────────
        $student2 = User::updateOrCreate(
            ['email' => 'mahasiswa2@ulm.ac.id'],
            ['name' => 'Siti Rahayu', 'password' => Hash::make('password123'), 'role' => 'student', 'is_active' => true]
        );
        Profile::updateOrCreate(['user_id' => $student2->id], [
            'student_id' => '2110101046', 'faculty' => 'Fakultas Teknik',
            'major' => 'Teknik Informatika', 'year_entry' => 2021,
            'notification_prefs' => ['schedule' => true, 'task' => true, 'announcement' => true, 'attendance' => true],
        ]);

        $student3 = User::updateOrCreate(
            ['email' => 'mahasiswa3@ulm.ac.id'],
            ['name' => 'Ahmad Fathoni', 'password' => Hash::make('password123'), 'role' => 'student', 'is_active' => true]
        );
        Profile::updateOrCreate(['user_id' => $student3->id], [
            'student_id' => '2110101047', 'faculty' => 'Fakultas Teknik',
            'major' => 'Teknik Informatika', 'year_entry' => 2021,
            'notification_prefs' => ['schedule' => true, 'task' => true, 'announcement' => true, 'attendance' => true],
        ]);

        // ── Lecturer ──────────────────────────────────────────────────────────
        $lecturer = User::updateOrCreate(
            ['email' => 'dosen@ulm.ac.id'],
            ['name' => 'Dr. Rizky Ananda, M.Kom', 'password' => Hash::make('password123'), 'role' => 'lecturer', 'is_active' => true]
        );
        Profile::updateOrCreate(['user_id' => $lecturer->id], [
            'student_id' => 'NIP.198501012010011001',
            'faculty'    => 'Fakultas Teknik',
            'major'      => 'Teknik Informatika',
            'year_entry' => 2010,
            'bio'        => 'Dosen Pemrograman Bergerak dan Basis Data',
            'notification_prefs' => ['schedule' => true, 'task' => true, 'announcement' => true, 'attendance' => true],
        ]);

        // ── Organization user ─────────────────────────────────────────────────
        $bemUser = User::updateOrCreate(
            ['email' => 'bem@ulm.ac.id'],
            ['name' => 'BEM FILKOM ULM', 'password' => Hash::make('password123'), 'role' => 'organization', 'is_active' => true]
        );
        Profile::updateOrCreate(['user_id' => $bemUser->id], [
            'faculty'    => 'Fakultas Teknik',
            'major'      => 'Organisasi Kemahasiswaan',
            'year_entry' => 2024,
            'bio'        => 'Badan Eksekutif Mahasiswa FILKOM ULM',
            'notification_prefs' => ['schedule' => true, 'task' => true, 'announcement' => true, 'attendance' => true],
        ]);

        // ── Organization ──────────────────────────────────────────────────────
        $org = Organization::updateOrCreate(
            ['leader_id' => $bemUser->id],
            [
                'name'        => 'BEM FILKOM ULM',
                'description' => 'Badan Eksekutif Mahasiswa Fakultas Ilmu Komputer Universitas Lambung Mangkurat',
                'category'    => 'bem',
                'is_verified' => true,
                'member_count'=> 3,
            ]
        );

        // BEM members (leader + 2 students)
        $mainStudent = User::where('email', 'test@ulm.ac.id')->first();
        foreach ([
            [$bemUser->id, 'leader'],
            [$mainStudent->id, 'member'],
            [$student2->id, 'secretary'],
        ] as [$uid, $role]) {
            OrganizationMember::updateOrCreate(
                ['organization_id' => $org->id, 'user_id' => $uid],
                ['role' => $role, 'joined_at' => now()->subMonths(3), 'is_active' => true]
            );
        }

        // BEM Event
        OrganizationEvent::updateOrCreate(
            ['organization_id' => $org->id, 'title' => 'Seminar AI dan Machine Learning 2026'],
            [
                'created_by'            => $bemUser->id,
                'description'           => 'Seminar nasional membahas perkembangan AI dan Machine Learning untuk mahasiswa FILKOM.',
                'event_date'            => now()->addDays(14)->setTime(9, 0),
                'end_date'              => now()->addDays(14)->setTime(16, 0),
                'location'              => 'Aula Utama Gedung FILKOM',
                'max_participants'      => 200,
                'registration_deadline' => now()->addDays(12),
                'status'                => 'published',
            ]
        );

        // ── Classroom (Pemrograman Bergerak) ──────────────────────────────────
        $class = ClassRoom::updateOrCreate(
            ['course_code' => 'CS401', 'lecturer_id' => $lecturer->id],
            [
                'name'          => 'Kelas A Pemrograman Bergerak',
                'course_name'   => 'Pemrograman Bergerak',
                'semester'      => 4,
                'academic_year' => '2025/2026',
                'description'   => 'Kelas praktikum pengembangan aplikasi mobile menggunakan Flutter.',
                'max_students'  => 35,
                'is_active'     => true,
            ]
        );

        // Enroll 3 students
        foreach ([$mainStudent, $student2, $student3] as $student) {
            ClassEnrollment::updateOrCreate(
                ['class_id' => $class->id, 'student_id' => $student->id],
                ['enrolled_at' => now()->subMonths(1), 'status' => 'active']
            );
        }

        // Task 1: Already submitted by mainStudent
        $task1 = ClassTask::updateOrCreate(
            ['class_id' => $class->id, 'title' => 'Tugas 1 — UI Login Screen Flutter'],
            [
                'created_by'  => $lecturer->id,
                'description' => 'Buat UI Login Screen menggunakan Flutter dengan validasi form. Sertakan email & password field.',
                'deadline'    => now()->subDays(3),
                'max_score'   => 100,
            ]
        );

        ClassTaskSubmission::updateOrCreate(
            ['class_task_id' => $task1->id, 'student_id' => $mainStudent->id],
            [
                'content'      => 'Saya telah menyelesaikan UI Login Screen dengan validasi email dan password menggunakan Flutter Form widget.',
                'status'       => 'graded',
                'score'        => 88,
                'feedback'     => 'Bagus! Implementasi validasi sudah benar. Untuk ke depannya tambahkan animasi pada error state.',
                'submitted_at' => now()->subDays(4),
                'graded_at'    => now()->subDays(2),
            ]
        );

        ClassTaskSubmission::updateOrCreate(
            ['class_task_id' => $task1->id, 'student_id' => $student2->id],
            [
                'content'      => 'Login screen dengan TextField dan ElevatedButton sudah selesai.',
                'status'       => 'submitted',
                'submitted_at' => now()->subDays(3),
            ]
        );

        // Task 2: Upcoming, no submissions yet
        ClassTask::updateOrCreate(
            ['class_id' => $class->id, 'title' => 'Tugas 2 — State Management dengan Riverpod'],
            [
                'created_by'  => $lecturer->id,
                'description' => 'Implementasikan state management menggunakan Riverpod untuk counter app. Sertakan Provider, StateNotifier, dan AsyncNotifier.',
                'deadline'    => now()->addDays(7),
                'max_score'   => 100,
            ]
        );
    }
}

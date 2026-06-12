<?php
// database/seeders/UserSeeder.php

namespace Database\Seeders;

use App\Models\Profile;
use App\Models\Schedule;
use App\Models\Task;
use App\Models\User;
use App\Models\UserActivity;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // ── Main test user ────────────────────────────────────────────────
        $user = User::updateOrCreate(
            ['email' => 'test@ulm.ac.id'],
            [
                'name'      => 'Budi Santoso',
                'password'  => Hash::make('password123'),
                'role'      => 'student',
                'is_active' => true,
            ]
        );

        Profile::updateOrCreate(
            ['user_id' => $user->id],
            [
                'student_id'         => '2110101045',
                'faculty'            => 'Fakultas Teknik',
                'major'              => 'Teknik Informatika',
                'year_entry'         => 2021,
                'phone'              => '081234567890',
                'bio'                => 'Mahasiswa Teknik Informatika semester 4',
                'notification_prefs' => [
                    'schedule'     => true,
                    'task'         => true,
                    'announcement' => true,
                    'attendance'   => true,
                ],
            ]
        );

        // ── Delete existing data for clean re-seed ─────────────────────────
        Schedule::where('user_id', $user->id)->delete();
        Task::where('user_id', $user->id)->forceDelete();
        UserActivity::where('user_id', $user->id)->delete();

        // ── Schedules (5 weekly) ───────────────────────────────────────────
        $schedules = [
            [
                'title'       => 'Matematika Diskrit',
                'category'    => 'lecture',
                'day_of_week' => Carbon::MONDAY,
                'start_time'  => '08:00:00',
                'end_time'    => '09:40:00',
                'room'        => 'Gedung A R.201',
                'lecturer'    => 'Dr. Ahmad Fauzi, M.Kom',
                'color_tag'   => '#6366F1',
            ],
            [
                'title'       => 'Pemrograman Bergerak',
                'category'    => 'lecture',
                'day_of_week' => Carbon::TUESDAY,
                'start_time'  => '10:00:00',
                'end_time'    => '11:40:00',
                'room'        => 'Lab Komputer Lt.2',
                'lecturer'    => 'Bapak Rizky Ananda, S.T.',
                'color_tag'   => '#8B5CF6',
            ],
            [
                'title'       => 'Basis Data',
                'category'    => 'practicum',
                'day_of_week' => Carbon::WEDNESDAY,
                'start_time'  => '13:00:00',
                'end_time'    => '14:40:00',
                'room'        => 'Lab Basis Data',
                'lecturer'    => 'Ibu Sari Dewi, M.T.',
                'color_tag'   => '#8B5CF6',
            ],
            [
                'title'       => 'Seminar Teknologi',
                'category'    => 'seminar',
                'day_of_week' => Carbon::THURSDAY,
                'start_time'  => '09:00:00',
                'end_time'    => '10:00:00',
                'room'        => 'Aula Utama',
                'lecturer'    => 'Tamu Undangan',
                'color_tag'   => '#06B6D4',
            ],
            [
                'title'       => 'Organisasi BEM',
                'category'    => 'organization',
                'day_of_week' => Carbon::FRIDAY,
                'start_time'  => '15:00:00',
                'end_time'    => '17:00:00',
                'room'        => 'Sekretariat BEM',
                'lecturer'    => null,
                'color_tag'   => '#F59E0B',
            ],
        ];

        foreach ($schedules as $s) {
            Schedule::create(array_merge($s, [
                'user_id'    => $user->id,
                'is_active'  => true,
                'recurrence' => 'weekly',
                'start_date' => now()->startOfYear()->toDateString(),
            ]));
        }

        // ── Tasks (5 with various statuses) ───────────────────────────────
        $tasks = [
            [
                'title'       => 'Laporan Praktikum Basis Data',
                'description' => 'Buat laporan lengkap praktikum modul 3 beserta screenshot dan analisis hasil.',
                'priority'    => 'high',
                'status'      => 'pending',
                'deadline'    => now()->addDays(2)->setTime(23, 59),
            ],
            [
                'title'       => 'Tugas Matematika Diskrit',
                'description' => 'Kerjakan soal latihan bab 4: Graf dan Pohon halaman 87-92.',
                'priority'    => 'medium',
                'status'      => 'in_progress',
                'deadline'    => now()->addDays(5)->setTime(23, 59),
            ],
            [
                'title'       => 'Presentasi Seminar',
                'description' => 'Siapkan slide presentasi topik Machine Learning untuk seminar teknologi.',
                'priority'    => 'critical',
                'status'      => 'pending',
                'deadline'    => now()->addDays(1)->setTime(8, 0),
            ],
            [
                'title'       => 'Resume Jurnal IEEE',
                'description' => 'Baca dan buat resume jurnal "Deep Learning for Mobile Applications" 2024.',
                'priority'    => 'low',
                'status'      => 'pending',
                'deadline'    => now()->addDays(7)->setTime(23, 59),
            ],
            [
                'title'       => 'Quiz Online Pemrograman Bergerak',
                'description' => 'Selesaikan quiz online di e-learning tentang Flutter State Management.',
                'priority'    => 'high',
                'status'      => 'overdue',
                'deadline'    => now()->subDay()->setTime(23, 59),
            ],
        ];

        foreach ($tasks as $t) {
            Task::create(array_merge($t, [
                'user_id'      => $user->id,
                'completed_at' => $t['status'] === 'completed' ? now() : null,
            ]));
        }

        // ── User activities (30 days random, for heatmap) ──────────────────
        $activityTypes = [
            'login', 'view_schedule', 'read_announcement',
            'complete_task', 'attend_class', 'checklist_item',
        ];

        for ($i = 30; $i >= 0; $i--) {
            $date  = now()->subDays($i)->toDateString();
            $count = rand(0, 4); // 0-4 activities per day (some days empty for realism)

            if ($count === 0 && rand(0, 3) !== 0) {
                $count = rand(1, 3); // make most days have some activity
            }

            for ($j = 0; $j < $count; $j++) {
                UserActivity::create([
                    'user_id'       => $user->id,
                    'type'          => $activityTypes[array_rand($activityTypes)],
                    'activity_date' => $date,
                    'meta'          => [],
                ]);
            }
        }
    }
}

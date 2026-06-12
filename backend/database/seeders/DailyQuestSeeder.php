<?php

namespace Database\Seeders;

use App\Models\DailyQuest;
use Illuminate\Database\Seeder;

class DailyQuestSeeder extends Seeder
{
    public function run(): void
    {
        $quests = [
            [
                'key'           => 'daily_login',
                'title'         => 'Login Harian',
                'description'   => 'Buka aplikasi hari ini',
                'icon'          => '📱',
                'activity_type' => 'login',
                'target_count'  => 1,
                'points_reward' => 5,
                'is_active'     => true,
            ],
            [
                'key'           => 'view_schedule_once',
                'title'         => 'Cek Jadwal',
                'description'   => 'Lihat jadwal kegiatan hari ini',
                'icon'          => '📅',
                'activity_type' => 'view_schedule',
                'target_count'  => 1,
                'points_reward' => 5,
                'is_active'     => true,
            ],
            [
                'key'           => 'read_announcement_once',
                'title'         => 'Baca Pengumuman',
                'description'   => 'Baca minimal 1 pengumuman hari ini',
                'icon'          => '📢',
                'activity_type' => 'read_announcement',
                'target_count'  => 1,
                'points_reward' => 10,
                'is_active'     => true,
            ],
            [
                'key'           => 'complete_task_once',
                'title'         => 'Selesaikan Tugas',
                'description'   => 'Selesaikan minimal 1 tugas hari ini',
                'icon'          => '✅',
                'activity_type' => 'complete_task',
                'target_count'  => 1,
                'points_reward' => 20,
                'is_active'     => true,
            ],
            [
                'key'           => 'attend_class_once',
                'title'         => 'Hadir Kelas',
                'description'   => 'Scan absensi di minimal 1 sesi hari ini',
                'icon'          => '🎓',
                'activity_type' => 'attend_class',
                'target_count'  => 1,
                'points_reward' => 20,
                'is_active'     => true,
            ],
            [
                'key'           => 'checklist_3',
                'title'         => 'Checklist Aktif',
                'description'   => 'Tandai selesai 3 item kegiatan',
                'icon'          => '☑️',
                'activity_type' => 'checklist_item',
                'target_count'  => 3,
                'points_reward' => 15,
                'is_active'     => true,
            ],
        ];

        foreach ($quests as $data) {
            DailyQuest::updateOrCreate(['key' => $data['key']], $data);
        }
    }
}

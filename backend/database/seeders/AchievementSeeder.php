<?php

namespace Database\Seeders;

use App\Models\Achievement;
use Illuminate\Database\Seeder;

class AchievementSeeder extends Seeder
{
    public function run(): void
    {
        $achievements = [
            // ── Engagement ────────────────────────────────────────────────────
            [
                'key'             => 'first_login',
                'title'           => 'Langkah Pertama',
                'description'     => 'Login pertama kali ke aplikasi',
                'icon'            => '🚀',
                'badge_color'     => '#6366F1',
                'category'        => 'engagement',
                'condition_type'  => 'login_count',
                'condition_value' => 1,
                'points_reward'   => 10,
            ],
            [
                'key'             => 'login_10',
                'title'           => 'Rajin Login',
                'description'     => 'Login sebanyak 10 kali',
                'icon'            => '📱',
                'badge_color'     => '#818CF8',
                'category'        => 'engagement',
                'condition_type'  => 'login_count',
                'condition_value' => 10,
                'points_reward'   => 20,
            ],

            // ── Streak ────────────────────────────────────────────────────────
            [
                'key'             => 'streak_3',
                'title'           => 'Konsisten 3 Hari',
                'description'     => 'Aktif 3 hari berturut-turut',
                'icon'            => '🔥',
                'badge_color'     => '#F59E0B',
                'category'        => 'engagement',
                'condition_type'  => 'streak_days',
                'condition_value' => 3,
                'points_reward'   => 15,
            ],
            [
                'key'             => 'streak_7',
                'title'           => 'Konsisten 7 Hari',
                'description'     => 'Aktif 7 hari berturut-turut',
                'icon'            => '🔥',
                'badge_color'     => '#F59E0B',
                'category'        => 'engagement',
                'condition_type'  => 'streak_days',
                'condition_value' => 7,
                'points_reward'   => 30,
            ],
            [
                'key'             => 'streak_30',
                'title'           => 'Konsisten 30 Hari',
                'description'     => 'Aktif 30 hari berturut-turut',
                'icon'            => '🔥🌟',
                'badge_color'     => '#EF4444',
                'category'        => 'engagement',
                'condition_type'  => 'streak_days',
                'condition_value' => 30,
                'points_reward'   => 100,
            ],
            [
                'key'             => 'streak_100',
                'title'           => 'Konsisten 100 Hari',
                'description'     => 'Aktif 100 hari berturut-turut',
                'icon'            => '🔥💎',
                'badge_color'     => '#B9F2FF',
                'category'        => 'engagement',
                'condition_type'  => 'streak_days',
                'condition_value' => 100,
                'points_reward'   => 500,
            ],

            // ── Academic ─────────────────────────────────────────────────────
            [
                'key'             => 'first_task',
                'title'           => 'Tugas Pertama',
                'description'     => 'Selesaikan tugas pertamamu',
                'icon'            => '✅',
                'badge_color'     => '#10B981',
                'category'        => 'academic',
                'condition_type'  => 'task_count',
                'condition_value' => 1,
                'points_reward'   => 10,
            ],
            [
                'key'             => 'task_master_10',
                'title'           => 'Task Hunter',
                'description'     => 'Selesaikan 10 tugas',
                'icon'            => '⚡',
                'badge_color'     => '#10B981',
                'category'        => 'academic',
                'condition_type'  => 'task_count',
                'condition_value' => 10,
                'points_reward'   => 30,
            ],
            [
                'key'             => 'task_master_50',
                'title'           => 'Task Master',
                'description'     => 'Selesaikan 50 tugas',
                'icon'            => '🏆',
                'badge_color'     => '#FFD700',
                'category'        => 'academic',
                'condition_type'  => 'task_count',
                'condition_value' => 50,
                'points_reward'   => 100,
            ],
            [
                'key'             => 'announcement_reader_10',
                'title'           => 'Info Seeker',
                'description'     => 'Baca 10 pengumuman',
                'icon'            => '📢',
                'badge_color'     => '#06B6D4',
                'category'        => 'academic',
                'condition_type'  => 'announcement_read',
                'condition_value' => 10,
                'points_reward'   => 20,
            ],
            [
                'key'             => 'attendance_5',
                'title'           => 'Hadir Terus',
                'description'     => 'Hadir di 5 sesi kelas',
                'icon'            => '🎓',
                'badge_color'     => '#8B5CF6',
                'category'        => 'academic',
                'condition_type'  => 'attendance_count',
                'condition_value' => 5,
                'points_reward'   => 30,
            ],

            // ── Point milestones ──────────────────────────────────────────────
            [
                'key'             => 'points_500',
                'title'           => 'Silver Hunter',
                'description'     => 'Kumpulkan total 500 poin',
                'icon'            => '🥈',
                'badge_color'     => '#C0C0C0',
                'category'        => 'engagement',
                'condition_type'  => 'total_points',
                'condition_value' => 500,
                'points_reward'   => 0,
            ],
            [
                'key'             => 'points_2000',
                'title'           => 'Gold Achiever',
                'description'     => 'Kumpulkan total 2.000 poin',
                'icon'            => '🥇',
                'badge_color'     => '#FFD700',
                'category'        => 'engagement',
                'condition_type'  => 'total_points',
                'condition_value' => 2000,
                'points_reward'   => 0,
            ],
        ];

        foreach ($achievements as $data) {
            Achievement::updateOrCreate(['key' => $data['key']], $data);
        }
    }
}

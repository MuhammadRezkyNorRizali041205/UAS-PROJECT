<?php
// app/Services/AnalyticsService.php

namespace App\Services;

use App\Models\Schedule;
use App\Models\Task;
use App\Models\User;
use App\Models\UserActivity;
use Carbon\Carbon;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class AnalyticsService
{
    public function getDashboardData(User $user): array
    {
        return Cache::store('file')->remember(
            "dashboard_v2_{$user->id}",
            300,
            fn () => [
                'greeting'           => $this->greeting($user->name),
                'today_schedules'    => $this->todaySchedules($user),
                'upcoming_deadlines' => $this->upcomingDeadlines($user),
                'weekly_stats'       => $this->weeklyStats($user),
                'streak'             => $this->streak($user),
                'total_schedules'    => Schedule::where('user_id', $user->id)
                    ->where('is_active', true)
                    ->count(),
            ]
        );
    }

    public function invalidateDashboardCache(int $userId): void
    {
        Cache::store('file')->forget("dashboard_v2_{$userId}");
    }

    // ─── Dashboard sub-sections ───────────────────────────────────────────────

    private function greeting(string $name): string
    {
        $first = explode(' ', trim($name))[0];
        $hour  = now()->hour;

        $part = match (true) {
            $hour < 11  => 'pagi',
            $hour < 15  => 'siang',
            $hour < 18  => 'sore',
            default     => 'malam',
        };

        return "Selamat {$part}, {$first}!";
    }

    private function todaySchedules(User $user): array
    {
        return Schedule::where('user_id', $user->id)
            ->where('is_active', true)
            ->where('day_of_week', now()->dayOfWeek)
            ->orderBy('start_time')
            ->limit(5)
            ->get()
            ->map(fn ($s) => [
                'id'             => $s->id,
                'title'          => $s->title,
                'category'       => $s->category,
                'start_time'     => substr($s->start_time, 0, 5),
                'end_time'       => substr($s->end_time, 0, 5),
                'room'           => $s->room,
                'lecturer'       => $s->lecturer,
                'category_color' => $this->categoryHex($s->category),
            ])
            ->all();
    }

    private function upcomingDeadlines(User $user): array
    {
        return Task::forUser($user->id)
            ->whereNotIn('status', ['completed', 'overdue'])
            ->whereNotNull('deadline')
            ->whereBetween('deadline', [now(), now()->addDays(7)])
            ->orderBy('deadline')
            ->limit(5)
            ->get()
            ->map(fn ($t) => [
                'id'                 => $t->id,
                'title'              => $t->title,
                'priority'           => $t->priority,
                'deadline'           => $t->deadline?->toIso8601String(),
                'deadline_formatted' => $t->deadline?->locale('id')
                    ->isoFormat('ddd, D MMM YYYY HH:mm'),
                'days_until_due'     => (int) now()->diffInDays($t->deadline, false),
            ])
            ->all();
    }

    private function weeklyStats(User $user): array
    {
        $total     = Task::forUser($user->id)->count();
        $completed = Task::forUser($user->id)->where('status', 'completed')->count();
        $overdue   = Task::forUser($user->id)->where('status', 'overdue')->count();

        return [
            'total_tasks'     => $total,
            'completed_tasks' => $completed,
            'overdue_tasks'   => $overdue,
            'completion_rate' => $total > 0
                ? round(($completed / $total) * 100, 1)
                : 0.0,
        ];
    }

    private function streak(User $user): int
    {
        $date = now()->startOfDay();

        // If no activity today yet, start counting from yesterday
        $hasToday = UserActivity::where('user_id', $user->id)
            ->whereDate('activity_date', $date->toDateString())
            ->exists();

        if (!$hasToday) {
            $date->subDay();
        }

        $streak = 0;
        for ($i = 0; $i < 365; $i++) {
            $exists = UserActivity::where('user_id', $user->id)
                ->whereDate('activity_date', $date->toDateString())
                ->exists();

            if (!$exists) break;

            $streak++;
            $date->subDay();
        }

        return $streak;
    }

    // ─── Heatmap ──────────────────────────────────────────────────────────────

    public function getHeatmapData(User $user, int $weeks = 16): array
    {
        $days  = min($weeks * 7, 365);
        $start = now()->subDays($days)->startOfDay();

        $activities = DB::table('user_activities')
            ->where('user_id', $user->id)
            ->where('activity_date', '>=', $start->toDateString())
            ->selectRaw('activity_date as date, COUNT(*) as count')
            ->groupBy('activity_date')
            ->pluck('count', 'date');

        $completions = Task::forUser($user->id)
            ->whereNotNull('completed_at')
            ->where('completed_at', '>=', $start)
            ->selectRaw('DATE(completed_at) as date, COUNT(*) as count')
            ->groupBy('date')
            ->pluck('count', 'date');

        $data = [];
        for ($i = $days; $i >= 0; $i--) {
            $date   = now()->subDays($i)->format('Y-m-d');
            $count  = (int)($activities[$date] ?? 0) + (int)($completions[$date] ?? 0);
            $data[] = ['date' => $date, 'count' => $count];
        }

        return $data;
    }

    // ─── Summary ──────────────────────────────────────────────────────────────

    public function getSummary(User $user, string $period = 'week'): array
    {
        $thisWeekCompleted = Task::forUser($user->id)
            ->where('status', 'completed')
            ->whereBetween('completed_at', [now()->startOfWeek(), now()->endOfWeek()])
            ->count();

        $lastWeekCompleted = Task::forUser($user->id)
            ->where('status', 'completed')
            ->whereBetween('completed_at', [
                now()->subWeek()->startOfWeek(),
                now()->subWeek()->endOfWeek(),
            ])
            ->count();

        $topDay   = DB::table('user_activities')
            ->where('user_id', $user->id)
            ->selectRaw('DAYOFWEEK(activity_date) as dow, COUNT(*) as count')
            ->groupBy('dow')
            ->orderByDesc('count')
            ->first();

        $dayNames = ['', 'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

        $chartData       = $this->getActivityChartData($user, $period);
        $totalActivities = array_sum(array_column($chartData, 'value'));
        $completedTasks  = Task::forUser($user->id)
            ->where('status', 'completed')
            ->where('completed_at', '>=', $this->periodStart($period))
            ->count();
        $totalTasksInPeriod = Task::forUser($user->id)
            ->where('created_at', '>=', $this->periodStart($period))
            ->count();

        return [
            // Backward-compatible existing fields
            'this_week_completed' => $thisWeekCompleted,
            'last_week_completed' => $lastWeekCompleted,
            'week_change'         => $thisWeekCompleted - $lastWeekCompleted,
            'most_productive_day' => $topDay ? ($dayNames[$topDay->dow] ?? '-') : '-',
            'active_schedules'    => Schedule::where('user_id', $user->id)
                ->where('is_active', true)
                ->count(),
            // New period-based fields
            'period'              => $period,
            'chart_data'          => $chartData,
            'summary'             => [
                'total_activities' => $totalActivities,
                'completed_tasks'  => $completedTasks,
                'completion_rate'  => $totalTasksInPeriod > 0
                    ? round(($completedTasks / $totalTasksInPeriod) * 100, 1)
                    : 0.0,
                'most_active_day'  => $topDay ? ($dayNames[$topDay->dow] ?? '-') : '-',
                'streak'           => $this->streak($user),
            ],
        ];
    }

    private function periodStart(string $period): Carbon
    {
        return match ($period) {
            'month' => now()->subDays(29)->startOfDay(),
            'year'  => now()->subMonths(11)->startOfMonth(),
            default => now()->subDays(6)->startOfDay(), // week
        };
    }

    private function getActivityChartData(User $user, string $period): array
    {
        $dayNamesShort = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
        $monthNames    = [
            '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
            'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
        ];

        if ($period === 'year') {
            // 12 months: group by year-month
            $data = DB::table('user_activities')
                ->where('user_id', $user->id)
                ->where('activity_date', '>=', now()->subMonths(11)->startOfMonth()->toDateString())
                ->selectRaw("DATE_FORMAT(activity_date, '%Y-%m') as ym, COUNT(*) as cnt")
                ->groupBy('ym')
                ->pluck('cnt', 'ym');

            $result = [];
            for ($i = 11; $i >= 0; $i--) {
                $m     = now()->subMonths($i);
                $key   = $m->format('Y-m');
                $result[] = [
                    'label' => $monthNames[(int) $m->format('n')],
                    'value' => (float) ($data[$key] ?? 0),
                ];
            }
            return $result;
        }

        if ($period === 'month') {
            // 30 days: group by date
            $data = DB::table('user_activities')
                ->where('user_id', $user->id)
                ->where('activity_date', '>=', now()->subDays(29)->toDateString())
                ->selectRaw('activity_date as dt, COUNT(*) as cnt')
                ->groupBy('dt')
                ->pluck('cnt', 'dt');

            $result = [];
            for ($i = 29; $i >= 0; $i--) {
                $d   = now()->subDays($i);
                $key = $d->toDateString();
                $result[] = [
                    'label' => $d->format('j'),
                    'value' => (float) ($data[$key] ?? 0),
                ];
            }
            return $result;
        }

        // week: 7 days
        $data = DB::table('user_activities')
            ->where('user_id', $user->id)
            ->where('activity_date', '>=', now()->subDays(6)->toDateString())
            ->selectRaw('activity_date as dt, COUNT(*) as cnt')
            ->groupBy('dt')
            ->pluck('cnt', 'dt');

        $result = [];
        for ($i = 6; $i >= 0; $i--) {
            $d   = now()->subDays($i);
            $key = $d->toDateString();
            $result[] = [
                'label' => $dayNamesShort[$d->dayOfWeek],
                'value' => (float) ($data[$key] ?? 0),
            ];
        }
        return $result;
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    private function categoryHex(string $category): string
    {
        return match ($category) {
            'lecture'      => '#6366F1',
            'practicum'    => '#8B5CF6',
            'seminar'      => '#06B6D4',
            'organization' => '#F59E0B',
            'task'         => '#10B981',
            'exam'         => '#EF4444',
            default        => '#6366F1',
        };
    }
}

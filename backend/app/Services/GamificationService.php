<?php

namespace App\Services;

use App\Events\AchievementUnlocked;
use App\Events\GamificationLevelUp;
use App\Events\QuestCompleted;
use App\Models\Achievement;
use App\Models\DailyQuest;
use App\Models\PointHistory;
use App\Models\Task;
use App\Models\UserAchievement;
use App\Models\UserPoint;
use App\Models\UserQuest;
use App\Models\UserStreak;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class GamificationService
{
    // ─── Point rewards per activity ───────────────────────────────────────────

    private const ACTIVITY_POINTS = [
        'login'             => 5,
        'view_schedule'     => 5,
        'read_announcement' => 10,
        'complete_task'     => 30,
        'attend_class'      => 20,
        'checklist_item'    => 10,
    ];

    // null = no daily cap (unlimited per day)
    private const DAILY_CAPS = [
        'login'             => 1,
        'view_schedule'     => 1,
        'read_announcement' => 3,
        'complete_task'     => null,
        'attend_class'      => null,
        'checklist_item'    => 5,
    ];

    // ─── Public entry point ───────────────────────────────────────────────────

    /**
     * Called by UserActivityObserver whenever a UserActivity is created.
     * Processes points, streak, quests, and achievements atomically.
     */
    public function processActivity(int $userId, string $activityType, array $meta = []): void
    {
        try {
            DB::transaction(function () use ($userId, $activityType, $meta) {
                $points = self::ACTIVITY_POINTS[$activityType] ?? 0;

                if ($points > 0 && $this->canEarnPoints($userId, $activityType)) {
                    $this->awardPoints($userId, $points, $activityType, $meta);
                }

                $this->updateStreak($userId);
                $this->updateQuests($userId, $activityType);
                $this->checkAchievements($userId);
            });
        } catch (\Throwable $e) {
            // Gamification must never break existing features
            Log::warning("Gamification processing failed for user {$userId}: " . $e->getMessage());
        }
    }

    // ─── Point management ─────────────────────────────────────────────────────

    private function awardPoints(int $userId, int $points, string $activityType, array $meta = []): void
    {
        PointHistory::create([
            'user_id'       => $userId,
            'points'        => $points,
            'type'          => 'earn',
            'activity_type' => $activityType,
            'description'   => PointHistory::ACTIVITY_LABELS[$activityType] ?? $activityType,
            'meta'          => empty($meta) ? null : $meta,
        ]);

        $userPoint = UserPoint::lockForUpdate()->firstOrCreate(
            ['user_id' => $userId],
            [
                'total_points'         => 0,
                'level'                => 'bronze',
                'current_level_points' => 0,
                'next_level_threshold' => 500,
            ]
        );

        $oldLevel = $userPoint->level;
        $userPoint->total_points          += $points;
        $userPoint->current_level_points  += $points;

        $newLevel = $this->calculateLevel($userPoint->total_points);
        if ($newLevel !== $oldLevel) {
            $userPoint->level                = $newLevel;
            $userPoint->next_level_threshold = $this->getNextThreshold($newLevel);
            $userPoint->save();

            // Fire event after transaction completes (DB commit first)
            DB::afterCommit(fn () => event(new GamificationLevelUp(
                user:     $userPoint->user,
                oldLevel: $oldLevel,
                newLevel: $newLevel,
            )));
        } else {
            $userPoint->save();
        }
    }

    private function canEarnPoints(int $userId, string $activityType): bool
    {
        $cap = self::DAILY_CAPS[$activityType] ?? null;
        if ($cap === null) return true;

        $count = PointHistory::where('user_id', $userId)
            ->where('activity_type', $activityType)
            ->whereDate('created_at', today())
            ->count();

        return $count < $cap;
    }

    // ─── Streak management ────────────────────────────────────────────────────

    private function updateStreak(int $userId): void
    {
        $streak = UserStreak::lockForUpdate()->firstOrCreate(
            ['user_id' => $userId],
            ['current_streak' => 0, 'longest_streak' => 0]
        );

        $today     = today()->toDateString();
        $yesterday = today()->subDay()->toDateString();

        // Already counted for today — nothing to do
        if ($streak->last_activity_date?->toDateString() === $today) return;

        if ($streak->last_activity_date?->toDateString() === $yesterday) {
            $streak->current_streak++;
        } else {
            // Streak broken or first activity ever
            $streak->current_streak = 1;
        }

        if ($streak->current_streak > $streak->longest_streak) {
            $streak->longest_streak = $streak->current_streak;
        }

        $streak->last_activity_date = $today;
        $streak->save();
    }

    // ─── Quest management ─────────────────────────────────────────────────────

    private function updateQuests(int $userId, string $activityType): void
    {
        $today  = today()->toDateString();
        $quests = DailyQuest::active()->where('activity_type', $activityType)->get();

        foreach ($quests as $quest) {
            $userQuest = UserQuest::firstOrCreate(
                ['user_id' => $userId, 'quest_id' => $quest->id, 'quest_date' => $today],
                ['progress' => 0, 'is_completed' => false]
            );

            if ($userQuest->is_completed) continue;

            $userQuest->progress++;

            if ($userQuest->progress >= $quest->target_count) {
                $userQuest->is_completed = true;
                $userQuest->completed_at = now();
                $userQuest->save();

                // Quest completion bonus points (no daily cap — one quest = one reward)
                PointHistory::create([
                    'user_id'       => $userId,
                    'points'        => $quest->points_reward,
                    'type'          => 'earn',
                    'activity_type' => 'quest_complete',
                    'description'   => "Quest: {$quest->title}",
                    'meta'          => ['quest_key' => $quest->key],
                ]);

                UserPoint::where('user_id', $userId)->increment('total_points', $quest->points_reward);
                UserPoint::where('user_id', $userId)->increment('current_level_points', $quest->points_reward);

                $capturedQuest = $quest;
                DB::afterCommit(fn () => event(new QuestCompleted(
                    user:  \App\Models\User::find($userId),
                    quest: $capturedQuest,
                )));
            } else {
                $userQuest->save();
            }
        }
    }

    // ─── Achievement management ───────────────────────────────────────────────

    private function checkAchievements(int $userId): void
    {
        $earnedIds  = UserAchievement::where('user_id', $userId)->pluck('achievement_id');
        $candidates = Achievement::whereNotIn('id', $earnedIds)->get();

        foreach ($candidates as $achievement) {
            if (!$this->meetsCondition($userId, $achievement)) continue;

            UserAchievement::create([
                'user_id'        => $userId,
                'achievement_id' => $achievement->id,
                'earned_at'      => now(),
            ]);

            if ($achievement->points_reward > 0) {
                PointHistory::create([
                    'user_id'       => $userId,
                    'points'        => $achievement->points_reward,
                    'type'          => 'earn',
                    'activity_type' => 'achievement',
                    'description'   => "Achievement: {$achievement->title}",
                    'meta'          => ['achievement_key' => $achievement->key],
                ]);

                UserPoint::where('user_id', $userId)->increment('total_points', $achievement->points_reward);
            }

            $capturedAchievement = $achievement;
            DB::afterCommit(fn () => event(new AchievementUnlocked(
                user:        \App\Models\User::find($userId),
                achievement: $capturedAchievement,
            )));
        }
    }

    private function meetsCondition(int $userId, Achievement $achievement): bool
    {
        return match ($achievement->condition_type) {
            'streak_days'      => $this->getStreakDays($userId) >= $achievement->condition_value,
            'task_count'       => $this->getCompletedTaskCount($userId) >= $achievement->condition_value,
            'login_count'      => $this->getLoginCount($userId) >= $achievement->condition_value,
            'announcement_read'=> $this->getAnnouncementReadCount($userId) >= $achievement->condition_value,
            'total_points'     => $this->getTotalPoints($userId) >= $achievement->condition_value,
            'attendance_count' => $this->getAttendanceCount($userId) >= $achievement->condition_value,
            default            => false,
        };
    }

    // ─── Condition helpers (query helpers, not cached — called once per activity) ──

    private function getStreakDays(int $userId): int
    {
        return UserStreak::where('user_id', $userId)->value('current_streak') ?? 0;
    }

    private function getCompletedTaskCount(int $userId): int
    {
        return Task::where('user_id', $userId)->where('status', 'completed')->count();
    }

    private function getLoginCount(int $userId): int
    {
        return PointHistory::where('user_id', $userId)->where('activity_type', 'login')->count();
    }

    private function getAnnouncementReadCount(int $userId): int
    {
        return PointHistory::where('user_id', $userId)->where('activity_type', 'read_announcement')->count();
    }

    private function getTotalPoints(int $userId): int
    {
        return UserPoint::where('user_id', $userId)->value('total_points') ?? 0;
    }

    private function getAttendanceCount(int $userId): int
    {
        return \App\Models\AttendanceLog::where('user_id', $userId)->count();
    }

    // ─── Level calculation ────────────────────────────────────────────────────

    private function calculateLevel(int $totalPoints): string
    {
        $thresholds = array_reverse(UserPoint::LEVEL_THRESHOLDS, true);
        foreach ($thresholds as $level => $threshold) {
            if ($totalPoints >= $threshold) return $level;
        }
        return 'bronze';
    }

    private function getNextThreshold(string $currentLevel): int
    {
        $levels = array_keys(UserPoint::LEVEL_THRESHOLDS);
        $idx    = array_search($currentLevel, $levels, true);

        if ($idx !== false && $idx < count($levels) - 1) {
            return UserPoint::LEVEL_THRESHOLDS[$levels[$idx + 1]];
        }
        return PHP_INT_MAX; // Diamond: no next level
    }

    // ─── Public query methods (used by controller) ────────────────────────────

    public function getProfile(int $userId): array
    {
        $userPoint = UserPoint::firstOrCreate(
            ['user_id' => $userId],
            ['total_points' => 0, 'level' => 'bronze', 'current_level_points' => 0, 'next_level_threshold' => 500]
        );

        $streak = UserStreak::firstOrCreate(
            ['user_id' => $userId],
            ['current_streak' => 0, 'longest_streak' => 0]
        );

        $recentAchievements = UserAchievement::where('user_id', $userId)
            ->with('achievement')
            ->orderByDesc('earned_at')
            ->limit(5)
            ->get();

        $today = today()->toDateString();
        $totalQuests     = DailyQuest::active()->count();
        $completedQuests = UserQuest::where('user_id', $userId)
            ->where('quest_date', $today)
            ->where('is_completed', true)
            ->count();

        $rank = UserPoint::where('total_points', '>', $userPoint->total_points)->count() + 1;

        return compact('userPoint', 'streak', 'recentAchievements', 'completedQuests', 'totalQuests', 'rank');
    }

    public function getTodayQuests(int $userId): \Illuminate\Support\Collection
    {
        $today  = today()->toDateString();
        $quests = DailyQuest::active()->orderBy('points_reward')->get();

        return $quests->map(function (DailyQuest $quest) use ($userId, $today) {
            $userQuest = UserQuest::where('user_id', $userId)
                ->where('quest_id', $quest->id)
                ->where('quest_date', $today)
                ->first();

            $quest->user_progress   = $userQuest?->progress ?? 0;
            $quest->is_completed    = $userQuest?->is_completed ?? false;
            $quest->completed_at    = $userQuest?->completed_at;
            return $quest;
        });
    }

    public function getAchievements(int $userId): array
    {
        $earned = UserAchievement::where('user_id', $userId)
            ->with('achievement')
            ->orderByDesc('earned_at')
            ->get()
            ->map(fn ($ua) => array_merge(
                $ua->achievement->toArray(),
                ['is_earned' => true, 'earned_at' => $ua->earned_at]
            ));

        $earnedIds = $earned->pluck('id');
        $locked = Achievement::whereNotIn('id', $earnedIds)
            ->get()
            ->map(fn ($a) => array_merge(
                $a->toArray(),
                ['is_earned' => false, 'earned_at' => null]
            ));

        return ['earned' => $earned, 'locked' => $locked];
    }

    public function getPointHistory(int $userId, int $perPage = 20): \Illuminate\Contracts\Pagination\LengthAwarePaginator
    {
        return PointHistory::where('user_id', $userId)
            ->orderByDesc('created_at')
            ->paginate($perPage);
    }
}

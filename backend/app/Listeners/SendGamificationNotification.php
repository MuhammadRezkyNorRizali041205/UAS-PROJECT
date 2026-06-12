<?php

namespace App\Listeners;

use App\Events\AchievementUnlocked;
use App\Events\GamificationLevelUp;
use App\Events\QuestCompleted;
use App\Models\NotificationLog;
use App\Models\UserPoint;

class SendGamificationNotification
{
    /**
     * Handle level-up notifications.
     */
    public function handleLevelUp(GamificationLevelUp $event): void
    {
        $levelLabels = \App\Models\UserPoint::LEVEL_LABELS;
        $newLabel = $levelLabels[$event->newLevel] ?? $event->newLevel;

        NotificationLog::create([
            'user_id' => $event->user->id,
            'type'    => 'level_up',
            'title'   => "🎉 Naik Level!",
            'body'    => "Selamat! Kamu sekarang di level {$newLabel}. Terus semangat!",
            'data'    => ['level' => $event->newLevel, 'old_level' => $event->oldLevel],
            'sent_at' => now(),
        ]);

        // TODO: Send FCM via user->fcm_token when notification service is ready
    }

    /**
     * Handle achievement-unlocked notifications.
     */
    public function handleAchievement(AchievementUnlocked $event): void
    {
        NotificationLog::create([
            'user_id' => $event->user->id,
            'type'    => 'achievement_unlocked',
            'title'   => "{$event->achievement->icon} Achievement Baru!",
            'body'    => "Kamu mendapatkan badge '{$event->achievement->title}'!",
            'data'    => ['achievement_key' => $event->achievement->key],
            'sent_at' => now(),
        ]);
    }

    /**
     * Handle quest-completed notifications.
     */
    public function handleQuestCompleted(QuestCompleted $event): void
    {
        NotificationLog::create([
            'user_id' => $event->user->id,
            'type'    => 'quest_completed',
            'title'   => "{$event->quest->icon} Quest Selesai!",
            'body'    => "'{$event->quest->title}' +{$event->quest->points_reward} poin",
            'data'    => ['quest_key' => $event->quest->key, 'points' => $event->quest->points_reward],
            'sent_at' => now(),
        ]);
    }
}

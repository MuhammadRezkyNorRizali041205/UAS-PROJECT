<?php

namespace App\Observers;

use App\Models\UserActivity;
use App\Services\GamificationService;

class UserActivityObserver
{
    public function __construct(private readonly GamificationService $gamificationService) {}

    /**
     * Hook into the existing UserActivity creation flow (non-invasive).
     * Every time any part of the app creates a UserActivity record,
     * gamification is processed automatically without modifying existing controllers.
     */
    public function created(UserActivity $activity): void
    {
        $this->gamificationService->processActivity(
            userId: $activity->user_id,
            activityType: $activity->type,
            meta: is_array($activity->meta) ? $activity->meta : [],
        );
    }
}

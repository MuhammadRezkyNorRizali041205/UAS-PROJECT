<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GamificationProfileResource extends JsonResource
{
    /**
     * @param  array{userPoint, streak, recentAchievements, completedQuests, totalQuests, rank}  $resource
     */
    public function toArray(Request $request): array
    {
        $up = $this->resource['userPoint'];
        $st = $this->resource['streak'];

        return [
            'total_points'           => $up->total_points,
            'level'                  => $up->level,
            'level_label'            => $up->level_label,
            'level_color'            => $up->level_color,
            'current_level_points'   => $up->current_level_points,
            'next_level_threshold'   => $up->next_level_threshold,
            'progress_percentage'    => $up->progress_percentage,
            'rank'                   => $this->resource['rank'],

            'streak' => [
                'current'            => $st->current_streak,
                'longest'            => $st->longest_streak,
                'last_activity_date' => $st->last_activity_date?->toDateString(),
                'is_active_today'    => $st->getIsActiveToday(),
                'emoji'              => $st->streak_emoji,
            ],

            'recent_achievements' => $this->resource['recentAchievements']
                ->map(fn ($ua) => [
                    'id'          => $ua->achievement->id,
                    'key'         => $ua->achievement->key,
                    'title'       => $ua->achievement->title,
                    'description' => $ua->achievement->description,
                    'icon'        => $ua->achievement->icon,
                    'badge_color' => $ua->achievement->badge_color,
                    'earned_at'   => $ua->earned_at,
                ]),

            'today_quests_completed' => $this->resource['completedQuests'],
            'today_quests_total'     => $this->resource['totalQuests'],
        ];
    }
}

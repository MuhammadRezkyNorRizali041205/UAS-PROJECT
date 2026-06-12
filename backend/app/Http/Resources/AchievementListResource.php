<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AchievementListResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'earned' => collect($this->resource['earned'])->map(fn ($a) => $this->formatAchievement($a)),
            'locked' => collect($this->resource['locked'])->map(fn ($a) => $this->formatAchievement($a)),
        ];
    }

    private function formatAchievement(array $a): array
    {
        return [
            'id'              => $a['id'],
            'key'             => $a['key'],
            'title'           => $a['title'],
            'description'     => $a['description'],
            'icon'            => $a['icon'],
            'badge_color'     => $a['badge_color'],
            'category'        => $a['category'],
            'points_reward'   => $a['points_reward'],
            'is_earned'       => $a['is_earned'],
            'earned_at'       => $a['earned_at'],
        ];
    }
}

<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class QuestResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'            => $this->id,
            'key'           => $this->key,
            'title'         => $this->title,
            'description'   => $this->description,
            'icon'          => $this->icon,
            'target_count'  => $this->target_count,
            'points_reward' => $this->points_reward,
            'progress'      => $this->user_progress ?? 0,
            'is_completed'  => $this->is_completed ?? false,
            'completed_at'  => $this->completed_at ?? null,
        ];
    }
}

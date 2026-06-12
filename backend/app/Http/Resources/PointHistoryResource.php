<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PointHistoryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'             => $this->id,
            'points'         => $this->points,
            'type'           => $this->type,
            'activity_type'  => $this->activity_type,
            'activity_label' => $this->activity_label,
            'description'    => $this->description,
            'meta'           => $this->meta,
            'created_at'     => $this->created_at,
        ];
    }
}

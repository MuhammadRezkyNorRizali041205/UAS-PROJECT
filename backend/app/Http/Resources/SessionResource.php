<?php
// app/Http/Resources/SessionResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SessionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'              => $this->id,
            'course_name'     => $this->course_name,
            'session_code'    => $this->session_code,
            'location'        => $this->location,
            'latitude'        => $this->latitude,
            'longitude'       => $this->longitude,
            'radius_m'        => $this->radius_m,
            'starts_at'       => $this->starts_at->toIso8601String(),
            'ends_at'         => $this->ends_at->toIso8601String(),
            'is_active'       => $this->isActive(),
            'attendee_count'  => $this->whenLoaded('logs', fn () => $this->logs->count()),
            'creator'         => $this->whenLoaded('creator', fn () => [
                'id'   => $this->creator->id,
                'name' => $this->creator->name,
            ]),
        ];
    }
}

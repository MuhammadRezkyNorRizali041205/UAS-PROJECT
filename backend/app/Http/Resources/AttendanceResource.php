<?php
// app/Http/Resources/AttendanceResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AttendanceResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'          => $this->id,
            'session'     => $this->whenLoaded('session', fn () => [
                'id'          => $this->session->id,
                'course_name' => $this->session->course_name,
                'location'    => $this->session->location,
                'starts_at'   => $this->session->starts_at->toIso8601String(),
                'ends_at'     => $this->session->ends_at->toIso8601String(),
            ]),
            'scanned_at'  => $this->scanned_at->toIso8601String(),
            'scanned_at_formatted' => $this->scanned_at
                ->locale('id')->isoFormat('ddd, D MMM YYYY HH:mm'),
        ];
    }
}

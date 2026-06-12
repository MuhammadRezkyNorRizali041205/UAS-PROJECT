<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProfileResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'avatar_url'         => $this->avatar_url,
            'bio'                => $this->bio,
            'phone'              => $this->phone,
            'faculty'            => $this->faculty,
            'major'              => $this->major,
            'student_id'         => $this->student_id,
            'year_entry'         => $this->year_entry,
            'notification_prefs' => $this->notification_prefs,
        ];
    }
}

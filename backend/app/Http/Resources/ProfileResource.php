<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProfileResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $notificationPrefs = $this['notification_prefs'] ?? [];

        return [
            'id' => (string) ($this['id'] ?? ''),
            'name' => $this['name'] ?? '',
            'email' => $this['email'] ?? '',
            'role' => $this['role'] ?? 'student',
            'avatar_url' => $this['avatar_url'],
            'profile' => [
                'nim' => $this['profile']['nim'] ?? null,
                'faculty' => $this['profile']['faculty'] ?? null,
                'major' => $this['profile']['major'] ?? null,
                'semester' => $this['profile']['semester'] ?? null,
                'phone' => $this['profile']['phone'] ?? null,
                'bio' => $this['profile']['bio'] ?? null,
            ],
            'stats' => [
                'total_schedules' => (int) ($this['stats']['total_schedules'] ?? 0),
                'total_tasks' => (int) ($this['stats']['total_tasks'] ?? 0),
                'completed_tasks' => (int) ($this['stats']['completed_tasks'] ?? 0),
                'completion_rate' => (float) ($this['stats']['completion_rate'] ?? 0),
                'streak' => (int) ($this['stats']['streak'] ?? 0),
            ],
            'notification_prefs' => [
                'schedule' => (bool) ($notificationPrefs['schedule'] ?? true),
                'task' => (bool) ($notificationPrefs['task'] ?? true),
                'announcement' => (bool) ($notificationPrefs['announcement'] ?? true),
                'attendance' => (bool) ($notificationPrefs['attendance'] ?? true),
            ],
        ];
    }
}

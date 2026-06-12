<?php
// app/Http/Resources/TaskResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TaskResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $now      = now();
        $deadline = $this->deadline;

        $daysUntilDue = null;
        $isOverdue    = false;

        if ($deadline) {
            $isOverdue    = $deadline->isPast() && $this->status !== 'completed';
            $daysUntilDue = (int) $now->diffInDays($deadline, false);
        }

        return [
            'id'                 => $this->id,
            'title'              => $this->title,
            'description'        => $this->description,
            'priority'           => $this->priority,
            'priority_label'     => $this->priorityLabel($this->priority),
            'status'             => $this->status,
            'status_label'       => $this->statusLabel($this->status),
            'deadline'           => $deadline?->toIso8601String(),
            'deadline_formatted' => $deadline?->locale('id')->isoFormat('dddd, D MMM YYYY HH:mm'),
            'completed_at'       => $this->completed_at?->toIso8601String(),
            'is_overdue'         => $isOverdue,
            'days_until_due'     => $daysUntilDue,
            'time_remaining'     => $this->timeRemaining($deadline, $isOverdue),
            'urgency_level'      => $this->urgencyLevel($deadline, $isOverdue),
            'category'       => $this->whenLoaded('category', fn () => [
                'id'    => $this->category->id,
                'name'  => $this->category->name,
                'color' => $this->category->color,
                'icon'  => $this->category->icon,
            ]),
            'created_at'     => $this->created_at->toIso8601String(),
            'updated_at'     => $this->updated_at->toIso8601String(),
        ];
    }

    private function timeRemaining(?\Carbon\Carbon $deadline, bool $isOverdue): ?string
    {
        if (!$deadline) return null;

        if ($isOverdue) {
            $hours = (int) abs(now()->diffInHours($deadline));
            return "Terlambat {$hours} jam";
        }

        $diffMins = (int) now()->diffInMinutes($deadline);
        $diffHrs  = (int) now()->diffInHours($deadline);
        $diffDays = (int) now()->diffInDays($deadline);

        if ($diffDays > 2)  return "{$diffDays} hari lagi";
        if ($diffHrs >= 3)  return "{$diffHrs} jam lagi";

        $h = (int) floor($diffMins / 60);
        $m = $diffMins % 60;

        if ($diffMins < 30) return "{$diffMins} menit lagi";
        return $h > 0 ? "{$h} jam {$m} menit lagi" : "{$diffMins} menit lagi";
    }

    private function urgencyLevel(?\Carbon\Carbon $deadline, bool $isOverdue): string
    {
        if (!$deadline || $this->status === 'completed') return 'safe';
        if ($isOverdue) return 'overdue';

        $diffHours = now()->diffInHours($deadline);
        if ($diffHours < 3)  return 'critical';
        if ($diffHours < 48) return 'warning';
        return 'safe';
    }

    private function priorityLabel(string $priority): string
    {
        return match ($priority) {
            'low'      => 'Rendah',
            'medium'   => 'Sedang',
            'high'     => 'Tinggi',
            'critical' => 'Kritis',
            default    => $priority,
        };
    }

    private function statusLabel(string $status): string
    {
        return match ($status) {
            'pending'     => 'Belum Mulai',
            'in_progress' => 'Dikerjakan',
            'completed'   => 'Selesai',
            'overdue'     => 'Terlambat',
            default       => $status,
        };
    }
}

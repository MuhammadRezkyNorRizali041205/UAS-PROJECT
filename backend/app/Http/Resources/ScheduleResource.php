<?php
// app/Http/Resources/ScheduleResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ScheduleResource extends JsonResource
{
    private static array $dayNames = [
        0 => 'Minggu',
        1 => 'Senin',
        2 => 'Selasa',
        3 => 'Rabu',
        4 => 'Kamis',
        5 => 'Jumat',
        6 => 'Sabtu',
    ];

    public function toArray(Request $request): array
    {
        $startTime = \Carbon\Carbon::parse($this->start_time);
        $endTime   = \Carbon\Carbon::parse($this->end_time);

        return [
            'id'               => $this->id,
            'title'            => $this->title,
            'category'         => $this->category,
            'day_of_week'      => $this->day_of_week,
            'day_name'         => self::$dayNames[$this->day_of_week] ?? '-',
            'start_time'       => substr($this->start_time, 0, 5),  // HH:mm
            'end_time'         => substr($this->end_time, 0, 5),
            'duration_minutes' => (int) $startTime->diffInMinutes($endTime),
            'room'             => $this->room,
            'lecturer'         => $this->lecturer,
            'recurrence'       => $this->recurrence,
            'start_date'       => $this->start_date?->toDateString(),
            'end_date'         => $this->end_date?->toDateString(),
            'color_tag'        => $this->color_tag,
            'is_active'        => $this->is_active,
            'is_today'         => $this->day_of_week === now()->dayOfWeek,
            'notes'            => $this->notes,
            'category_color'   => $this->categoryColor($this->category),
            'created_at'       => $this->created_at?->toISOString(),
            'updated_at'       => $this->updated_at?->toISOString(),
        ];
    }

    private function categoryColor(string $category): string
    {
        return match ($category) {
            'lecture'      => '#6366F1',
            'practicum'    => '#8B5CF6',
            'seminar'      => '#06B6D4',
            'organization' => '#F59E0B',
            'task'         => '#10B981',
            'exam'         => '#EF4444',
            default        => '#6366F1',
        };
    }
}

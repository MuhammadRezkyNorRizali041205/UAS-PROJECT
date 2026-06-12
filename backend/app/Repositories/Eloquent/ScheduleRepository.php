<?php
// app/Repositories/Eloquent/ScheduleRepository.php

namespace App\Repositories\Eloquent;

use App\Models\Schedule;
use App\Repositories\Contracts\ScheduleRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class ScheduleRepository implements ScheduleRepositoryInterface
{
    public function getAll(int $userId, array $filters = []): Collection
    {
        $query = Schedule::where('user_id', $userId)
            ->orderBy('day_of_week')
            ->orderBy('start_time');

        if (!empty($filters['category'])) {
            $query->where('category', $filters['category']);
        }

        if (isset($filters['day_of_week'])) {
            $query->where('day_of_week', (int) $filters['day_of_week']);
        }

        if (!empty($filters['recurrence'])) {
            $query->where('recurrence', $filters['recurrence']);
        }

        if (isset($filters['is_active'])) {
            $query->where('is_active', (bool) $filters['is_active']);
        }

        return $query->get();
    }

    public function findById(int $id): ?Schedule
    {
        return Schedule::find($id);
    }

    public function create(int $userId, array $data): Schedule
    {
        return Schedule::create(array_merge($data, ['user_id' => $userId]));
    }

    public function update(Schedule $schedule, array $data): Schedule
    {
        $schedule->update($data);
        return $schedule->fresh();
    }

    public function delete(Schedule $schedule): void
    {
        $schedule->delete();
    }

    public function getTodaySchedules(int $userId): Collection
    {
        return Schedule::where('user_id', $userId)
            ->today()
            ->get();
    }

    public function getWeekSchedules(int $userId): Collection
    {
        return Schedule::where('user_id', $userId)
            ->thisWeek()
            ->orderBy('day_of_week')
            ->orderBy('start_time')
            ->get();
    }
}

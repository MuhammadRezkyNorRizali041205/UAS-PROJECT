<?php
// app/Repositories/Contracts/ScheduleRepositoryInterface.php

namespace App\Repositories\Contracts;

use App\Models\Schedule;
use Illuminate\Database\Eloquent\Collection;

interface ScheduleRepositoryInterface
{
    public function getAll(int $userId, array $filters = []): Collection;

    public function findById(int $id): ?Schedule;

    public function create(int $userId, array $data): Schedule;

    public function update(Schedule $schedule, array $data): Schedule;

    public function delete(Schedule $schedule): void;

    public function getTodaySchedules(int $userId): Collection;

    public function getWeekSchedules(int $userId): Collection;
}

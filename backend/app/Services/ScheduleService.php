<?php
// app/Services/ScheduleService.php

namespace App\Services;

use App\Models\Schedule;
use App\Models\User;
use App\Models\UserActivity;
use App\Repositories\Contracts\ScheduleRepositoryInterface;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\Collection;

class ScheduleService
{
    public function __construct(
        private readonly ScheduleRepositoryInterface $repository
    ) {}

    public function getAll(User $user, array $filters = []): Collection
    {
        return $this->repository->getAll($user->id, $filters);
    }

    public function getById(User $user, int $id): Schedule
    {
        $schedule = $this->repository->findById($id);

        if (!$schedule || $schedule->user_id !== $user->id) {
            throw new AuthorizationException('Jadwal tidak ditemukan.');
        }

        return $schedule;
    }

    public function create(User $user, array $data): Schedule
    {
        $schedule = $this->repository->create($user->id, $data);

        $this->logActivity($user->id, 'schedule_created', [
            'schedule_id' => $schedule->id,
            'title'       => $schedule->title,
        ]);

        return $schedule;
    }

    public function update(User $user, int $id, array $data): Schedule
    {
        $schedule = $this->getById($user, $id);
        $updated  = $this->repository->update($schedule, $data);

        $this->logActivity($user->id, 'schedule_updated', [
            'schedule_id' => $schedule->id,
            'title'       => $schedule->title,
        ]);

        return $updated;
    }

    public function delete(User $user, int $id): void
    {
        $schedule = $this->getById($user, $id);

        $this->logActivity($user->id, 'schedule_deleted', [
            'schedule_id' => $schedule->id,
            'title'       => $schedule->title,
        ]);

        $this->repository->delete($schedule);
    }

    public function getToday(User $user): Collection
    {
        return $this->repository->getTodaySchedules($user->id);
    }

    public function getWeek(User $user): Collection
    {
        return $this->repository->getWeekSchedules($user->id);
    }

    private function logActivity(int $userId, string $type, array $meta = []): void
    {
        UserActivity::create([
            'user_id'       => $userId,
            'type'          => $type,
            'meta'          => $meta,
            'activity_date' => today(),
        ]);
    }
}

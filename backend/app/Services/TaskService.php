<?php
// app/Services/TaskService.php

namespace App\Services;

use App\Models\Task;
use App\Models\User;
use App\Models\UserActivity;
use App\Repositories\Contracts\TaskRepositoryInterface;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\Collection;

class TaskService
{
    public function __construct(private readonly TaskRepositoryInterface $repo) {}

    public function getAll(User $user, array $filters = []): Collection
    {
        return $this->repo->getAll($user, $filters);
    }

    public function getById(User $user, int $id): Task
    {
        $task = $this->repo->findById($id);

        if (!$task || $task->user_id !== $user->id) {
            throw new AuthorizationException('Tugas tidak ditemukan.');
        }

        return $task;
    }

    public function create(User $user, array $data): Task
    {
        $task = $this->repo->create(array_merge($data, [
            'user_id' => $user->id,
        ]));

        $this->logActivity($user->id, 'task_created', ['task_id' => $task->id, 'title' => $task->title]);

        return $task;
    }

    public function update(User $user, int $id, array $data): Task
    {
        $task = $this->getById($user, $id);

        if (isset($data['status']) && $data['status'] === 'completed' && !$task->completed_at) {
            $data['completed_at'] = now();
        }

        if (isset($data['status']) && $data['status'] !== 'completed') {
            $data['completed_at'] = null;
        }

        $updated = $this->repo->update($task, $data);

        $type = isset($data['status']) && $data['status'] === 'completed'
            ? 'task_completed'
            : 'task_updated';

        $this->logActivity($user->id, $type, ['task_id' => $updated->id, 'title' => $updated->title]);

        return $updated;
    }

    public function updateStatus(User $user, int $id, string $status): Task
    {
        return $this->update($user, $id, ['status' => $status]);
    }

    public function delete(User $user, int $id): void
    {
        $task = $this->getById($user, $id);
        $this->logActivity($user->id, 'task_deleted', ['task_id' => $task->id, 'title' => $task->title]);
        $this->repo->delete($task);
    }

    public function getUpcoming(User $user): Collection
    {
        return $this->repo->getUpcoming($user);
    }

    public function getOverdue(User $user): Collection
    {
        return $this->repo->getOverdue($user);
    }

    private function logActivity(int $userId, string $type, array $meta = []): void
    {
        try {
            UserActivity::create([
                'user_id'       => $userId,
                'type'          => $type,
                'meta'          => $meta,
                'activity_date' => today(),
            ]);
        } catch (\Throwable) {
            // Non-critical
        }
    }
}

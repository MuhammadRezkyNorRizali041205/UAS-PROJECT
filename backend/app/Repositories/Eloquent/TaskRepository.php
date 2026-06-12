<?php
// app/Repositories/Eloquent/TaskRepository.php

namespace App\Repositories\Eloquent;

use App\Models\Task;
use App\Models\User;
use App\Repositories\Contracts\TaskRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class TaskRepository implements TaskRepositoryInterface
{
    public function getAll(User $user, array $filters = []): Collection
    {
        $query = Task::with('category')
            ->forUser($user->id)
            ->orderByRaw("FIELD(priority, 'critical','high','medium','low')")
            ->orderBy('deadline');

        if (!empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (!empty($filters['priority'])) {
            $query->where('priority', $filters['priority']);
        }

        if (!empty($filters['category_id'])) {
            $query->where('category_id', $filters['category_id']);
        }

        if (isset($filters['has_deadline'])) {
            $filters['has_deadline']
                ? $query->whereNotNull('deadline')
                : $query->whereNull('deadline');
        }

        return $query->get();
    }

    public function findById(int $id): ?Task
    {
        return Task::with('category')->find($id);
    }

    public function create(array $data): Task
    {
        return Task::create($data);
    }

    public function update(Task $task, array $data): Task
    {
        $task->update($data);
        return $task->fresh('category');
    }

    public function delete(Task $task): void
    {
        $task->delete();
    }

    public function getUpcoming(User $user): Collection
    {
        return Task::with('category')
            ->forUser($user->id)
            ->upcoming()
            ->get();
    }

    public function getOverdue(User $user): Collection
    {
        return Task::with('category')
            ->forUser($user->id)
            ->overdue()
            ->get();
    }
}

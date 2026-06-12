<?php
// app/Repositories/Contracts/TaskRepositoryInterface.php

namespace App\Repositories\Contracts;

use App\Models\Task;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

interface TaskRepositoryInterface
{
    public function getAll(User $user, array $filters = []): Collection;

    public function findById(int $id): ?Task;

    public function create(array $data): Task;

    public function update(Task $task, array $data): Task;

    public function delete(Task $task): void;

    public function getUpcoming(User $user): Collection;

    public function getOverdue(User $user): Collection;
}

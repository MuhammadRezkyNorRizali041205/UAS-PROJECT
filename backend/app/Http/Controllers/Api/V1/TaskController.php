<?php
// app/Http/Controllers/Api/V1/TaskController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Task\StoreTaskRequest;
use App\Http\Requests\Task\UpdateTaskRequest;
use App\Http\Resources\TaskResource;
use App\Services\TaskService;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class TaskController extends Controller
{
    public function __construct(private readonly TaskService $service) {}

    public function index(Request $request): JsonResponse
    {
        $filters = $request->only(['status', 'priority', 'category_id', 'has_deadline']);
        $tasks   = $this->service->getAll($request->user(), $filters);

        return $this->success(TaskResource::collection($tasks), 'Berhasil mengambil tugas.');
    }

    public function store(StoreTaskRequest $request): JsonResponse
    {
        $task = $this->service->create($request->user(), $request->validated());

        return $this->success(new TaskResource($task), 'Tugas berhasil ditambahkan.', 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        try {
            $task = $this->service->getById($request->user(), $id);
            return $this->success(new TaskResource($task));
        } catch (AuthorizationException $e) {
            return $this->error($e->getMessage(), 404);
        }
    }

    public function update(UpdateTaskRequest $request, int $id): JsonResponse
    {
        try {
            $task = $this->service->update($request->user(), $id, $request->validated());
            return $this->success(new TaskResource($task), 'Tugas berhasil diperbarui.');
        } catch (AuthorizationException $e) {
            return $this->error($e->getMessage(), 404);
        }
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        try {
            $this->service->delete($request->user(), $id);
            return $this->success(null, 'Tugas berhasil dihapus.');
        } catch (AuthorizationException $e) {
            return $this->error($e->getMessage(), 404);
        }
    }

    public function updateStatus(Request $request, int $id): JsonResponse
    {
        try {
            $validated = $request->validate([
                'status' => ['required', 'in:pending,in_progress,completed,overdue'],
            ]);
            $task = $this->service->updateStatus($request->user(), $id, $validated['status']);
            return $this->success(new TaskResource($task), 'Status tugas diperbarui.');
        } catch (AuthorizationException $e) {
            return $this->error($e->getMessage(), 404);
        } catch (ValidationException $e) {
            return $this->error('Validasi gagal.', 422, $e->errors());
        }
    }

    public function upcoming(Request $request): JsonResponse
    {
        $tasks = $this->service->getUpcoming($request->user());
        return $this->success(TaskResource::collection($tasks), 'Tugas mendatang.');
    }

    public function overdue(Request $request): JsonResponse
    {
        $tasks = $this->service->getOverdue($request->user());
        return $this->success(TaskResource::collection($tasks), 'Tugas terlambat.');
    }
}

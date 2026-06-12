<?php
// app/Http/Controllers/Api/V1/ScheduleController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Schedule\StoreScheduleRequest;
use App\Http\Requests\Schedule\UpdateScheduleRequest;
use App\Http\Resources\ScheduleResource;
use App\Services\ScheduleService;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ScheduleController extends Controller
{
    public function __construct(private readonly ScheduleService $service) {}

    public function index(Request $request): JsonResponse
    {
        $filters   = $request->only(['category', 'day_of_week', 'recurrence', 'is_active']);
        $schedules = $this->service->getAll($request->user(), $filters);

        return $this->success(
            ScheduleResource::collection($schedules),
            'Berhasil mengambil jadwal.',
        );
    }

    public function store(StoreScheduleRequest $request): JsonResponse
    {
        $schedule = $this->service->create($request->user(), $request->validated());

        return $this->success(
            new ScheduleResource($schedule),
            'Jadwal berhasil ditambahkan.',
            201,
        );
    }

    public function show(Request $request, int $id): JsonResponse
    {
        try {
            $schedule = $this->service->getById($request->user(), $id);
            return $this->success(new ScheduleResource($schedule));
        } catch (AuthorizationException $e) {
            return $this->error($e->getMessage(), 404);
        }
    }

    public function update(UpdateScheduleRequest $request, int $id): JsonResponse
    {
        try {
            $schedule = $this->service->update($request->user(), $id, $request->validated());
            return $this->success(new ScheduleResource($schedule), 'Jadwal berhasil diperbarui.');
        } catch (AuthorizationException $e) {
            return $this->error($e->getMessage(), 404);
        }
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        try {
            $this->service->delete($request->user(), $id);
            return $this->success(null, 'Jadwal berhasil dihapus.');
        } catch (AuthorizationException $e) {
            return $this->error($e->getMessage(), 404);
        }
    }

    public function today(Request $request): JsonResponse
    {
        $schedules = $this->service->getToday($request->user());

        return $this->success(
            ScheduleResource::collection($schedules),
            'Jadwal hari ini.',
        );
    }

    public function week(Request $request): JsonResponse
    {
        $schedules = $this->service->getWeek($request->user());

        return $this->success(
            ScheduleResource::collection($schedules),
            'Jadwal minggu ini.',
        );
    }
}

<?php
// app/Http/Controllers/Api/V1/AnalyticsController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\AnalyticsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AnalyticsController extends Controller
{
    public function __construct(private readonly AnalyticsService $service) {}

    public function dashboard(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->role !== 'student') {
            return $this->success([
                'greeting'           => 'Selamat datang, ' . $user->name . '!',
                'today_schedules'    => [],
                'upcoming_deadlines' => [],
                'weekly_stats'       => [
                    'total_tasks'       => 0,
                    'completed_tasks'   => 0,
                    'overdue_tasks'     => 0,
                    'completion_rate'   => 0,
                ],
                'streak'           => 0,
                'total_schedules'  => 0,
            ], 'Dashboard data.');
        }

        $data = $this->service->getDashboardData($user);
        return $this->success($data, 'Dashboard data.');
    }

    public function heatmap(Request $request): JsonResponse
    {
        $weeks = (int) $request->query('weeks', 16);
        $data  = $this->service->getHeatmapData($request->user(), $weeks);
        return $this->success($data);
    }

    public function summary(Request $request): JsonResponse
    {
        $period = in_array($request->query('period'), ['week', 'month', 'year'])
            ? $request->query('period')
            : 'week';

        $data = $this->service->getSummary($request->user(), $period);
        return $this->success($data);
    }
}

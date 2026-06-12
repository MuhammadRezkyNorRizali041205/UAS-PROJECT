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
        $data = $this->service->getDashboardData($request->user());
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
        $data = $this->service->getSummary($request->user());
        return $this->success($data);
    }
}

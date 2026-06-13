<?php
// app/Http/Controllers/Api/V1/Lecturer/LecturerDashboardController.php

namespace App\Http\Controllers\Api\V1\Lecturer;

use App\Http\Controllers\Controller;
use App\Services\LecturerService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LecturerDashboardController extends Controller
{
    use ApiResponse;

    public function __construct(private LecturerService $service) {}

    public function __invoke(Request $request): JsonResponse
    {
        $stats = $this->service->getDashboardStats($request->user());
        return $this->success(data: $stats);
    }
}

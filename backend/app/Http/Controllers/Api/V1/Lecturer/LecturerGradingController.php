<?php
// app/Http/Controllers/Api/V1/Lecturer/LecturerGradingController.php

namespace App\Http\Controllers\Api\V1\Lecturer;

use App\Http\Controllers\Controller;
use App\Services\LecturerService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LecturerGradingController extends Controller
{
    use ApiResponse;

    public function __construct(private LecturerService $service) {}

    public function index(Request $request): JsonResponse
    {
        $pending = $this->service->getAllPendingGrading($request->user());
        return $this->success(data: [
            'submissions' => $pending,
            'total'       => count($pending),
        ]);
    }
}

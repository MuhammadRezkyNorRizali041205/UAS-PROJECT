<?php
// app/Http/Controllers/Api/V1/Organization/OrganizationDashboardController.php

namespace App\Http\Controllers\Api\V1\Organization;

use App\Http\Controllers\Controller;
use App\Services\OrganizationService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrganizationDashboardController extends Controller
{
    use ApiResponse;

    public function __construct(private OrganizationService $service) {}

    public function __invoke(Request $request): JsonResponse
    {
        $org = $this->service->getOrganizationForUser($request->user());

        if (!$org) {
            return $this->error('Organisasi tidak ditemukan.', 404);
        }

        $stats  = $this->service->getDashboardStats($org);
        $detail = $this->service->getOrganizationDetail($org);

        $upcomingEvents = $this->service->getEvents($org, 'published')
            ->take(5)
            ->values();

        return $this->success(data: [
            'organization'    => $detail,
            'stats'           => $stats,
            'upcoming_events' => $upcomingEvents,
        ]);
    }
}

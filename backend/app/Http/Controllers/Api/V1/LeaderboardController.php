<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\LeaderboardService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LeaderboardController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly LeaderboardService $leaderboardService) {}

    /**
     * GET /v1/leaderboard?scope=campus|faculty|major|class&limit=50
     * Returns ranked leaderboard with the current user's rank injected.
     */
    public function index(Request $request): JsonResponse
    {
        $scope = in_array($request->query('scope'), ['campus', 'faculty', 'major', 'class'])
            ? $request->query('scope')
            : 'campus';

        $limit = (int) $request->query('limit', 50);

        $data = $this->leaderboardService->get(
            scope:  $scope,
            userId: $request->user()->id,
            limit:  $limit,
        );

        // Mark the authenticated user in the entries list
        $authId = $request->user()->id;
        $data['entries'] = array_map(
            fn ($e) => array_merge($e, ['is_current_user' => $e['user_id'] === $authId]),
            $data['entries']
        );

        return $this->success(data: $data, message: 'Leaderboard retrieved.');
    }
}

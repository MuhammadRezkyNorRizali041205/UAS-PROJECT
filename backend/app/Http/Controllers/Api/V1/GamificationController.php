<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\GamificationProfileResource;
use App\Http\Resources\PointHistoryResource;
use App\Http\Resources\QuestResource;
use App\Http\Resources\AchievementListResource;
use App\Services\GamificationService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GamificationController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly GamificationService $gamificationService) {}

    /**
     * GET /v1/gamification/profile
     * Full gamification snapshot: points, level, streak, recent achievements, quest summary.
     */
    public function profile(Request $request): JsonResponse
    {
        $data = $this->gamificationService->getProfile($request->user()->id);

        return $this->success(
            data: new GamificationProfileResource($data),
            message: 'Gamification profile retrieved.'
        );
    }

    /**
     * GET /v1/gamification/quests
     * Today's quests with current user progress.
     */
    public function quests(Request $request): JsonResponse
    {
        $quests = $this->gamificationService->getTodayQuests($request->user()->id);

        return $this->success(
            data: QuestResource::collection($quests),
            message: 'Daily quests retrieved.'
        );
    }

    /**
     * GET /v1/gamification/achievements
     * All achievements split into earned and locked.
     */
    public function achievements(Request $request): JsonResponse
    {
        $data = $this->gamificationService->getAchievements($request->user()->id);

        return $this->success(
            data: new AchievementListResource($data),
            message: 'Achievements retrieved.'
        );
    }

    /**
     * GET /v1/gamification/history
     * Paginated point transaction history.
     */
    public function history(Request $request): JsonResponse
    {
        $history = $this->gamificationService->getPointHistory(
            userId: $request->user()->id,
            perPage: (int) $request->query('per_page', 20),
        );

        return $this->success(
            data: PointHistoryResource::collection($history)->response()->getData(true),
            message: 'Point history retrieved.'
        );
    }
}

<?php

namespace App\Services;

use App\Models\Profile;
use App\Models\User;
use App\Models\UserPoint;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class LeaderboardService
{
    private const CACHE_TTL    = 300; // 5 minutes
    private const MAX_ENTRIES  = 100;

    // ─── Public API ───────────────────────────────────────────────────────────

    /**
     * Get leaderboard for a given scope.
     *
     * @param  string  $scope  campus|faculty|major|class
     * @param  int     $userId Authenticated user ID (to filter by their own faculty/major/class)
     * @param  int     $limit  Max entries to return
     */
    public function get(string $scope, int $userId, int $limit = 50): array
    {
        $scopeValue = $this->resolveScopeValue($scope, $userId);
        $cacheKey   = "leaderboard:{$scope}:{$scopeValue}";

        $entries = Cache::remember($cacheKey, self::CACHE_TTL, fn () =>
            $this->buildLeaderboard($scope, $scopeValue, min($limit, self::MAX_ENTRIES))
        );

        $myRank = $this->getMyRank($userId, $scope, $scopeValue);

        return [
            'entries'            => $entries,
            'my_rank'            => $myRank,
            'scope'              => $scope,
            'total_participants' => count($entries),
        ];
    }

    // ─── Internal builders ────────────────────────────────────────────────────

    private function buildLeaderboard(string $scope, string $scopeValue, int $limit): array
    {
        $query = DB::table('user_points as up')
            ->join('users as u', 'u.id', '=', 'up.user_id')
            ->leftJoin('profiles as p', 'p.user_id', '=', 'u.id')
            ->where('u.is_active', true)
            ->select(
                'up.user_id',
                'u.name',
                'p.avatar_url',
                'up.total_points',
                'up.level',
                'p.faculty',
                'p.major',
                'p.year_entry',
            )
            ->orderByDesc('up.total_points')
            ->limit($limit);

        $this->applyScope($query, $scope, $scopeValue);

        return $query->get()
            ->values()
            ->map(fn ($row, $idx) => [
                'rank'         => $idx + 1,
                'user_id'      => $row->user_id,
                'name'         => $row->name,
                'avatar_url'   => $row->avatar_url,
                'total_points' => (int) $row->total_points,
                'level'        => $row->level,
                'level_label'  => \App\Models\UserPoint::LEVEL_LABELS[$row->level] ?? 'Bronze',
            ])
            ->toArray();
    }

    private function getMyRank(int $userId, string $scope, string $scopeValue): ?array
    {
        $userPoint = UserPoint::where('user_id', $userId)->first();
        if (!$userPoint) return null;

        $countQuery = DB::table('user_points as up')
            ->join('users as u', 'u.id', '=', 'up.user_id')
            ->leftJoin('profiles as p', 'p.user_id', '=', 'u.id')
            ->where('u.is_active', true)
            ->where('up.total_points', '>', $userPoint->total_points);

        $this->applyScope($countQuery, $scope, $scopeValue);

        $rank = $countQuery->count() + 1;

        return [
            'rank'         => $rank,
            'total_points' => $userPoint->total_points,
            'level'        => $userPoint->level,
            'level_label'  => \App\Models\UserPoint::LEVEL_LABELS[$userPoint->level] ?? 'Bronze',
        ];
    }

    private function applyScope($query, string $scope, string $scopeValue): void
    {
        match ($scope) {
            'faculty' => $query->where('p.faculty', $scopeValue),
            'major'   => $query->where('p.major', $scopeValue),
            'class'   => $query->whereRaw('CONCAT(p.major, "_", p.year_entry) = ?', [$scopeValue]),
            default   => null, // campus = all users, no filter
        };
    }

    private function resolveScopeValue(string $scope, int $userId): string
    {
        if ($scope === 'campus') return 'all';

        $profile = Profile::where('user_id', $userId)->first();
        if (!$profile) return 'all';

        return match ($scope) {
            'faculty' => $profile->faculty ?? 'all',
            'major'   => $profile->major ?? 'all',
            'class'   => ($profile->major ?? '') . '_' . ($profile->year_entry ?? ''),
            default   => 'all',
        };
    }
}

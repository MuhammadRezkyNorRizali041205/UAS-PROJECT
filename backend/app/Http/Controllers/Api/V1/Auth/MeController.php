<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MeController extends Controller
{
    use ApiResponse;

    /**
     * Get authenticated user details.
     *
     * GET /api/v1/auth/me
     */
    public function __invoke(Request $request): JsonResponse
    {
        $user = $request->user()->load('profile');

        return $this->success(
            data: new UserResource($user),
            message: 'User retrieved successfully.'
        );
    }
}

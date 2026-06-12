<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Services\AuthService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LogoutController extends Controller
{
    use ApiResponse;

    public function __construct(private AuthService $authService) {}

    /**
     * Revoke current access token.
     *
     * POST /api/v1/auth/logout
     */
    public function __invoke(Request $request): JsonResponse
    {
        $this->authService->logout($request->user());

        return $this->success(message: 'Logout berhasil.');
    }
}

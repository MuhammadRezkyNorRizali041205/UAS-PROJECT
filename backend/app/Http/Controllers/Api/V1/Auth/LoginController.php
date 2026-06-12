<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Resources\UserResource;
use App\Services\AuthService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;

class LoginController extends Controller
{
    use ApiResponse;

    public function __construct(private AuthService $authService) {}

    /**
     * Authenticate user and return access token.
     *
     * POST /api/v1/auth/login
     */
    public function __invoke(LoginRequest $request): JsonResponse
    {
        try {
            $result = $this->authService->login($request->validated());

            return $this->success(
                data: [
                    'user'  => new UserResource($result['user']),
                    'token' => $result['token'],
                    'type'  => 'Bearer',
                ],
                message: 'Login berhasil.'
            );
        } catch (ValidationException $e) {
            return $this->error('Email atau password salah.', 401, $e->errors(), 'INVALID_CREDENTIALS');
        } catch (\Throwable $e) {
            return $this->error('Gagal melakukan login.', 500);
        }
    }
}

<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Services\AuthService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;

class RegisterController extends Controller
{
    use ApiResponse;

    public function __construct(private AuthService $authService) {}

    /**
     * Register a new user account.
     *
     * POST /api/v1/auth/register
     */
    public function __invoke(RegisterRequest $request): JsonResponse
    {
        try {
            $result = $this->authService->register($request->validated());

            return $this->success(
                data: [
                    'user'  => new UserResource($result['user']),
                    'token' => $result['token'],
                    'type'  => 'Bearer',
                ],
                message: 'Registrasi berhasil.',
                code: 201
            );
        } catch (ValidationException $e) {
            return $this->error($e->getMessage(), 422, $e->errors());
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::error('Register error: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return $this->error('Gagal melakukan registrasi.', 500);
        }
    }
}

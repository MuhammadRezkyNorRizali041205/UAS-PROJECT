<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Http\Requests\Auth\ResetPasswordRequest;
use App\Services\AuthService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;

class ForgotPasswordController extends Controller
{
    use ApiResponse;

    public function __construct(private AuthService $authService) {}

    /**
     * Send OTP to user email for password reset.
     *
     * POST /api/v1/auth/forgot-password
     */
    public function sendOtp(ForgotPasswordRequest $request): JsonResponse
    {
        try {
            $this->authService->forgotPassword($request->email);

            return $this->success(message: 'Kode OTP telah dikirim ke email Anda.');
        } catch (ValidationException $e) {
            return $this->error($e->getMessage(), 422, $e->errors(), 'OTP_LIMIT_EXCEEDED');
        } catch (\Throwable $e) {
            return $this->error('Gagal mengirim OTP.', 500);
        }
    }

    /**
     * Verify OTP and reset password.
     *
     * POST /api/v1/auth/reset-password
     */
    public function resetPassword(ResetPasswordRequest $request): JsonResponse
    {
        try {
            $this->authService->resetPassword($request->validated());

            return $this->success(message: 'Password berhasil direset. Silakan login.');
        } catch (ValidationException $e) {
            return $this->error($e->getMessage(), 422, $e->errors(), 'OTP_INVALID');
        } catch (\Throwable $e) {
            return $this->error('Gagal mereset password.', 500);
        }
    }
}

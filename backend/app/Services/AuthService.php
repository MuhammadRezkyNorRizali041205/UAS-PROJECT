<?php

namespace App\Services;

use App\Models\PasswordResetOtp;
use App\Models\Profile;
use App\Models\User;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\ValidationException;

class AuthService
{
    /**
     * Register a new user and create empty profile.
     */
    public function register(array $data): array
    {
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'name'     => $data['name'],
                'email'    => $data['email'],
                'password' => $data['password'],
                'role'     => $data['role'] ?? 'student',
            ]);

            Profile::create(['user_id' => $user->id]);

            $token = $user->createToken('auth_token')->plainTextToken;

            return ['user' => $user->load('profile'), 'token' => $token];
        });
    }

    /**
     * Authenticate user and return token.
     */
    public function login(array $data): array
    {
        $user = User::where('email', $data['email'])->first();

        if (!$user || !\Illuminate\Support\Facades\Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau password salah.'],
            ]);
        }

        if (!$user->is_active) {
            throw ValidationException::withMessages([
                'email' => ['Akun Anda telah dinonaktifkan.'],
            ]);
        }

        // Update FCM token if provided
        if (!empty($data['fcm_token'])) {
            $user->update(['fcm_token' => $data['fcm_token']]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return ['user' => $user->load('profile'), 'token' => $token];
    }

    /**
     * Revoke current user token.
     */
    public function logout(User $user): void
    {
        /** @var \Laravel\Sanctum\PersonalAccessToken|null $token */
        $token = $user->currentAccessToken();
        $token?->delete();
    }

    /**
     * Generate and send OTP for password reset.
     */
    public function forgotPassword(string $email): void
    {
        $lockoutMinutes = (int) config('otp.lockout_minutes', 30);
        $maxAttempts    = (int) config('otp.max_attempts', 5);

        // Check for existing unexpired OTP with max attempts (lockout)
        $existing = PasswordResetOtp::where('email', $email)
            ->where('expires_at', '>', now())
            ->whereNull('used_at')
            ->first();

        if ($existing && $existing->attempts >= $maxAttempts) {
            throw ValidationException::withMessages([
                'email' => ["Terlalu banyak percobaan. Coba lagi dalam {$lockoutMinutes} menit."],
            ]);
        }

        // Delete previous OTPs for this email
        PasswordResetOtp::where('email', $email)->delete();

        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        $otpRecord = PasswordResetOtp::create([
            'email'      => $email,
            'otp'        => $otp,
            'expires_at' => now()->addMinutes((int) config('otp.expire_minutes', 15)),
        ]);

        // Send OTP via email
        try {
            Mail::to($email)->send(new \App\Mail\OtpMail($otp));
        } catch (\Throwable $e) {
            Log::error('Failed to send OTP email', ['email' => $email, 'error' => $e->getMessage()]);
        }
    }

    /**
     * Verify OTP and reset password.
     */
    public function resetPassword(array $data): void
    {
        $otpRecord = PasswordResetOtp::where('email', $data['email'])
            ->whereNull('used_at')
            ->orderByDesc('id')
            ->first();

        if (!$otpRecord) {
            throw ValidationException::withMessages([
                'otp' => ['OTP tidak ditemukan atau sudah digunakan.'],
            ]);
        }

        if ($otpRecord->isExpired()) {
            throw ValidationException::withMessages([
                'otp' => ['OTP sudah kadaluarsa.'],
            ]);
        }

        if ($otpRecord->isMaxAttempts()) {
            throw ValidationException::withMessages([
                'otp' => ['Terlalu banyak percobaan. Minta OTP baru.'],
            ]);
        }

        if ($otpRecord->otp !== $data['otp']) {
            $otpRecord->increment('attempts');
            throw ValidationException::withMessages([
                'otp' => ['OTP tidak valid.'],
            ]);
        }

        DB::transaction(function () use ($data, $otpRecord) {
            $otpRecord->update(['used_at' => now()]);

            User::where('email', $data['email'])->update([
                'password' => $data['password'],
            ]);
        });

        event(new PasswordReset(User::where('email', $data['email'])->first()));
    }
}

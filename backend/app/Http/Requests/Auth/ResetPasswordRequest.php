<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class ResetPasswordRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email'    => ['required', 'email', 'exists:users,email'],
            'otp'      => ['required', 'string', 'digits:6'],
            'password' => ['required', 'string', 'min:8', 'regex:/^(?=.*[a-zA-Z])(?=.*\d).+$/', 'confirmed'],
        ];
    }

    public function messages(): array
    {
        return [
            'password.regex'     => 'Password harus mengandung minimal satu huruf dan satu angka.',
            'password.confirmed' => 'Konfirmasi password tidak cocok.',
        ];
    }
}

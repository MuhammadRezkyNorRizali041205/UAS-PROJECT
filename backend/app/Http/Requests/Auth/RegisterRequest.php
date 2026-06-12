<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name'     => ['required', 'string', 'max:255'],
            'email'    => ['required', 'email:rfc', 'unique:users,email', 'max:255'],
            'password' => ['required', 'string', 'min:8', 'regex:/^(?=.*[a-zA-Z])(?=.*\d).+$/'],
            'role'     => ['sometimes', 'string', 'in:student,lecturer,org_admin'],
        ];
    }

    public function messages(): array
    {
        return [
            'password.regex' => 'Password harus mengandung minimal satu huruf dan satu angka.',
        ];
    }
}

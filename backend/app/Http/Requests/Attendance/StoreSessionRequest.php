<?php
// app/Http/Requests/Attendance/StoreSessionRequest.php

namespace App\Http\Requests\Attendance;

use Illuminate\Foundation\Http\FormRequest;

class StoreSessionRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'course_name' => ['required', 'string', 'max:255'],
            'location'    => ['nullable', 'string', 'max:255'],
            'latitude'    => ['nullable', 'numeric', 'between:-90,90'],
            'longitude'   => ['nullable', 'numeric', 'between:-180,180'],
            'radius_m'    => ['nullable', 'integer', 'min:10', 'max:5000'],
            'starts_at'   => ['required', 'date'],
            'ends_at'     => ['required', 'date', 'after:starts_at'],
        ];
    }

    public function messages(): array
    {
        return [
            'course_name.required' => 'Nama mata kuliah wajib diisi.',
            'ends_at.after'        => 'Waktu selesai harus setelah waktu mulai.',
        ];
    }
}

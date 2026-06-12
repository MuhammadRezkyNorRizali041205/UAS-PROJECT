<?php
// app/Http/Requests/Task/StoreTaskRequest.php

namespace App\Http\Requests\Task;

use Illuminate\Foundation\Http\FormRequest;

class StoreTaskRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'title'       => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:5000'],
            'priority'    => ['sometimes', 'in:low,medium,high,critical'],
            'status'      => ['sometimes', 'in:pending,in_progress,completed,overdue'],
            'category_id' => ['nullable', 'exists:task_categories,id'],
            'deadline'    => ['nullable', 'date', 'after:now'],
        ];
    }

    public function messages(): array
    {
        return [
            'title.required'     => 'Judul tugas wajib diisi.',
            'title.max'          => 'Judul maksimal 255 karakter.',
            'priority.in'        => 'Prioritas tidak valid.',
            'status.in'          => 'Status tidak valid.',
            'category_id.exists' => 'Kategori tidak ditemukan.',
            'deadline.after'     => 'Deadline harus setelah waktu sekarang.',
        ];
    }
}

<?php
// app/Http/Requests/Task/UpdateTaskRequest.php

namespace App\Http\Requests\Task;

use Illuminate\Foundation\Http\FormRequest;

class UpdateTaskRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'title'       => ['sometimes', 'string', 'max:255'],
            'description' => ['sometimes', 'nullable', 'string', 'max:5000'],
            'priority'    => ['sometimes', 'in:low,medium,high,critical'],
            'status'      => ['sometimes', 'in:pending,in_progress,completed,overdue'],
            'category_id' => ['sometimes', 'nullable', 'exists:task_categories,id'],
            'deadline'    => ['sometimes', 'nullable', 'date'],
        ];
    }
}

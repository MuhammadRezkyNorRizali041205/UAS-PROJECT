<?php
// app/Http/Requests/Schedule/StoreScheduleRequest.php

namespace App\Http\Requests\Schedule;

use Illuminate\Foundation\Http\FormRequest;

class StoreScheduleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title'       => ['required', 'string', 'max:255'],
            'category'    => ['required', 'string', 'in:lecture,practicum,seminar,organization,task,exam,custom'],
            'day_of_week' => ['required', 'integer', 'between:0,6'],
            'start_time'  => ['required', 'date_format:H:i'],
            'end_time'    => ['required', 'date_format:H:i', 'after:start_time'],
            'room'        => ['nullable', 'string', 'max:100'],
            'lecturer'    => ['nullable', 'string', 'max:255'],
            'recurrence'  => ['required', 'string', 'in:once,weekly,biweekly'],
            'start_date'  => ['required', 'date'],
            'end_date'    => ['nullable', 'date', 'after_or_equal:start_date'],
            'color_tag'   => ['nullable', 'string', 'regex:/^#[0-9A-Fa-f]{6}$/'],
            'is_active'   => ['boolean'],
            'notes'       => ['nullable', 'string', 'max:1000'],
        ];
    }

    public function messages(): array
    {
        return [
            'end_time.after'             => 'Waktu selesai harus setelah waktu mulai.',
            'end_date.after_or_equal'    => 'Tanggal akhir harus setelah atau sama dengan tanggal mulai.',
            'day_of_week.between'        => 'Hari tidak valid.',
            'category.in'                => 'Kategori tidak valid.',
            'recurrence.in'              => 'Jenis pengulangan tidak valid.',
            'color_tag.regex'            => 'Format warna tidak valid (gunakan hex #RRGGBB).',
        ];
    }
}

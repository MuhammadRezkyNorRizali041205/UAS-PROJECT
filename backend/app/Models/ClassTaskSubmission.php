<?php
// app/Models/ClassTaskSubmission.php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ClassTaskSubmission extends Model
{
    use HasUuid;

    protected $fillable = [
        'class_task_id', 'student_id', 'content', 'attachment_url',
        'score', 'feedback', 'status', 'submitted_at', 'graded_at',
    ];

    protected function casts(): array
    {
        return [
            'submitted_at' => 'datetime',
            'graded_at'    => 'datetime',
            'score'        => 'integer',
        ];
    }

    public function classTask(): BelongsTo
    {
        return $this->belongsTo(ClassTask::class, 'class_task_id');
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function getLetterGradeAttribute(): string
    {
        if ($this->score === null) return '-';
        return match (true) {
            $this->score >= 85 => 'A',
            $this->score >= 70 => 'B',
            $this->score >= 55 => 'C',
            $this->score >= 40 => 'D',
            default            => 'E',
        };
    }
}

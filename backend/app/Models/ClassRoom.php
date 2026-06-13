<?php
// app/Models/ClassRoom.php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class ClassRoom extends Model
{
    use HasUuid, SoftDeletes;

    protected $table = 'classes';

    protected $fillable = [
        'name', 'course_name', 'course_code', 'lecturer_id',
        'semester', 'academic_year', 'description', 'max_students', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active'   => 'boolean',
            'semester'    => 'integer',
            'max_students'=> 'integer',
        ];
    }

    public function lecturer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'lecturer_id');
    }

    public function enrollments(): HasMany
    {
        return $this->hasMany(ClassEnrollment::class, 'class_id');
    }

    public function students(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'class_enrollments', 'class_id', 'student_id')
            ->withPivot(['enrolled_at', 'status'])
            ->withTimestamps();
    }

    public function classTasks(): HasMany
    {
        return $this->hasMany(ClassTask::class, 'class_id');
    }

    public function getStudentCountAttribute(): int
    {
        return $this->enrollments()->where('status', 'active')->count();
    }

    public function getPendingSubmissionsCountAttribute(): int
    {
        return ClassTaskSubmission::whereIn(
            'class_task_id',
            $this->classTasks()->pluck('id')
        )->where('status', 'submitted')->count();
    }
}

<?php
// app/Models/ClassTask.php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class ClassTask extends Model
{
    use HasUuid, SoftDeletes;

    protected $fillable = [
        'class_id', 'created_by', 'title', 'description',
        'deadline', 'max_score', 'attachment_url',
    ];

    protected function casts(): array
    {
        return [
            'deadline'  => 'datetime',
            'max_score' => 'integer',
        ];
    }

    public function classRoom(): BelongsTo
    {
        return $this->belongsTo(ClassRoom::class, 'class_id');
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function submissions(): HasMany
    {
        return $this->hasMany(ClassTaskSubmission::class, 'class_task_id');
    }

    public function getSubmittedCountAttribute(): int
    {
        return $this->submissions()->whereIn('status', ['submitted', 'graded', 'late'])->count();
    }

    public function getGradedCountAttribute(): int
    {
        return $this->submissions()->where('status', 'graded')->count();
    }
}

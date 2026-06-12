<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Builder;

class Task extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'user_id', 'category_id', 'title', 'description',
        'priority', 'status', 'deadline', 'completed_at', 'reminder_sent',
    ];

    protected function casts(): array
    {
        return [
            'deadline'      => 'datetime',
            'completed_at'  => 'datetime',
            'reminder_sent' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(TaskCategory::class);
    }

    public function labels(): BelongsToMany
    {
        return $this->belongsToMany(TaskLabel::class, 'task_label_pivot', 'task_id', 'label_id');
    }

    public function scopeUpcoming(Builder $query): Builder
    {
        return $query->whereNotIn('status', ['completed', 'overdue'])
            ->whereBetween('deadline', [now(), now()->addDays(7)])
            ->orderBy('deadline');
    }

    public function scopeOverdue(Builder $query): Builder
    {
        return $query->where('status', 'overdue')
            ->orderBy('deadline', 'desc');
    }

    public function scopeForUser(Builder $query, int $userId): Builder
    {
        return $query->where('user_id', $userId);
    }

    public function isOverdue(): bool
    {
        return $this->deadline && $this->deadline->isPast()
            && !in_array($this->status, ['completed']);
    }

    public function getCountdownAttribute(): string
    {
        if (!$this->deadline) return '';

        $now = now();
        $deadline = $this->deadline;

        if ($deadline->isPast()) {
            $diff = $now->diff($deadline);
            return "Terlambat {$diff->h} jam 🔴";
        }

        $diffInMinutes = $now->diffInMinutes($deadline);

        if ($diffInMinutes <= 60) {
            return "{$diffInMinutes} menit lagi ⚠️";
        }

        if ($deadline->isToday()) {
            return "Hari ini jam " . $deadline->format('H:i');
        }

        if ($deadline->isTomorrow()) {
            return "Besok jam " . $deadline->format('H:i');
        }

        $days  = $now->diffInDays($deadline);
        $hours = $now->copy()->addDays($days)->diffInHours($deadline);
        return "{$days} hari {$hours} jam lagi";
    }
}

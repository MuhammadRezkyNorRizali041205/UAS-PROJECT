<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Builder;

class Schedule extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'user_id', 'title', 'category', 'day_of_week',
        'start_time', 'end_time', 'room', 'lecturer',
        'recurrence', 'start_date', 'end_date', 'color_tag', 'is_active', 'notes',
    ];

    protected function casts(): array
    {
        return [
            'day_of_week' => 'integer',
            'start_date'  => 'date',
            'end_date'    => 'date',
            'is_active'   => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function scopeToday(Builder $query): Builder
    {
        $today = now()->dayOfWeek; // Carbon: 0=Sun
        return $query->where('day_of_week', $today)
            ->where('is_active', true)
            ->where('start_date', '<=', today())
            ->where(function ($q) {
                $q->whereNull('end_date')->orWhere('end_date', '>=', today());
            })
            ->orderBy('start_time');
    }

    public function scopeThisWeek(Builder $query): Builder
    {
        $days = [];
        for ($i = 0; $i < 7; $i++) {
            $days[] = now()->addDays($i)->dayOfWeek;
        }
        return $query->whereIn('day_of_week', array_unique($days))
            ->where('is_active', true)
            ->where('start_date', '<=', now()->addDays(7))
            ->where(function ($q) {
                $q->whereNull('end_date')->orWhere('end_date', '>=', today());
            });
    }
}

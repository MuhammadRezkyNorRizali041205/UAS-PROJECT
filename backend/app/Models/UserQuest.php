<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserQuest extends Model
{
    public $timestamps = false; // Using manual created_at / updated_at in migration

    protected $fillable = [
        'user_id',
        'quest_id',
        'quest_date',
        'progress',
        'is_completed',
        'completed_at',
    ];

    protected $casts = [
        'quest_date'   => 'date',
        'progress'     => 'integer',
        'is_completed' => 'boolean',
        'completed_at' => 'datetime',
        'created_at'   => 'datetime',
        'updated_at'   => 'datetime',
    ];

    // ─── Relationships ────────────────────────────────────────────────────────

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function quest(): BelongsTo
    {
        return $this->belongsTo(DailyQuest::class, 'quest_id');
    }
}

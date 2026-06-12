<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PointHistory extends Model
{
    public $timestamps = false; // Only has created_at (immutable history)

    protected $fillable = [
        'user_id',
        'points',
        'type',
        'activity_type',
        'description',
        'meta',
    ];

    protected $casts = [
        'points'     => 'integer',
        'meta'       => 'array',
        'created_at' => 'datetime',
    ];

    // ─── Activity type labels ─────────────────────────────────────────────────

    public const ACTIVITY_LABELS = [
        'login'               => 'Login Harian',
        'view_schedule'       => 'Lihat Jadwal',
        'read_announcement'   => 'Baca Pengumuman',
        'complete_task'       => 'Selesaikan Tugas',
        'attend_class'        => 'Hadir Kelas',
        'checklist_item'      => 'Checklist Kegiatan',
        'quest_complete'      => 'Quest Selesai',
        'achievement'         => 'Achievement Baru',
    ];

    public function getActivityLabelAttribute(): string
    {
        return self::ACTIVITY_LABELS[$this->activity_type] ?? $this->activity_type;
    }

    // ─── Relationships ────────────────────────────────────────────────────────

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

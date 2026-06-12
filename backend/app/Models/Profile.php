<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Profile extends Model
{
    protected $fillable = [
        'user_id', 'avatar_url', 'bio', 'phone',
        'faculty', 'major', 'student_id', 'year_entry', 'notification_prefs',
    ];

    protected function casts(): array
    {
        return [
            'notification_prefs' => 'array',
            'year_entry' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function getAvatarUrlAttribute($value): ?string
    {
        if (!$value) return null;
        if (str_starts_with($value, 'http')) return $value;
        return asset('storage/' . $value);
    }

    public function isNotificationEnabled(string $category): bool
    {
        return $this->notification_prefs[$category] ?? true;
    }
}

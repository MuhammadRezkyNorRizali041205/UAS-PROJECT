<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    protected $fillable = [
        'name', 'email', 'password', 'role', 'fcm_token', 'is_active',
    ];

    protected $hidden = [
        'password', 'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_active' => 'boolean',
        ];
    }

    public function profile(): HasOne
    {
        return $this->hasOne(Profile::class);
    }

    public function schedules(): HasMany
    {
        return $this->hasMany(Schedule::class);
    }

    public function tasks(): HasMany
    {
        return $this->hasMany(Task::class);
    }

    public function taskCategories(): HasMany
    {
        return $this->hasMany(TaskCategory::class);
    }

    public function taskLabels(): HasMany
    {
        return $this->hasMany(TaskLabel::class);
    }

    public function attendanceLogs(): HasMany
    {
        return $this->hasMany(AttendanceLog::class);
    }

    public function attendanceSessions(): HasMany
    {
        return $this->hasMany(AttendanceSession::class, 'creator_id');
    }

    public function announcements(): HasMany
    {
        return $this->hasMany(Announcement::class, 'author_id');
    }

    public function notificationLogs(): HasMany
    {
        return $this->hasMany(NotificationLog::class);
    }

    public function activities(): HasMany
    {
        return $this->hasMany(UserActivity::class);
    }

    public function bookmarkedAnnouncements()
    {
        return $this->belongsToMany(Announcement::class, 'announcement_bookmarks')
            ->withPivot('created_at');
    }

    public function isAdmin(): bool
    {
        return in_array($this->role, ['admin', 'org_admin']);
    }

    public function isLecturer(): bool
    {
        return $this->role === 'lecturer';
    }

    // ─── Chat relationships ────────────────────────────────────────────────────

    public function conversations(): BelongsToMany
    {
        return $this->belongsToMany(Conversation::class, 'conversation_participants')
            ->withPivot(['joined_at', 'last_read_at', 'is_admin'])
            ->withTimestamps()
            ->orderByPivot('joined_at', 'desc');
    }

    public function friends(): BelongsToMany
    {
        return $this->belongsToMany(
            User::class,
            'friendships',
            'requester_id',
            'addressee_id'
        )->wherePivot('status', 'accepted')
         ->union(
             $this->belongsToMany(
                 User::class,
                 'friendships',
                 'addressee_id',
                 'requester_id'
             )->wherePivot('status', 'accepted')
         );
    }
}

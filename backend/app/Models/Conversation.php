<?php
// app/Models/Conversation.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class Conversation extends Model
{
    public $incrementing = false;
    protected $keyType   = 'string';

    protected $fillable = [
        'id', 'type', 'name', 'avatar', 'created_by', 'last_message_at',
    ];

    protected function casts(): array
    {
        return [
            'last_message_at' => 'datetime',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (Conversation $conv) {
            if (empty($conv->id)) {
                $conv->id = (string) Str::uuid();
            }
        });
    }

    // ─── Relationships ────────────────────────────────────────────────────────

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function participants(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'conversation_participants')
            ->withPivot(['joined_at', 'last_read_at', 'is_admin'])
            ->withTimestamps();
    }

    public function messages(): HasMany
    {
        return $this->hasMany(Message::class);
    }

    // ─── Computed attributes ──────────────────────────────────────────────────

    public function getUnreadCountAttribute(): int
    {
        $userId   = auth()->id();
        $pivot    = $this->participants()->where('users.id', $userId)->first()?->pivot;
        $lastRead = $pivot?->last_read_at;

        $query = $this->messages()->where('sender_id', '!=', $userId);
        if ($lastRead) {
            $query->where('created_at', '>', $lastRead);
        }

        return $query->count();
    }

    public function getLastMessageAttribute(): ?array
    {
        $msg = $this->messages()->with('sender')->latest()->first();
        if (!$msg) return null;

        return [
            'id'         => $msg->id,
            'content'    => $msg->type === 'achievement'
                ? '🏆 Membagikan pencapaian'
                : ($msg->type === 'image' ? '📷 Gambar' : $msg->content),
            'type'       => $msg->type,
            'sender'     => ['id' => $msg->sender_id, 'name' => $msg->sender?->name],
            'created_at' => $msg->created_at?->toIso8601String(),
        ];
    }

    public function getOtherParticipantAttribute(): ?array
    {
        if ($this->type !== 'direct') return null;
        $userId = auth()->id();
        $other  = $this->participants()->where('users.id', '!=', $userId)->first();
        if (!$other) return null;

        return [
            'id'         => $other->id,
            'name'       => $other->name,
            'avatar_url' => $other->profile?->avatar_url,
        ];
    }
}

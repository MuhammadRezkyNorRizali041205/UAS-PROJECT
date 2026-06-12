<?php
// app/Models/Message.php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Message extends Model
{
    use HasUuid, SoftDeletes;

    protected $fillable = [
        'conversation_id', 'sender_id', 'content',
        'type', 'attachment_url', 'achievement_data', 'is_read', 'read_at',
    ];

    protected function casts(): array
    {
        return [
            'achievement_data' => 'array',
            'is_read'          => 'boolean',
            'read_at'          => 'datetime',
        ];
    }

    public function conversation(): BelongsTo
    {
        return $this->belongsTo(Conversation::class);
    }

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }
}

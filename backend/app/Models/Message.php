<?php
// app/Models/Message.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Message extends Model
{
    use SoftDeletes;

    public $incrementing = false;
    protected $keyType   = 'string';

    protected $fillable = [
        'id', 'conversation_id', 'sender_id', 'content',
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

    protected static function booted(): void
    {
        static::creating(function (Message $msg) {
            if (empty($msg->id)) {
                $msg->id = (string) Str::uuid();
            }
        });
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

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class NotificationLog extends Model
{
    public $timestamps = false;
    const CREATED_AT = 'sent_at';
    const UPDATED_AT = null;

    protected $fillable = [
        'user_id', 'type', 'title', 'body',
        'data', 'sent_at', 'read_at', 'fcm_message_id',
    ];

    protected function casts(): array
    {
        return [
            'data'    => 'array',
            'sent_at' => 'datetime',
            'read_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

<?php
// app/Models/ConversationParticipant.php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Relations\Pivot;

class ConversationParticipant extends Pivot
{
    use HasUuid;

    protected $table = 'conversation_participants';

    public $incrementing = false;
    protected $keyType   = 'string';

    protected $fillable = [
        'id', 'conversation_id', 'user_id',
        'joined_at', 'last_read_at', 'is_admin',
    ];

    protected function casts(): array
    {
        return [
            'joined_at'    => 'datetime',
            'last_read_at' => 'datetime',
            'is_admin'     => 'boolean',
        ];
    }
}

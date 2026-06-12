<?php
// routes/channels.php

use App\Models\User;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

// Private channel for conversation — only participants may subscribe
Broadcast::channel('conversation.{conversationId}', function (User $user, string $conversationId) {
    return $user->conversations()
        ->where('conversations.id', $conversationId)
        ->exists();
});

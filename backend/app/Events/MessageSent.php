<?php
// app/Events/MessageSent.php

namespace App\Events;

use App\Models\Message;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MessageSent implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public readonly Message $message) {}

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('conversation.' . $this->message->conversation_id),
        ];
    }

    public function broadcastAs(): string
    {
        return 'message.sent';
    }

    public function broadcastWith(): array
    {
        $msg    = $this->message;
        $sender = $msg->sender;

        return [
            'id'               => $msg->id,
            'conversation_id'  => $msg->conversation_id,
            'content'          => $msg->content,
            'type'             => $msg->type,
            'attachment_url'   => $msg->attachment_url,
            'achievement_data' => $msg->achievement_data,
            'sender'           => [
                'id'         => $sender?->id,
                'name'       => $sender?->name,
                'avatar_url' => $sender?->profile?->avatar_url,
            ],
            'created_at'       => $msg->created_at?->toIso8601String(),
        ];
    }
}

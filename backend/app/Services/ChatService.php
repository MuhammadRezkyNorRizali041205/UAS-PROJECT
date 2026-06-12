<?php
// app/Services/ChatService.php

namespace App\Services;

use App\Events\MessageSent;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\User;
use Illuminate\Pagination\CursorPaginator;
use Illuminate\Support\Collection;
use Illuminate\Support\Str;

class ChatService
{
    public function getConversations(User $user): Collection
    {
        return $user->conversations()
            ->with(['participants:id,name,email', 'messages' => function ($q) {
                $q->latest()->limit(1);
            }])
            ->get()
            ->map(function (Conversation $conv) use ($user) {
                $lastMsg = $conv->messages->first();
                $other   = $conv->type === 'direct'
                    ? $conv->participants->firstWhere('id', '!=', $user->id)
                    : null;

                $pivot        = $conv->participants->firstWhere('id', $user->id)?->pivot;
                $lastReadAt   = $pivot?->last_read_at;
                $unreadCount  = $lastReadAt
                    ? $conv->messages()
                        ->where('sender_id', '!=', $user->id)
                        ->where('created_at', '>', $lastReadAt)
                        ->count()
                    : $conv->messages()
                        ->where('sender_id', '!=', $user->id)
                        ->count();

                return [
                    'id'              => $conv->id,
                    'type'            => $conv->type,
                    'name'            => $conv->type === 'direct' ? $other?->name : $conv->name,
                    'avatar'          => $conv->avatar,
                    'last_message'    => $lastMsg ? [
                        'id'         => $lastMsg->id,
                        'content'    => $lastMsg->type === 'achievement' ? '🏆 Achievement shared' : $lastMsg->content,
                        'type'       => $lastMsg->type,
                        'sender_id'  => $lastMsg->sender_id,
                        'created_at' => $lastMsg->created_at,
                    ] : null,
                    'unread_count'    => $unreadCount,
                    'last_message_at' => $conv->last_message_at,
                    'participants'    => $conv->participants->map(fn($p) => [
                        'id'       => $p->id,
                        'name'     => $p->name,
                        'is_admin' => (bool) $p->pivot->is_admin,
                    ]),
                ];
            })
            ->sortByDesc('last_message_at')
            ->values();
    }

    public function getOrCreateDirectConversation(User $requester, int $targetId): Conversation
    {
        $target = User::findOrFail($targetId);

        // Look for an existing direct conversation shared by both
        $existing = Conversation::where('type', 'direct')
            ->whereHas('participants', fn($q) => $q->where('user_id', $requester->id))
            ->whereHas('participants', fn($q) => $q->where('user_id', $target->id))
            ->first();

        if ($existing) {
            return $existing;
        }

        $conv = Conversation::create([
            'id'         => Str::uuid(),
            'type'       => 'direct',
            'created_by' => $requester->id,
        ]);

        $conv->participants()->attach([
            $requester->id => ['joined_at' => now(), 'is_admin' => false],
            $target->id    => ['joined_at' => now(), 'is_admin' => false],
        ]);

        return $conv;
    }

    public function createGroupConversation(User $creator, string $name, array $memberIds): Conversation
    {
        $conv = Conversation::create([
            'id'         => Str::uuid(),
            'type'       => 'group',
            'name'       => $name,
            'created_by' => $creator->id,
        ]);

        $attach = [];
        foreach (array_unique(array_merge([$creator->id], $memberIds)) as $uid) {
            $attach[$uid] = [
                'joined_at' => now(),
                'is_admin'  => ($uid === $creator->id),
            ];
        }
        $conv->participants()->attach($attach);

        return $conv;
    }

    public function getMessages(User $user, string $conversationId, ?string $cursor, int $perPage = 30): CursorPaginator
    {
        $conv = Conversation::findOrFail($conversationId);

        abort_unless(
            $conv->participants()->where('user_id', $user->id)->exists(),
            403,
            'Not a participant'
        );

        return $conv->messages()
            ->with('sender:id,name')
            ->orderByDesc('created_at')
            ->cursorPaginate($perPage, ['*'], 'cursor', $cursor);
    }

    public function sendMessage(User $sender, string $conversationId, string $content, string $type = 'text', ?array $achievementData = null): Message
    {
        $conv = Conversation::findOrFail($conversationId);

        abort_unless(
            $conv->participants()->where('user_id', $sender->id)->exists(),
            403,
            'Not a participant'
        );

        $message = Message::create([
            'id'               => Str::uuid(),
            'conversation_id'  => $conv->id,
            'sender_id'        => $sender->id,
            'content'          => $content,
            'type'             => $type,
            'achievement_data' => $achievementData,
        ]);

        $conv->update(['last_message_at' => now()]);

        $message->load('sender:id,name');

        broadcast(new MessageSent($message))->toOthers();

        return $message;
    }

    public function shareAchievementToChat(User $sender, string $conversationId, array $achievement): Message
    {
        return $this->sendMessage(
            $sender,
            $conversationId,
            '🏆 ' . $achievement['title'],
            'achievement',
            $achievement
        );
    }

    public function markAsRead(User $user, string $conversationId): void
    {
        $conv = Conversation::findOrFail($conversationId);

        $conv->participants()->updateExistingPivot($user->id, [
            'last_read_at' => now(),
        ]);
    }

    public function searchUsers(User $me, string $query): Collection
    {
        return User::where('id', '!=', $me->id)
            ->where(function ($q) use ($query) {
                $q->where('name', 'like', "%{$query}%")
                  ->orWhere('email', 'like', "%{$query}%");
            })
            ->select('id', 'name', 'email')
            ->limit(20)
            ->get();
    }
}

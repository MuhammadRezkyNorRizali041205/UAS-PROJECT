<?php
// app/Http/Controllers/Api/V1/ChatController.php

namespace App\Http\Controllers\Api\V1;

use App\Events\UserTyping;
use App\Http\Controllers\Controller;
use App\Services\ChatService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChatController extends Controller
{
    public function __construct(private readonly ChatService $chat) {}

    // GET /api/v1/chat/conversations
    public function conversations(Request $request): JsonResponse
    {
        $list = $this->chat->getConversations($request->user());
        return response()->json(['data' => $list]);
    }

    // POST /api/v1/chat/conversations/direct
    public function createDirect(Request $request): JsonResponse
    {
        $request->validate(['user_id' => 'required|integer|exists:users,id']);

        $conv = $this->chat->getOrCreateDirectConversation(
            $request->user(),
            $request->integer('user_id')
        );

        return response()->json(['data' => ['id' => $conv->id, 'type' => $conv->type]], 201);
    }

    // POST /api/v1/chat/conversations/group
    public function createGroup(Request $request): JsonResponse
    {
        $request->validate([
            'name'       => 'required|string|max:100',
            'member_ids' => 'required|array|min:1',
            'member_ids.*' => 'integer|exists:users,id',
        ]);

        $conv = $this->chat->createGroupConversation(
            $request->user(),
            $request->string('name'),
            $request->array('member_ids')
        );

        return response()->json(['data' => ['id' => $conv->id, 'type' => $conv->type, 'name' => $conv->name]], 201);
    }

    // GET /api/v1/chat/conversations/{id}/messages
    public function messages(Request $request, string $id): JsonResponse
    {
        $paginator = $this->chat->getMessages(
            $request->user(),
            $id,
            $request->string('cursor')->value() ?: null,
            30
        );

        return response()->json([
            'data'        => $paginator->items(),
            'next_cursor' => $paginator->nextCursor()?->encode(),
            'has_more'    => $paginator->hasMorePages(),
        ]);
    }

    // POST /api/v1/chat/conversations/{id}/messages
    public function sendMessage(Request $request, string $id): JsonResponse
    {
        $request->validate([
            'content' => 'required|string|max:4000',
            'type'    => 'sometimes|in:text,image',
        ]);

        $message = $this->chat->sendMessage(
            $request->user(),
            $id,
            $request->string('content'),
            $request->string('type', 'text')
        );

        return response()->json(['data' => $message], 201);
    }

    // POST /api/v1/chat/conversations/{id}/share-achievement
    public function shareAchievement(Request $request, string $id): JsonResponse
    {
        $request->validate([
            'title'       => 'required|string',
            'description' => 'sometimes|string',
            'type'        => 'required|in:task_completed,streak_milestone,badge_earned,level_up',
            'points'      => 'sometimes|integer',
            'icon'        => 'sometimes|string',
        ]);

        $message = $this->chat->shareAchievementToChat(
            $request->user(),
            $id,
            $request->only(['title', 'description', 'type', 'points', 'icon'])
        );

        return response()->json(['data' => $message], 201);
    }

    // POST /api/v1/chat/conversations/{id}/read
    public function markRead(Request $request, string $id): JsonResponse
    {
        $this->chat->markAsRead($request->user(), $id);
        return response()->json(['message' => 'Marked as read']);
    }

    // POST /api/v1/chat/conversations/{id}/typing
    public function typing(Request $request, string $id): JsonResponse
    {
        $request->validate(['is_typing' => 'required|boolean']);

        broadcast(new UserTyping($request->user(), $id, $request->boolean('is_typing')))->toOthers();

        return response()->json(['message' => 'ok']);
    }

    // GET /api/v1/chat/users/search?q=
    public function searchUsers(Request $request): JsonResponse
    {
        $request->validate(['q' => 'required|string|min:2']);

        $users = $this->chat->searchUsers($request->user(), $request->string('q'));

        return response()->json(['data' => $users]);
    }
}

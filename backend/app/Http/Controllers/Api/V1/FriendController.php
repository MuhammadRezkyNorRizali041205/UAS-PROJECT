<?php
// app/Http/Controllers/Api/V1/FriendController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Friendship;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class FriendController extends Controller
{
    // GET /api/v1/friends
    public function index(Request $request): JsonResponse
    {
        $me = $request->user();

        $friends = Friendship::where('status', 'accepted')
            ->where(fn($q) => $q->where('requester_id', $me->id)->orWhere('addressee_id', $me->id))
            ->with(['requester:id,name,email', 'addressee:id,name,email'])
            ->get()
            ->map(function (Friendship $f) use ($me) {
                $friend = $f->requester_id === $me->id ? $f->addressee : $f->requester;
                return ['id' => $friend->id, 'name' => $friend->name, 'email' => $friend->email];
            });

        return response()->json(['data' => $friends]);
    }

    // GET /api/v1/friends/requests
    public function requests(Request $request): JsonResponse
    {
        $pending = Friendship::where('addressee_id', $request->user()->id)
            ->where('status', 'pending')
            ->with('requester:id,name,email')
            ->get()
            ->map(fn($f) => [
                'friendship_id' => $f->id,
                'from'          => ['id' => $f->requester->id, 'name' => $f->requester->name, 'email' => $f->requester->email],
                'sent_at'       => $f->created_at,
            ]);

        return response()->json(['data' => $pending]);
    }

    // POST /api/v1/friends/request
    public function sendRequest(Request $request): JsonResponse
    {
        $request->validate(['user_id' => 'required|integer|exists:users,id']);

        $me       = $request->user();
        $targetId = $request->integer('user_id');

        abort_if($me->id === $targetId, 422, 'Cannot add yourself');

        $exists = Friendship::where(function ($q) use ($me, $targetId) {
            $q->where('requester_id', $me->id)->where('addressee_id', $targetId);
        })->orWhere(function ($q) use ($me, $targetId) {
            $q->where('requester_id', $targetId)->where('addressee_id', $me->id);
        })->exists();

        abort_if($exists, 422, 'Friendship already exists or pending');

        Friendship::create([
            'id'           => Str::uuid(),
            'requester_id' => $me->id,
            'addressee_id' => $targetId,
            'status'       => 'pending',
        ]);

        return response()->json(['message' => 'Friend request sent'], 201);
    }

    // POST /api/v1/friends/{id}/accept
    public function accept(Request $request, string $id): JsonResponse
    {
        $friendship = Friendship::where('id', $id)
            ->where('addressee_id', $request->user()->id)
            ->where('status', 'pending')
            ->firstOrFail();

        $friendship->update(['status' => 'accepted']);

        return response()->json(['message' => 'Friend request accepted']);
    }

    // DELETE /api/v1/friends/{id}
    public function destroy(Request $request, string $id): JsonResponse
    {
        $me = $request->user();

        $friendship = Friendship::where('id', $id)
            ->where(fn($q) => $q->where('requester_id', $me->id)->orWhere('addressee_id', $me->id))
            ->firstOrFail();

        $friendship->delete();

        return response()->json(['message' => 'Removed']);
    }
}

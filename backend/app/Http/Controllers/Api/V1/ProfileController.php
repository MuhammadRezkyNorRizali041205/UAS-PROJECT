<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Profile\UpdateAvatarRequest;
use App\Http\Requests\Profile\UpdateProfileRequest;
use App\Http\Resources\ProfileResource;
use App\Services\ProfileService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function __construct(private readonly ProfileService $service) {}

    public function show(Request $request): JsonResponse
    {
        $data = $this->service->getProfile($request->user());

        return $this->success(new ProfileResource($data), 'Berhasil mengambil profil.');
    }

    public function update(UpdateProfileRequest $request): JsonResponse
    {
        $this->service->updateProfile($request->user(), $request->validated());
        $data = $this->service->getProfile($request->user()->fresh('profile'));

        return $this->success(new ProfileResource($data), 'Profil berhasil diperbarui.');
    }

    public function updateAvatar(UpdateAvatarRequest $request): JsonResponse
    {
        $avatarUrl = $this->service->updateAvatar(
            $request->user(),
            $request->file('avatar'),
        );

        return $this->success([
            'avatar_url' => $avatarUrl,
        ], 'Avatar berhasil diperbarui.');
    }

    public function updateNotifications(Request $request): JsonResponse
    {
        $data = $request->validate([
            'schedule' => ['required', 'boolean'],
            'task' => ['required', 'boolean'],
            'announcement' => ['required', 'boolean'],
            'attendance' => ['required', 'boolean'],
        ]);

        $this->service->updateNotificationPrefs($request->user(), $data);

        return $this->success([
            'notification_prefs' => $request->user()->fresh('profile')->profile?->notification_prefs,
        ], 'Preferensi notifikasi berhasil diperbarui.');
    }
}

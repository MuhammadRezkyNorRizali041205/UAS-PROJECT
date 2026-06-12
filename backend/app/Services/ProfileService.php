<?php

namespace App\Services;

use App\Models\Profile;
use App\Models\Schedule;
use App\Models\Task;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Drivers\Gd\Driver;
use Intervention\Image\ImageManager;

class ProfileService
{
    public function getProfile(User $user): array
    {
        $user->loadMissing('profile');

        $profile = $user->profile;
        $stats = $this->calculateStats($user);

        return [
            'id' => (string) $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'avatar_url' => $profile?->avatar_url,
            'profile' => [
                'nim' => $profile?->student_id,
                'faculty' => $profile?->faculty,
                'major' => $profile?->major,
                'semester' => $profile?->year_entry,
                'phone' => $profile?->phone,
                'bio' => $profile?->bio,
            ],
            'stats' => $stats,
            'notification_prefs' => $this->notificationPrefs($profile),
        ];
    }

    public function updateProfile(User $user, array $data): User
    {
        $profile = $user->profile()->firstOrCreate([
            'user_id' => $user->id,
        ]);

        $user->update([
            'name' => $data['name'],
        ]);

        $profile->update([
            'student_id' => $data['nim'] ?? null,
            'faculty' => $data['faculty'] ?? null,
            'major' => $data['major'] ?? null,
            'year_entry' => $data['semester'] ?? null,
            'phone' => $data['phone'] ?? null,
            'bio' => $data['bio'] ?? null,
        ]);

        return $user->fresh('profile');
    }

    public function updateAvatar(User $user, UploadedFile $file): string
    {
        $profile = $user->profile()->firstOrCreate([
            'user_id' => $user->id,
        ]);

        $oldPath = $profile->getRawOriginal('avatar_url');
        if ($oldPath) {
            Storage::disk('public')->delete($oldPath);
        }

        $manager = new ImageManager(new Driver());
        $image = $manager->read($file->getRealPath())->cover(400, 400);

        $filename = sprintf('avatar_%s_%s.jpg', $user->id, time());
        $path = 'avatars/' . $filename;

        Storage::disk('public')->put($path, (string) $image->toJpeg(85));

        $profile->update([
            'avatar_url' => $path,
        ]);

        return $profile->fresh()->avatar_url;
    }

    public function updateNotificationPrefs(User $user, array $prefs): void
    {
        $profile = $user->profile()->firstOrCreate([
            'user_id' => $user->id,
        ]);

        $profile->update([
            'notification_prefs' => [
                'schedule' => (bool) ($prefs['schedule'] ?? true),
                'task' => (bool) ($prefs['task'] ?? true),
                'announcement' => (bool) ($prefs['announcement'] ?? true),
                'attendance' => (bool) ($prefs['attendance'] ?? true),
            ],
        ]);
    }

    private function calculateStats(User $user): array
    {
        $totalSchedules = Schedule::where('user_id', $user->id)->count();
        $totalTasks = Task::where('user_id', $user->id)->count();
        $completedTasks = Task::where('user_id', $user->id)
            ->where('status', 'completed')
            ->count();

        $completionRate = $totalTasks > 0
            ? round(($completedTasks / $totalTasks) * 100, 1)
            : 0.0;

        return [
            'total_schedules' => $totalSchedules,
            'total_tasks' => $totalTasks,
            'completed_tasks' => $completedTasks,
            'completion_rate' => $completionRate,
            'streak' => $this->calculateStreak($user),
        ];
    }

    private function calculateStreak(User $user): int
    {
        $days = Task::where('user_id', $user->id)
            ->whereNotNull('completed_at')
            ->orderByDesc('completed_at')
            ->pluck('completed_at')
            ->map(fn ($dt) => $dt->toDateString())
            ->unique()
            ->values();

        if ($days->isEmpty()) {
            return 0;
        }

        $today = now()->toDateString();
        $yesterday = now()->subDay()->toDateString();
        $head = $days->first();

        if ($head !== $today && $head !== $yesterday) {
            return 0;
        }

        $streak = 0;
        $cursor = $head;
        foreach ($days as $day) {
            if ($day !== $cursor) {
                break;
            }

            $streak++;
            $cursor = now()->parse($cursor)->subDay()->toDateString();
        }

        return $streak;
    }

    private function notificationPrefs(?Profile $profile): array
    {
        $defaults = [
            'schedule' => true,
            'task' => true,
            'announcement' => true,
            'attendance' => true,
        ];

        if (!$profile || !is_array($profile->notification_prefs)) {
            return $defaults;
        }

        return array_merge($defaults, $profile->notification_prefs);
    }
}

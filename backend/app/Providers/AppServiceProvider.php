<?php

namespace App\Providers;

use App\Models\KelasMataKuliah;
use App\Models\UserActivity;
use App\Observers\KelasMataKuliahObserver;
use App\Observers\UserActivityObserver;
use App\Repositories\Contracts\AttendanceRepositoryInterface;
use App\Repositories\Contracts\ScheduleRepositoryInterface;
use App\Repositories\Contracts\TaskRepositoryInterface;
use App\Repositories\Eloquent\AttendanceRepository;
use App\Repositories\Eloquent\ScheduleRepository;
use App\Repositories\Eloquent\TaskRepository;
use App\Services\AttendanceService;
use App\Services\GamificationService;
use App\Services\LeaderboardService;
use App\Services\ScheduleService;
use App\Services\TaskService;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(ScheduleRepositoryInterface::class, ScheduleRepository::class);
        $this->app->bind(ScheduleService::class, fn ($app) =>
            new ScheduleService($app->make(ScheduleRepositoryInterface::class))
        );

        $this->app->bind(TaskRepositoryInterface::class, TaskRepository::class);
        $this->app->bind(TaskService::class, fn ($app) =>
            new TaskService($app->make(TaskRepositoryInterface::class))
        );

        $this->app->bind(AttendanceRepositoryInterface::class, AttendanceRepository::class);
        $this->app->bind(AttendanceService::class, fn ($app) =>
            new AttendanceService($app->make(AttendanceRepositoryInterface::class))
        );
    }

    public function boot(): void
    {
        $this->configureRateLimiting();
        $this->registerGamification();
    }

    private function registerGamification(): void
    {
        UserActivity::observe(UserActivityObserver::class);
        KelasMataKuliah::observe(KelasMataKuliahObserver::class);

        \Illuminate\Support\Facades\Event::listen(
            \App\Events\GamificationLevelUp::class,
            [\App\Listeners\SendGamificationNotification::class, 'handleLevelUp'],
        );
        \Illuminate\Support\Facades\Event::listen(
            \App\Events\AchievementUnlocked::class,
            [\App\Listeners\SendGamificationNotification::class, 'handleAchievement'],
        );
        \Illuminate\Support\Facades\Event::listen(
            \App\Events\QuestCompleted::class,
            [\App\Listeners\SendGamificationNotification::class, 'handleQuestCompleted'],
        );
    }

    /**
     * Configure rate limiters for auth and general API.
     */
    private function configureRateLimiting(): void
    {
        // Auth endpoints: 5 req/min per IP (strict)
        RateLimiter::for('auth', function (Request $request) {
            return Limit::perMinute((int) env('RATE_LIMIT_AUTH', 60))
                ->by($request->ip())
                ->response(fn () => response()->json([
                    'success' => false,
                    'message' => 'Terlalu banyak permintaan. Coba lagi nanti.',
                    'code'    => 'RATE_LIMIT_EXCEEDED',
                ], 429));
        });

        // General API: 300 req/min per user or IP
        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute((int) env('RATE_LIMIT_API', 300))
                ->by(optional($request->user())->id ?: $request->ip());
        });
    }
}

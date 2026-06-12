<?php

use App\Http\Controllers\Api\V1\Auth\ForgotPasswordController;
use App\Http\Controllers\Api\V1\Auth\LoginController;
use App\Http\Controllers\Api\V1\Auth\LogoutController;
use App\Http\Controllers\Api\V1\Auth\MeController;
use App\Http\Controllers\Api\V1\Auth\RegisterController;
use App\Http\Controllers\Api\V1\AnalyticsController;
use App\Http\Controllers\Api\V1\AttendanceController;
use App\Http\Controllers\Api\V1\ProfileController;
use App\Http\Controllers\Api\V1\ScheduleController;
use App\Http\Controllers\Api\V1\TaskController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes - v1
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {

    // Auth (public)
    Route::prefix('auth')->group(function () {
        Route::post('register',        RegisterController::class)
            ->middleware('throttle:auth');
        Route::post('login',           LoginController::class)
            ->middleware('throttle:auth');
        Route::post('forgot-password', [ForgotPasswordController::class, 'sendOtp'])
            ->middleware('throttle:auth');
        Route::post('reset-password',  [ForgotPasswordController::class, 'resetPassword'])
            ->middleware('throttle:auth');
    });

    // Authenticated routes
    Route::middleware('auth:sanctum')->group(function () {

        // Auth
        Route::prefix('auth')->group(function () {
            Route::post('logout', LogoutController::class);
            Route::get('me',     MeController::class);
        });

        // Schedule — static routes BEFORE apiResource to avoid :schedule param conflict
        Route::get('schedules/today', [ScheduleController::class, 'today']);
        Route::get('schedules/week',  [ScheduleController::class, 'week']);
        Route::apiResource('schedules', ScheduleController::class);

        // Task — static routes BEFORE apiResource
        Route::get('tasks/upcoming',        [TaskController::class, 'upcoming']);
        Route::get('tasks/overdue',         [TaskController::class, 'overdue']);
        Route::patch('tasks/{task}/status', [TaskController::class, 'updateStatus']);
        Route::apiResource('tasks', TaskController::class);

        // Attendance
        Route::get('attendance/sessions',               [AttendanceController::class, 'listSessions']);
        Route::post('attendance/sessions',              [AttendanceController::class, 'createSession']);
        Route::get('attendance/sessions/{code}',        [AttendanceController::class, 'showSession']);
        Route::get('attendance/sessions/{id}/attendees',[AttendanceController::class, 'sessionAttendees']);
        Route::post('attendance/scan',                  [AttendanceController::class, 'scan']);
        Route::get('attendance/history',                [AttendanceController::class, 'history']);
        Route::get('attendance/stats',                  [AttendanceController::class, 'stats']);

        // Announcements
        // Route::apiResource('announcements', AnnouncementController::class);

        // Analytics
        Route::get('analytics/dashboard', [AnalyticsController::class, 'dashboard']);
        Route::get('analytics/heatmap',   [AnalyticsController::class, 'heatmap']);
        Route::get('analytics/summary',   [AnalyticsController::class, 'summary']);

        // Profile
        Route::get('profile', [ProfileController::class, 'show']);
        Route::put('profile', [ProfileController::class, 'update']);
        Route::post('profile/avatar', [ProfileController::class, 'updateAvatar']);
        Route::patch('profile/notifications', [ProfileController::class, 'updateNotifications']);
    });
});

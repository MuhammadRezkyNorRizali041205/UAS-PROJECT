<?php

use App\Http\Controllers\Api\V1\Auth\ForgotPasswordController;
use App\Http\Controllers\Api\V1\Auth\LoginController;
use App\Http\Controllers\Api\V1\Auth\LogoutController;
use App\Http\Controllers\Api\V1\Auth\MeController;
use App\Http\Controllers\Api\V1\Auth\RegisterController;
use App\Http\Controllers\Api\V1\AnalyticsController;
use App\Http\Controllers\Api\V1\AnnouncementController;
use App\Http\Controllers\Api\V1\AttendanceController;
use App\Http\Controllers\Api\V1\ChatController;
use App\Http\Controllers\Api\V1\FriendController;
use App\Http\Controllers\Api\V1\GamificationController;
use App\Http\Controllers\Api\V1\LeaderboardController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\ProfileController;
use App\Http\Controllers\Api\V1\ScheduleController;
use App\Http\Controllers\Api\V1\SocialFeedController;
use App\Http\Controllers\Api\V1\StudentClassController;
use App\Http\Controllers\Api\V1\TaskController;

use App\Http\Controllers\Api\V1\Lecturer\LecturerDashboardController;
use App\Http\Controllers\Api\V1\Lecturer\LecturerClassController;
use App\Http\Controllers\Api\V1\Lecturer\LecturerTaskController;
use App\Http\Controllers\Api\V1\Lecturer\LecturerStudentController;
use App\Http\Controllers\Api\V1\Lecturer\LecturerAttendanceController;
use App\Http\Controllers\Api\V1\Lecturer\LecturerGradingController;

use App\Http\Controllers\Api\V1\Organization\OrganizationDashboardController;
use App\Http\Controllers\Api\V1\Organization\OrganizationEventController;
use App\Http\Controllers\Api\V1\Organization\OrganizationMemberController;

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
        Route::get('announcements',      [AnnouncementController::class, 'index']);
        Route::post('announcements',     [AnnouncementController::class, 'store']);
        Route::get('announcements/{id}', [AnnouncementController::class, 'show']);

        // Notifications — static routes before parameterized
        Route::get('notifications/unread-count', [NotificationController::class, 'unreadCount']);
        Route::patch('notifications/read-all',   [NotificationController::class, 'markAllRead']);
        Route::get('notifications',              [NotificationController::class, 'index']);
        Route::patch('notifications/{id}/read',  [NotificationController::class, 'markRead']);
        Route::delete('notifications/{id}',      [NotificationController::class, 'destroy']);

        // Analytics
        Route::get('analytics/dashboard', [AnalyticsController::class, 'dashboard']);
        Route::get('analytics/heatmap',   [AnalyticsController::class, 'heatmap']);
        Route::get('analytics/summary',   [AnalyticsController::class, 'summary']);

        // Profile
        Route::get('profile', [ProfileController::class, 'show']);
        Route::put('profile', [ProfileController::class, 'update']);
        Route::post('profile/avatar', [ProfileController::class, 'updateAvatar']);
        Route::patch('profile/notifications', [ProfileController::class, 'updateNotifications']);

        // Gamification
        Route::prefix('gamification')->group(function () {
            Route::get('profile',      [GamificationController::class, 'profile']);
            Route::get('quests',       [GamificationController::class, 'quests']);
            Route::get('achievements', [GamificationController::class, 'achievements']);
            Route::get('history',      [GamificationController::class, 'history']);
        });

        // Leaderboard
        Route::get('leaderboard', [LeaderboardController::class, 'index']);

        // ─── Chat ─────────────────────────────────────────────────────────────
        Route::prefix('chat')->group(function () {
            Route::get('conversations',                          [ChatController::class, 'conversations']);
            Route::post('conversations/direct',                  [ChatController::class, 'createDirect']);
            Route::post('conversations/group',                   [ChatController::class, 'createGroup']);
            Route::get('conversations/{id}/messages',            [ChatController::class, 'messages']);
            Route::post('conversations/{id}/messages',           [ChatController::class, 'sendMessage']);
            Route::post('conversations/{id}/share-achievement',  [ChatController::class, 'shareAchievement']);
            Route::post('conversations/{id}/read',               [ChatController::class, 'markRead']);
            Route::post('conversations/{id}/typing',             [ChatController::class, 'typing']);
            Route::get('users/search',                           [ChatController::class, 'searchUsers']);
        });

        // ─── Social Feed ──────────────────────────────────────────────────────
        Route::prefix('feed')->group(function () {
            Route::get('',          [SocialFeedController::class, 'index']);
            Route::post('',         [SocialFeedController::class, 'store']);
            Route::get('my',        [SocialFeedController::class, 'myFeed']);
            Route::post('{id}/like',[SocialFeedController::class, 'like']);
        });

        // ─── Friends ──────────────────────────────────────────────────────────
        Route::prefix('friends')->group(function () {
            Route::get('',             [FriendController::class, 'index']);
            Route::get('requests',     [FriendController::class, 'requests']);
            Route::post('request',     [FriendController::class, 'sendRequest']);
            Route::post('{id}/accept', [FriendController::class, 'accept']);
            Route::delete('{id}',      [FriendController::class, 'destroy']);
        });

        // ─── Student Class (role: student) ────────────────────────────────────
        Route::middleware('role:student')->prefix('student')->group(function () {
            Route::get('classes',                        [StudentClassController::class, 'myClasses']);
            Route::get('classes/{classId}',              [StudentClassController::class, 'classDetail']);
            Route::post('class-tasks/{taskId}/submit',   [StudentClassController::class, 'submitTask']);
        });

        // ─── Lecturer (role: lecturer) ────────────────────────────────────────
        Route::middleware('role:lecturer')->prefix('lecturer')->group(function () {
            Route::get('dashboard', LecturerDashboardController::class);

            Route::get('classes',                                [LecturerClassController::class, 'index']);
            Route::post('classes',                               [LecturerClassController::class, 'store']);
            Route::get('classes/{id}',                           [LecturerClassController::class, 'show']);
            Route::put('classes/{id}',                           [LecturerClassController::class, 'update']);
            Route::delete('classes/{id}',                        [LecturerClassController::class, 'destroy']);
            Route::post('classes/{id}/enroll',                   [LecturerClassController::class, 'enrollStudent']);
            Route::delete('classes/{id}/students/{studentId}',   [LecturerClassController::class, 'removeStudent']);

            // Tasks
            Route::get('classes/{classId}/tasks',                [LecturerTaskController::class, 'index']);
            Route::post('classes/{classId}/tasks',               [LecturerTaskController::class, 'store']);
            Route::get('tasks/{id}',                             [LecturerTaskController::class, 'show']);
            Route::put('tasks/{id}',                             [LecturerTaskController::class, 'update']);
            Route::delete('tasks/{id}',                          [LecturerTaskController::class, 'destroy']);
            Route::get('tasks/{id}/submissions',                 [LecturerTaskController::class, 'submissions']);
            Route::patch('submissions/{id}/grade',               [LecturerTaskController::class, 'grade']);

            // Students
            Route::get('classes/{classId}/students',             [LecturerStudentController::class, 'index']);
            Route::get('classes/{classId}/students/{studentId}/progress', [LecturerStudentController::class, 'progress']);

            // Attendance
            Route::get('classes/{classId}/attendance',           [LecturerAttendanceController::class, 'index']);
            Route::post('classes/{classId}/attendance',          [LecturerAttendanceController::class, 'store']);
            Route::get('attendance/{sessionId}',                 [LecturerAttendanceController::class, 'show']);
            Route::patch('attendance/{sessionId}/close',         [LecturerAttendanceController::class, 'close']);

            // Grading (all pending)
            Route::get('grading',                                [LecturerGradingController::class, 'index']);
        });

        // ─── Organization (role: organization) ───────────────────────────────
        Route::middleware('role:organization')->prefix('org')->group(function () {
            Route::get('dashboard', OrganizationDashboardController::class);

            Route::get('events',                         [OrganizationEventController::class, 'index']);
            Route::post('events',                        [OrganizationEventController::class, 'store']);
            Route::get('events/{id}',                    [OrganizationEventController::class, 'show']);
            Route::put('events/{id}',                    [OrganizationEventController::class, 'update']);
            Route::patch('events/{id}/publish',          [OrganizationEventController::class, 'publish']);
            Route::delete('events/{id}',                 [OrganizationEventController::class, 'destroy']);
            Route::get('events/{id}/registrations',      [OrganizationEventController::class, 'registrations']);

            Route::get('members',                        [OrganizationMemberController::class, 'index']);
            Route::post('members',                       [OrganizationMemberController::class, 'store']);
            Route::patch('members/{id}/role',            [OrganizationMemberController::class, 'updateRole']);
            Route::delete('members/{id}',                [OrganizationMemberController::class, 'destroy']);
        });
    });
});

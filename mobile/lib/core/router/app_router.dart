// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/announcement/presentation/screens/announcement_feed_screen.dart';
import '../../features/announcement/presentation/screens/announcement_detail_screen.dart';
import '../../features/notification/presentation/screens/notification_screen.dart';

import '../../features/schedule/presentation/screens/schedule_list_screen.dart';
import '../../features/schedule/presentation/screens/schedule_form_screen.dart';
import '../../features/schedule/presentation/screens/schedule_detail_screen.dart';

import '../../features/task/presentation/screens/task_list_screen.dart';
import '../../features/task/presentation/screens/task_form_screen.dart';
import '../../features/task/presentation/screens/task_detail_screen.dart';

import '../../features/calendar/presentation/screens/calendar_screen.dart';

import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/attendance/presentation/screens/qr_scanner_screen.dart';
import '../../features/attendance/presentation/screens/qr_generator_screen.dart';
import '../../features/attendance/presentation/screens/attendance_history_screen.dart';

import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';

import '../../features/gamification/presentation/screens/daily_quest_screen.dart';
import '../../features/gamification/presentation/screens/achievement_screen.dart';
import '../../features/gamification/presentation/screens/leaderboard_screen.dart';

import '../../features/chat/presentation/screens/conversation_list_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/search_user_screen.dart';
import '../../features/chat/presentation/screens/create_group_screen.dart';
import '../../features/feed/presentation/screens/social_feed_screen.dart';
import '../../features/friend/presentation/screens/friend_list_screen.dart';

// Lecturer screens
import '../../features/lecturer/presentation/screens/lecturer_dashboard_screen.dart';
import '../../features/lecturer/presentation/screens/lecturer_class_list_screen.dart';
import '../../features/lecturer/presentation/screens/lecturer_class_detail_screen.dart';
import '../../features/lecturer/presentation/screens/lecturer_task_submissions_screen.dart';
import '../../features/lecturer/presentation/screens/lecturer_grade_submission_screen.dart';
import '../../features/lecturer/presentation/screens/lecturer_student_progress_screen.dart';

// Organization screens
import '../../features/organization/presentation/screens/org_dashboard_screen.dart';
import '../../features/organization/presentation/screens/org_event_list_screen.dart';
import '../../features/organization/presentation/screens/org_event_form_screen.dart';
import '../../features/organization/presentation/screens/org_member_list_screen.dart';

// Student class screens
import '../../features/student_class/presentation/screens/student_class_list_screen.dart';
import '../../features/student_class/presentation/screens/student_class_detail_screen.dart';
import '../../features/student_class/presentation/screens/student_task_submit_screen.dart';

import '../../features/chat/presentation/providers/chat_providers.dart';
import '../../shared/theme/app_colors.dart';

part 'app_router.g.dart';

// ─── Route names ──────────────────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const splash         = '/splash';
  static const login          = '/login';
  static const register       = '/register';
  static const forgotPassword = '/forgot-password';

  // ── Student bottom nav roots ───────────────────────────────────────────────
  static const dashboard  = '/dashboard';
  static const schedule   = '/schedule';
  static const task       = '/task';
  static const chat       = '/chat';
  static const profile    = '/profile';

  // ── Full-screen feature routes ─────────────────────────────────────────────
  static const calendar   = '/calendar';
  static const attendance = '/attendance';
  static const feed       = '/feed';
  static const friends    = '/friends';

  // ── Dashboard sub-routes ───────────────────────────────────────────────────
  static const analytics     = '/dashboard/analytics';
  static const announcement  = '/dashboard/announcement';
  static const notification  = '/dashboard/notification';

  static const attendanceScan     = '/attendance/scan';
  static const attendanceGenerate = '/attendance/generate';
  static const attendanceHistory  = '/attendance/history';

  static const scheduleCreate = '/schedule/create';
  static const taskCreate     = '/task/create';

  static const profileEdit              = '/profile/edit';
  static const gamificationQuests       = '/profile/gamification/quests';
  static const gamificationAchievements = '/profile/gamification/achievements';
  static const gamificationLeaderboard  = '/profile/gamification/leaderboard';

  static const chatNew      = '/chat/new';
  static const chatNewGroup = '/chat/new-group';
  static String chatConversation(String id) => '/chat/$id';

  static String scheduleDetail(String id)     => '/schedule/$id';
  static String scheduleEdit(String id)       => '/schedule/$id/edit';
  static String taskDetail(String id)         => '/task/$id';
  static String taskEdit(String id)           => '/task/$id/edit';
  static String announcementDetail(String id) => '/dashboard/announcement/$id';

  // ── Student class routes ───────────────────────────────────────────────────
  static const studentClasses = '/student/classes';
  static String studentClassDetail(String id) => '/student/classes/$id';
  static String studentTaskSubmit(String taskId, String classId) =>
      '/student/class-tasks/$taskId/submit?classId=$classId';

  // ── Lecturer routes ────────────────────────────────────────────────────────
  static const lecturerDashboard = '/lecturer/dashboard';
  static const lecturerClasses   = '/lecturer/classes';
  static String lecturerClassDetail(String id)  => '/lecturer/classes/$id';
  static String lecturerTaskSubmissions(String id) => '/lecturer/tasks/$id/submissions';
  static String lecturerGrade(String submissionId) => '/lecturer/submissions/$submissionId/grade';
  static String lecturerStudentProgress(String classId, String studentId) =>
      '/lecturer/classes/$classId/students/$studentId/progress';

  // ── Organization routes ────────────────────────────────────────────────────
  static const orgDashboard = '/org/dashboard';
  static const orgEvents    = '/org/events';
  static const orgEventsCreate = '/org/events/create';
  static String orgEventDetail(String id) => '/org/events/$id';
  static const orgMembers   = '/org/members';

  // ── Admin routes ───────────────────────────────────────────────────────────
  static const adminDashboard = '/admin/dashboard';
}

// ─── Router provider ──────────────────────────────────────────────────────────
@riverpod
GoRouter appRouter(Ref ref) {
  final notifier = _RouterRefreshNotifier();

  ref.listen<AuthState>(authProvider, (_, next) => notifier.update(next));
  ref.onDispose(notifier.dispose);

  notifier.update(ref.read(authProvider));

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, state) {
      final path      = state.matchedLocation;
      final authState = notifier.authState;

      final isSplash   = path == AppRoutes.splash;
      final isAuthRoute = path == AppRoutes.login ||
          path == AppRoutes.register ||
          path == AppRoutes.forgotPassword;

      if (authState is AuthInitial || authState is AuthLoading) return null;

      if (authState is AuthAuthenticated) {
        if (isSplash || isAuthRoute) {
          return _homeForRole(authState.user.role);
        }
        return null;
      }

      if (!isAuthRoute) return AppRoutes.login;
      return null;
    },
    routes: [
      // ─── Splash & Auth ────────────────────────────────────────────────
      GoRoute(path: AppRoutes.splash,         builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login,          builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register,       builder: (_, __) => const RegisterScreen()),
      GoRoute(path: AppRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),

      // ─── Full-screen routes (no bottom nav) ───────────────────────────
      GoRoute(
        path: AppRoutes.calendar,
        builder: (_, __) => const CalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.attendance,
        builder: (_, __) => const AttendanceScreen(),
        routes: [
          GoRoute(path: 'scan',     builder: (_, __) => const QrScannerScreen()),
          GoRoute(path: 'generate', builder: (_, __) => const QrGeneratorScreen()),
          GoRoute(path: 'history',  builder: (_, __) => const AttendanceHistoryScreen()),
        ],
      ),
      GoRoute(path: AppRoutes.feed,    builder: (_, __) => const SocialFeedScreen()),
      GoRoute(path: AppRoutes.friends, builder: (_, __) => const FriendListScreen()),

      // ─── Student class routes ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.studentClasses,
        builder: (_, __) => const StudentClassListScreen(),
        routes: [
          GoRoute(
            path: ':classId',
            builder: (_, state) => StudentClassDetailScreen(classId: state.pathParameters['classId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/student/class-tasks/:taskId/submit',
        builder: (_, state) => StudentTaskSubmitScreen(
          taskId:  state.pathParameters['taskId']!,
          classId: state.uri.queryParameters['classId'] ?? '',
        ),
      ),

      // ─── Lecturer routes ──────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _LecturerShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.lecturerDashboard,
              builder: (_, __) => const LecturerDashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.lecturerClasses,
              builder: (_, __) => const LecturerClassListScreen(),
              routes: [
                GoRoute(
                  path: ':classId',
                  builder: (_, state) => LecturerClassDetailScreen(classId: state.pathParameters['classId']!),
                  routes: [
                    GoRoute(
                      path: 'students/:studentId/progress',
                      builder: (_, state) => LecturerStudentProgressScreen(
                        classId:   state.pathParameters['classId']!,
                        studentId: state.pathParameters['studentId']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/lecturer/profile',
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(path: 'edit', builder: (_, __) => const EditProfileScreen()),
              ],
            ),
          ]),
        ],
      ),
      // Full-screen lecturer routes (no bottom nav)
      GoRoute(
        path: '/lecturer/tasks/:taskId/submissions',
        builder: (_, state) => LecturerTaskSubmissionsScreen(taskId: state.pathParameters['taskId']!),
      ),
      GoRoute(
        path: '/lecturer/submissions/:submissionId/grade',
        builder: (_, state) => LecturerGradeSubmissionScreen(submissionId: state.pathParameters['submissionId']!),
      ),

      // ─── Organization routes ──────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _OrgShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.orgDashboard, builder: (_, __) => const OrgDashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.orgEvents,
              builder: (_, __) => const OrgEventListScreen(),
              routes: [
                GoRoute(path: 'create', builder: (_, __) => const OrgEventFormScreen()),
                GoRoute(path: ':eventId', builder: (_, state) => const OrgEventListScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.orgMembers, builder: (_, __) => const OrgMemberListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/org/profile',
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(path: 'edit', builder: (_, __) => const EditProfileScreen()),
              ],
            ),
          ]),
        ],
      ),

      // ─── Admin routes ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (_, __) => const _AdminDashboardScreen(),
      ),

      // ─── Main Student Shell (5 branches) ──────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (_, __) => const DashboardScreen(),
              routes: [
                GoRoute(path: 'analytics',    builder: (_, __) => const AnalyticsScreen()),
                GoRoute(
                  path: 'announcement',
                  builder: (_, __) => const AnnouncementFeedScreen(),
                  routes: [
                    GoRoute(
                      path: ':announcementId',
                      builder: (_, state) => AnnouncementDetailScreen(id: state.pathParameters['announcementId']!),
                    ),
                  ],
                ),
                GoRoute(path: 'notification', builder: (_, __) => const NotificationScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.schedule,
              builder: (_, __) => const ScheduleListScreen(),
              routes: [
                GoRoute(path: 'create', builder: (_, __) => const ScheduleFormScreen()),
                GoRoute(
                  path: ':scheduleId',
                  builder: (_, state) => ScheduleDetailScreen(id: state.pathParameters['scheduleId']!),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (_, state) => ScheduleFormScreen(id: state.pathParameters['scheduleId']),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.task,
              builder: (_, __) => const TaskListScreen(),
              routes: [
                GoRoute(path: 'create', builder: (_, __) => const TaskFormScreen()),
                GoRoute(
                  path: ':taskId',
                  builder: (_, state) => TaskDetailScreen(id: state.pathParameters['taskId']!),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (_, state) => TaskFormScreen(id: state.pathParameters['taskId']),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.chat,
              builder: (_, __) => const ConversationListScreen(),
              routes: [
                GoRoute(path: 'new',       builder: (_, __) => const SearchUserScreen()),
                GoRoute(path: 'new-group', builder: (_, __) => const CreateGroupScreen()),
                GoRoute(
                  path: ':conversationId',
                  builder: (_, state) => ChatScreen(conversationId: state.pathParameters['conversationId']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(path: 'edit',                     builder: (_, __) => const EditProfileScreen()),
                GoRoute(path: 'gamification/quests',      builder: (_, __) => const DailyQuestScreen()),
                GoRoute(path: 'gamification/achievements',builder: (_, __) => const AchievementScreen()),
                GoRoute(path: 'gamification/leaderboard', builder: (_, __) => const LeaderboardScreen()),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
}

String _homeForRole(String? role) {
  switch (role) {
    case 'lecturer':     return AppRoutes.lecturerDashboard;
    case 'organization': return AppRoutes.orgDashboard;
    case 'admin':        return AppRoutes.adminDashboard;
    default:             return AppRoutes.dashboard;
  }
}

// ─── Router refresh notifier ──────────────────────────────────────────────────
class _RouterRefreshNotifier extends ChangeNotifier {
  AuthState _authState = const AuthInitial();
  AuthState get authState => _authState;

  void update(AuthState newState) {
    if (_authState.runtimeType == newState.runtimeType &&
        newState is! AuthAuthenticated) {
      return;
    }
    _authState = newState;
    notifyListeners();
  }
}

// ─── Student Shell ────────────────────────────────────────────────────────────
class _AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const _AppShell({required this.navigationShell});

  static const _destinations = [
    (icon: Icons.dashboard_outlined,        active: Icons.dashboard_rounded,        label: 'Beranda'),
    (icon: Icons.calendar_today_outlined,   active: Icons.calendar_today_rounded,   label: 'Jadwal'),
    (icon: Icons.task_alt_outlined,         active: Icons.task_alt_rounded,         label: 'Tugas'),
    (icon: Icons.chat_bubble_outline_rounded, active: Icons.chat_bubble_rounded,    label: 'Chat'),
    (icon: Icons.person_outline_rounded,    active: Icons.person_rounded,           label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatUnread = ref.watch(conversationListProvider).maybeWhen(
      data: (convs) => convs.fold<int>(0, (sum, c) => sum + c.unreadCount),
      orElse: () => 0,
    );

    return Scaffold(
      body: SafeArea(bottom: false, child: navigationShell),
      bottomNavigationBar: _buildNavBar(context, chatUnread),
    );
  }

  Widget _buildNavBar(BuildContext context, int chatUnread) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
        color: AppColors.surface,
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
          destinations: _destinations.indexed.map((entry) {
            final i = entry.$1;
            final d = entry.$2;
            final showBadge = i == 3 && chatUnread > 0;
            return NavigationDestination(
              icon: showBadge ? Badge(label: Text(chatUnread > 99 ? '99+' : '$chatUnread'), child: Icon(d.icon)) : Icon(d.icon),
              selectedIcon: showBadge ? Badge(label: Text(chatUnread > 99 ? '99+' : '$chatUnread'), child: Icon(d.active)) : Icon(d.active),
              label: d.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Lecturer Shell ───────────────────────────────────────────────────────────
class _LecturerShell extends StatelessWidget {
  const _LecturerShell({required this.shell});
  final StatefulNavigationShell shell;

  static const _destinations = [
    (icon: Icons.dashboard_outlined,     active: Icons.dashboard_rounded, label: 'Beranda'),
    (icon: Icons.school_outlined,        active: Icons.school_rounded,    label: 'Kelas'),
    (icon: Icons.person_outline_rounded, active: Icons.person_rounded,    label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(bottom: false, child: shell),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
          color: AppColors.surface,
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
            destinations: _destinations.map((d) => NavigationDestination(
              icon: Icon(d.icon), selectedIcon: Icon(d.active), label: d.label,
            )).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Organization Shell ───────────────────────────────────────────────────────
class _OrgShell extends StatelessWidget {
  const _OrgShell({required this.shell});
  final StatefulNavigationShell shell;

  static const _destinations = [
    (icon: Icons.dashboard_outlined,          active: Icons.dashboard_rounded,         label: 'Beranda'),
    (icon: Icons.event_outlined,              active: Icons.event_rounded,             label: 'Event'),
    (icon: Icons.people_outline_rounded,      active: Icons.people_rounded,            label: 'Anggota'),
    (icon: Icons.person_outline_rounded,      active: Icons.person_rounded,            label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(bottom: false, child: shell),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
          color: AppColors.surface,
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
            destinations: _destinations.map((d) => NavigationDestination(
              icon: Icon(d.icon), selectedIcon: Icon(d.active), label: d.label,
            )).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Admin Dashboard (simple) ─────────────────────────────────────────────────
class _AdminDashboardScreen extends StatelessWidget {
  const _AdminDashboardScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface, title: const Text('Admin Dashboard')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: AppColors.roleAdmin, size: 72),
            SizedBox(height: 16),
            Text('Admin Panel', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Fitur admin tersedia via web dashboard', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

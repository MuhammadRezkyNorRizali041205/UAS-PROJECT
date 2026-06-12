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
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/attendance/presentation/screens/qr_scanner_screen.dart';
import '../../features/attendance/presentation/screens/qr_generator_screen.dart';
import '../../features/attendance/presentation/screens/attendance_history_screen.dart';
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

import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';

import '../../shared/theme/app_colors.dart';

part 'app_router.g.dart';

// ─── Route names ──────────────────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const dashboard = '/dashboard';
  static const analytics = '/analytics';
  static const attendance = '/attendance';
  static const attendanceScan = '/attendance/scan';
  static const attendanceGenerate = '/attendance/generate';
  static const attendanceHistory = '/attendance/history';
  static const announcement = '/announcement';
  static const notification = '/notification';
  static const schedule = '/schedule';
  static const scheduleCreate = '/schedule/create';
  static const task = '/task';
  static const taskCreate = '/task/create';
  static const calendar = '/calendar';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';

  static String scheduleDetail(String id) => '/schedule/$id';
  static String scheduleEdit(String id) => '/schedule/$id/edit';
  static String taskDetail(String id) => '/task/$id';
  static String taskEdit(String id) => '/task/$id/edit';
  static String announcementDetail(String id) => '/announcement/$id';
  static String attendanceSession(String id) => '/attendance/session/$id';
}

// ─── Router provider ──────────────────────────────────────────────────────────
//
// KEY FIX: Do NOT use ref.watch(authProvider) here — that recreates the entire
// GoRouter on every auth-state change, resetting navigation to initialLocation.
// Instead, use a ChangeNotifier with refreshListenable so GoRouter re-evaluates
// the redirect without rebuilding the router instance.
//
@riverpod
GoRouter appRouter(Ref ref) {
  final notifier = _RouterRefreshNotifier();

  // Listen to auth state changes and notify GoRouter to re-run redirect
  ref.listen<AuthState>(authProvider, (_, next) => notifier.update(next));
  ref.onDispose(notifier.dispose);

  // Seed with the current state so the first redirect is correct
  notifier.update(ref.read(authProvider));

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, state) {
      final path = state.matchedLocation;
      final authState = notifier.authState;

      final isSplash = path == AppRoutes.splash;
      final isAuthRoute = path == AppRoutes.login ||
          path == AppRoutes.register ||
          path == AppRoutes.forgotPassword;

      // Still checking session — don't interfere with navigation.
      // Splash owns initial routing; blocking here causes bounce-back loop.
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      // Authenticated — push away from splash / auth screens
      if (authState is AuthAuthenticated) {
        if (isSplash || isAuthRoute) return AppRoutes.dashboard;
        return null;
      }

      // Unauthenticated / error — redirect away from protected routes AND splash
      // FIX: previously only redirected if !isAuthRoute && !isSplash
      //      that kept users stuck on splash forever when unauthenticated
      if (!isAuthRoute) return AppRoutes.login;
      return null;
    },
    routes: [
      // ─── Splash & Auth ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // ─── Main App Shell ────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _AppShell(navigationShell: navigationShell),
        branches: [
          // ── Branch 0: Home / Dashboard ──────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: 'dashboard',
                builder: (_, __) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'analytics',
                    name: 'analytics',
                    builder: (_, __) => const AnalyticsScreen(),
                  ),
                  GoRoute(
                    path: 'attendance',
                    name: 'attendance',
                    builder: (_, __) => const AttendanceScreen(),
                    routes: [
                      GoRoute(
                        path: 'scan',
                        name: 'attendance-scan',
                        builder: (_, __) => const QrScannerScreen(),
                      ),
                      GoRoute(
                        path: 'generate',
                        name: 'attendance-generate',
                        builder: (_, __) => const QrGeneratorScreen(),
                      ),
                      GoRoute(
                        path: 'history',
                        name: 'attendance-history',
                        builder: (_, __) => const AttendanceHistoryScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'announcement',
                    name: 'announcement',
                    builder: (_, __) => const AnnouncementFeedScreen(),
                    routes: [
                      GoRoute(
                        path: ':announcementId',
                        name: 'announcement-detail',
                        builder: (_, state) => AnnouncementDetailScreen(
                          id: state.pathParameters['announcementId']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'notification',
                    name: 'notification',
                    builder: (_, __) => const NotificationScreen(),
                  ),
                ],
              ),
            ],
          ),

          // ── Branch 1: Schedule ───────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.schedule,
                name: 'schedule',
                builder: (_, __) => const ScheduleListScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    name: 'schedule-create',
                    builder: (_, __) => const ScheduleFormScreen(),
                  ),
                  GoRoute(
                    path: ':scheduleId',
                    name: 'schedule-detail',
                    builder: (_, state) => ScheduleDetailScreen(
                      id: state.pathParameters['scheduleId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: 'schedule-edit',
                        builder: (_, state) => ScheduleFormScreen(
                          id: state.pathParameters['scheduleId'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Branch 2: Task ───────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.task,
                name: 'task',
                builder: (_, __) => const TaskListScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    name: 'task-create',
                    builder: (_, __) => const TaskFormScreen(),
                  ),
                  GoRoute(
                    path: ':taskId',
                    name: 'task-detail',
                    builder: (_, state) => TaskDetailScreen(
                      id: state.pathParameters['taskId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: 'task-edit',
                        builder: (_, state) => TaskFormScreen(
                          id: state.pathParameters['taskId'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Branch 3: Calendar ───────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                name: 'calendar',
                builder: (_, __) => const CalendarScreen(),
              ),
            ],
          ),

          // ── Branch 4: Profile ────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (_, __) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'profile-edit',
                    builder: (_, __) => const EditProfileScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// ─── Router refresh notifier ──────────────────────────────────────────────────
class _RouterRefreshNotifier extends ChangeNotifier {
  AuthState _authState = const AuthInitial();
  AuthState get authState => _authState;

  void update(AuthState newState) {
    if (_authState.runtimeType == newState.runtimeType &&
        newState is! AuthAuthenticated) {
      return; // Skip redundant notifications
    }
    _authState = newState;
    notifyListeners();
  }
}

// ─── Shell widget ─────────────────────────────────────────────────────────────

const _rootPaths = {
  '/dashboard',
  '/schedule',
  '/task',
  '/calendar',
  '/profile'
};

class _AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _AppShell({required this.navigationShell});

  static const _destinations = [
    (
      icon: Icons.dashboard_outlined,
      active: Icons.dashboard_rounded,
      label: 'Beranda'
    ),
    (
      icon: Icons.calendar_today_outlined,
      active: Icons.calendar_today_rounded,
      label: 'Jadwal'
    ),
    (
      icon: Icons.task_alt_outlined,
      active: Icons.task_alt_rounded,
      label: 'Tugas'
    ),
    (
      icon: Icons.calendar_month_outlined,
      active: Icons.calendar_month_rounded,
      label: 'Kalender'
    ),
    (
      icon: Icons.person_outline_rounded,
      active: Icons.person_rounded,
      label: 'Profil'
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;
    final showNav = _rootPaths.contains(currentPath);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (isDesktop) {
      return _DesktopShell(
        navigationShell: navigationShell,
        destinations: _destinations,
      );
    }

    return Scaffold(
      body: SafeArea(bottom: false, child: navigationShell),
      bottomNavigationBar: showNav
          ? _MobileNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (i) => navigationShell.goBranch(
                i,
                initialLocation: i == navigationShell.currentIndex,
              ),
              destinations: _destinations,
            )
          : null,
    );
  }
}

class _MobileNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<({IconData icon, IconData active, String label})> destinations;

  const _MobileNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
        color: AppColors.surface,
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          height: 60,
          destinations: destinations
              .map((d) => NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.active),
                    label: d.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _DesktopShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<({IconData icon, IconData active, String label})> destinations;

  const _DesktopShell({
    required this.navigationShell,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.border)),
                color: AppColors.surface,
              ),
              child: NavigationRail(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (i) => navigationShell.goBranch(
                  i,
                  initialLocation: i == navigationShell.currentIndex,
                ),
                labelType: NavigationRailLabelType.all,
                groupAlignment: -1.0,
                minWidth: 72,
                destinations: destinations
                    .map((d) => NavigationRailDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(d.active),
                          label: Text(d.label),
                        ))
                    .toList(),
              ),
            ),
            Expanded(child: navigationShell),
          ],
        ),
      ),
    );
  }
}

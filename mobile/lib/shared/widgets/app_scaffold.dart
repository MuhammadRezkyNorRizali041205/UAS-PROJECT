// lib/shared/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';

class _NavItem {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const _navItems = [
  _NavItem(
    path: '/dashboard',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard_rounded,
    label: 'Beranda',
  ),
  _NavItem(
    path: '/schedule',
    icon: Icons.calendar_today_outlined,
    activeIcon: Icons.calendar_today_rounded,
    label: 'Jadwal',
  ),
  _NavItem(
    path: '/task',
    icon: Icons.task_alt_outlined,
    activeIcon: Icons.task_alt_rounded,
    label: 'Tugas',
  ),
  _NavItem(
    path: '/calendar',
    icon: Icons.calendar_month_outlined,
    activeIcon: Icons.calendar_month_rounded,
    label: 'Kalender',
  ),
  _NavItem(
    path: '/attendance',
    icon: Icons.qr_code_scanner_outlined,
    activeIcon: Icons.qr_code_scanner_rounded,
    label: 'Presensi',
  ),
  _NavItem(
    path: '/profile',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'Profil',
  ),
];

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showAppBar;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.showAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return _DesktopScaffold(
        body: body,
        title: title,
        actions: actions,
        floatingActionButton: floatingActionButton,
        showAppBar: showAppBar,
      );
    }
    return _MobileScaffold(
      body: body,
      title: title,
      actions: actions,
      floatingActionButton: floatingActionButton,
      showAppBar: showAppBar,
    );
  }
}

class _MobileScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showAppBar;

  const _MobileScaffold({
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.showAppBar = false,
  });

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _navItems.indexWhere((item) {
      if (item.path == '/') return location == '/';
      return location.startsWith(item.path);
    });
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      appBar: showAppBar && title != null
          ? AppBar(title: Text(title!), actions: actions)
          : null,
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) => context.go(_navItems[i].path),
          destinations: _navItems
              .map(
                (item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.activeIcon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _DesktopScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showAppBar;

  const _DesktopScaffold({
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.showAppBar = false,
  });

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _navItems.indexWhere((item) {
      if (item.path == '/') return location == '/';
      return location.startsWith(item.path);
    });
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

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
                selectedIndex: currentIndex,
                onDestinationSelected: (i) => context.go(_navItems[i].path),
                labelType: NavigationRailLabelType.all,
                groupAlignment: -1.0,
                destinations: _navItems
                    .map(
                      (item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.activeIcon),
                        label: Text(item.label),
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  if (showAppBar && title != null)
                    AppBar(title: Text(title!), actions: actions),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

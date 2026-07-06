// lib/features/auth/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  // Same WebOptions as _AuthInterceptor and Auth notifier so all reads
  // hit the same IndexedDB bucket on web.
  static const _storage = FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'smart_campus_db',
      publicKey: 'smart_campus_key',
    ),
  );

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    _checkAndRedirect();
  }

  Future<void> _checkAndRedirect() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    try {
      // Fast-path: read token directly from storage.
      // On web, flutter_secure_storage uses IndexedDB; it may be empty after
      // a fresh flutter run even if the user was previously logged in (e.g.
      // IndexedDB cleared by the browser or hot restart race condition).
      final token = await _storage.read(key: AppConstants.tokenKey);

      if (!mounted) return;

      if (token == null || token.isEmpty) {
        // No stored credentials — show onboarding for new users, login otherwise.
        final onboarded = prefs.getBool('onboarding_completed') ?? false;
        context.go(onboarded ? '/login' : '/onboarding');
        return;
      }

      // Token found — wait for authProvider to validate it against the server.
      // _checkSession() is already running in the background (called in Auth.build).
      AuthState authState = ref.read(authProvider);
      for (int i = 0; i < 60; i++) {
        if (authState is! AuthInitial && authState is! AuthLoading) break;
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        authState = ref.read(authProvider);
      }

      if (!mounted) return;

      if (authState is AuthAuthenticated) {
        context.go(_homeForRole(authState.user.role));
      } else {
        // Token was rejected by the server (401) or timed out — go to login.
        context.go('/login');
      }
    } catch (_) {
      // Storage read error (e.g. web IndexedDB unavailable after restart).
      // Safe fallback: redirect to login; user can re-authenticate.
      if (!mounted) return;
      context.go('/login');
    }
  }

  String _homeForRole(String role) => switch (role) {
    'lecturer'     => '/lecturer/dashboard',
    'organization' => '/org/dashboard',
    'org_admin'    => '/org/dashboard',
    'admin'        => '/admin/dashboard',
    _              => '/dashboard',
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo container
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.9),
                        AppColors.primaryLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 28),

                // App name
                const Text(
                  'Smart Campus',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Your Academic Assistant',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 56),

                // Animated loading dots
                _AnimatedDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_ctrl.value + i / 3.0) % 1.0;
            final opacity =
                (t < 0.5 ? t * 2.0 : (1.0 - t) * 2.0).clamp(0.15, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}

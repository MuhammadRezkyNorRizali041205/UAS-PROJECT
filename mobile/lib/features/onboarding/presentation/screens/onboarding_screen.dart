// lib/features/onboarding/presentation/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _skip() async {
    await ref.read(onboardingProvider.notifier).skipOnboarding();
    if (mounted) context.go('/login');
  }

  Future<void> _complete() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final page  = state.currentPage;

    return Scaffold(
      body: Stack(
        children: [
          // ── Pages ──────────────────────────────────────────────────────
          PageView(
            controller: _pageController,
            onPageChanged: (i) =>
                ref.read(onboardingProvider.notifier).goToPage(i),
            children: const [
              _Page1Welcome(),
              _Page2Schedule(),
              _Page3Deadline(),
              _Page4Productivity(),
              _Page5Start(),
            ],
          ),

          // ── Skip button ─────────────────────────────────────────────────
          if (page < 4)
            Positioned(
              top: 52,
              right: 24,
              child: SafeArea(
                child: TextButton(
                  onPressed: _skip,
                  child: const Text(
                    'Lewati',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),

          // ── Bottom nav: dots + next button ──────────────────────────────
          if (page < 4)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _DotsIndicator(
                          count: 5, currentIndex: page),
                      Flexible(
                        fit: FlexFit.loose,
                        child: ElevatedButton(
                        onPressed: () {
                          final next = page + 1;
                          ref
                              .read(onboardingProvider.notifier)
                              .goToPage(next);
                          _goToPage(next);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Lanjut',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Page 5 bottom buttons ────────────────────────────────────────
          if (page == 4)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(32, 0, 32, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _DotsIndicator(count: 5, currentIndex: 4),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go('/register'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Daftar Sekarang',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _complete,
                        child: const Text(
                          'Sudah punya akun? Masuk',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Dots Indicator ───────────────────────────────────────────────────────────

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.currentIndex});
  final int count, currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            border: isActive
                ? null
                : Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Page 1 — Welcome ─────────────────────────────────────────────────────────

class _Page1Welcome extends StatefulWidget {
  const _Page1Welcome();

  @override
  State<_Page1Welcome> createState() => _Page1WelcomeState();
}

class _Page1WelcomeState extends State<_Page1Welcome>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B2A), Color(0xFF0F0F23)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Expanded(
                flex: 55,
                child: Center(
                  child: ScaleTransition(
                    scale: _pulse,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.15),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ).createShader(bounds),
                      child: const Text(
                        'Smart Campus',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Asisten akademik pintar untuk\nmahasiswa modern',
                      style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Page 2 — Jadwal ──────────────────────────────────────────────────────────

class _Page2Schedule extends StatefulWidget {
  const _Page2Schedule();

  @override
  State<_Page2Schedule> createState() => _Page2ScheduleState();
}

class _Page2ScheduleState extends State<_Page2Schedule>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _slide = Tween<Offset>(
            begin: const Offset(0.5, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B2A), Color(0xFF12102A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Expanded(
                flex: 55,
                child: SlideTransition(
                  position: _slide,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MockScheduleCard(
                        icon: Icons.school_outlined,
                        subject: 'Matematika Diskrit',
                        time: '08:00 - 09:40',
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 12),
                      _MockScheduleCard(
                        icon: Icons.computer_outlined,
                        subject: 'Praktikum Basis Data',
                        time: '13:00 - 14:40',
                        color: AppColors.categoryPracticum,
                      ),
                    ],
                  ),
                ),
              ),
              const Expanded(
                flex: 45,
                child: Column(
                  children: [
                    Text(
                      'Jadwal Kuliah Terorganisir',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Semua jadwal dalam satu tempat.\nTidak ada lagi konflik jadwal.',
                      style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockScheduleCard extends StatelessWidget {
  const _MockScheduleCard(
      {required this.icon,
      required this.subject,
      required this.time,
      required this.color});
  final IconData icon;
  final String subject, time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(time,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Hari ini',
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Page 3 — Deadline ────────────────────────────────────────────────────────

class _Page3Deadline extends StatefulWidget {
  const _Page3Deadline();

  @override
  State<_Page3Deadline> createState() => _Page3DeadlineState();
}

class _Page3DeadlineState extends State<_Page3Deadline>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.04)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B2A), Color(0xFF1A0F14)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Expanded(
                flex: 55,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _pulse,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: AppColors.danger, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Laporan Praktikum',
                              style: TextStyle(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '2 jam lagi',
                              style: TextStyle(
                                  color: AppColors.danger, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tugas Analisis Algoritma',
                                    style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                SizedBox(height: 4),
                                Text('Deadline: Hari ini, 23:59',
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Critical',
                              style: TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: 45,
                child: Column(
                  children: [
                    Text(
                      'Deadline Tidak Terlewat',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Reminder otomatis sebelum deadline.\nCountdown real-time setiap saat.',
                      style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Page 4 — Produktivitas ───────────────────────────────────────────────────

class _Page4Productivity extends StatefulWidget {
  const _Page4Productivity();

  @override
  State<_Page4Productivity> createState() => _Page4ProductivityState();
}

class _Page4ProductivityState extends State<_Page4Productivity>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _grow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _grow = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heatmapColors = [
      Colors.transparent,
      AppColors.success.withValues(alpha: 0.2),
      AppColors.success.withValues(alpha: 0.4),
      AppColors.success.withValues(alpha: 0.7),
      AppColors.success,
    ];

    final heatData = [
      [0, 2, 1, 3, 4, 2, 1],
      [1, 3, 2, 4, 3, 1, 0],
      [2, 1, 3, 2, 4, 3, 2],
      [3, 4, 2, 1, 3, 4, 1],
      [1, 2, 4, 3, 2, 1, 3],
    ];

    final barHeights = [0.55, 0.80, 0.65];
    final barColors  = [AppColors.primary, AppColors.success, AppColors.info];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B2A), Color(0xFF0F1A10)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Expanded(
                flex: 55,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mini heatmap
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: heatData.map((row) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: row.map((val) {
                              return Container(
                                margin: const EdgeInsets.only(right: 4),
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: heatmapColors[val],
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                      color: AppColors.border.withValues(
                                          alpha: val == 0 ? 1 : 0)),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 24),
                    // Mini bar chart
                    AnimatedBuilder(
                      animation: _grow,
                      builder: (_, __) => Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(3, (i) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 28,
                            height: (barHeights[i] * 120 * _grow.value),
                            decoration: BoxDecoration(
                              color: barColors[i],
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: 45,
                child: Column(
                  children: [
                    Text(
                      'Pantau Produktivitasmu',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Lihat konsistensi belajar,\nstreak harian, dan pencapaianmu.',
                      style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Page 5 — Mulai ───────────────────────────────────────────────────────────

class _Page5Start extends StatelessWidget {
  const _Page5Start();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Expanded(
                flex: 55,
                child: Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Expanded(
                flex: 45,
                child: Column(
                  children: [
                    Text(
                      'Siap Memulai?',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Bergabung dengan ribuan mahasiswa\nyang lebih produktif',
                      style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

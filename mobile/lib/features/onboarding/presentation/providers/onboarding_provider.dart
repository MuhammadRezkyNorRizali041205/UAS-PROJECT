// lib/features/onboarding/presentation/providers/onboarding_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_provider.g.dart';

const _kOnboardingKey = 'onboarding_completed';

@riverpod
Future<bool> onboardingCompleted(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingKey) ?? false;
}

class OnboardingState {
  final int currentPage;
  final bool isCompleted;
  const OnboardingState({this.currentPage = 0, this.isCompleted = false});
  OnboardingState copyWith({int? currentPage, bool? isCompleted}) =>
      OnboardingState(
        currentPage: currentPage ?? this.currentPage,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  static const int totalPages = 5;

  @override
  OnboardingState build() => const OnboardingState();

  void nextPage() {
    if (state.currentPage < totalPages - 1) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void goToPage(int page) {
    state = state.copyWith(currentPage: page.clamp(0, totalPages - 1));
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingKey, true);
    state = state.copyWith(isCompleted: true);
  }

  Future<void> skipOnboarding() => completeOnboarding();
}

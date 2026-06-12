import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePass = true;
  String _selectedRole = 'student';

  static const _roles = [
    ('student', 'Mahasiswa'),
    ('lecturer', 'Dosen'),
    ('org_admin', 'Organisasi'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_nameCtrl.text.trim().isEmpty) return 'Nama harus diisi.';
    if (_emailCtrl.text.trim().isEmpty) return 'Email harus diisi.';
    if (_passwordCtrl.text.length < 8) return 'Password minimal 8 karakter.';
    final passRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).+$');
    if (!passRegex.hasMatch(_passwordCtrl.text)) {
      return 'Password harus mengandung huruf dan angka.';
    }
    return null;
  }

  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppTheme.error),
      );
      return;
    }

    await ref.read(authProvider.notifier).register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          role: _selectedRole,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final errorMsg = authState is AuthError ? (authState).message : null;

    ref.listen(authProvider, (_, next) {
      if (next is AuthAuthenticated) context.go(AppRoutes.dashboard);
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Buat Akun'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Error banner
                  if (errorMsg != null) ...[
                    ErrorBanner(message: errorMsg),
                    const SizedBox(height: 16),
                  ],

                  // Name
                  AppTextField(
                    controller: _nameCtrl,
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap',
                    prefixIcon: const Icon(Icons.person_outline),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  AppTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'nama@kampus.ac.id',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  AppTextField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    hint: 'Min. 8 karakter, huruf + angka',
                    obscureText: _obscurePass,
                    prefixIcon: const Icon(Icons.lock_outline),
                    enabled: !isLoading,
                    textInputAction: TextInputAction.done,
                    onSubmitted: isLoading ? null : _submit,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.textSecond,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Role selector
                  Text(
                    'Daftar sebagai',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _roles.map((r) {
                      final selected = _selectedRole == r.$1;
                      return ChoiceChip(
                        label: Text(r.$2),
                        selected: selected,
                        onSelected: isLoading
                            ? null
                            : (_) => setState(() => _selectedRole = r.$1),
                        selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: selected
                              ? AppTheme.primary
                              : AppTheme.textPrimary,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: selected ? AppTheme.primary : AppTheme.divider,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Register button
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Daftar'),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun?'),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Masuk'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isLoading) const LoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

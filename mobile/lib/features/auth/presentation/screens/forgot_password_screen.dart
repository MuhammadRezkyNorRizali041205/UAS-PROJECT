import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;
  bool _obscurePass = true;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMsg = 'Email harus diisi.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    final ok =
        await ref.read(authProvider.notifier).forgotPassword(email);
    setState(() {
      _isLoading = false;
      if (ok) {
        _otpSent = true;
      } else {
        final state = ref.read(authProvider);
        _errorMsg = state is AuthError ? state.message : 'Gagal mengirim OTP.';
      }
    });
  }

  Future<void> _resetPassword() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _errorMsg = 'Password dan konfirmasi tidak cocok.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    final ok = await ref.read(authProvider.notifier).resetPassword(
          email: _emailCtrl.text.trim(),
          otp: _otpCtrl.text.trim(),
          password: _passCtrl.text,
          passwordConfirmation: _confirmCtrl.text,
        );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil direset! Silakan login.'),
          backgroundColor: AppTheme.success,
        ),
      );
      context.go('/login');
    } else {
      final state = ref.read(authProvider);
      setState(
        () => _errorMsg =
            state is AuthError ? state.message : 'Gagal reset password.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _otpSent
                  ? 'Masukkan kode OTP yang dikirim ke ${_emailCtrl.text}'
                  : 'Masukkan email terdaftar untuk mendapatkan kode OTP.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecond),
            ),
            const SizedBox(height: 24),

            if (_errorMsg != null) ...[
              ErrorBanner(message: _errorMsg!),
              const SizedBox(height: 16),
            ],

            // Email field (always shown)
            AppTextField(
              controller: _emailCtrl,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              enabled: !_isLoading && !_otpSent,
            ),

            if (!_otpSent) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kirim OTP'),
              ),
            ],

            if (_otpSent) ...[
              const SizedBox(height: 16),

              // OTP field
              AppTextField(
                controller: _otpCtrl,
                label: 'Kode OTP (6 digit)',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.pin_outlined),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // New password
              AppTextField(
                controller: _passCtrl,
                label: 'Password Baru',
                obscureText: _obscurePass,
                prefixIcon: const Icon(Icons.lock_outline),
                enabled: !_isLoading,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm password
              AppTextField(
                controller: _confirmCtrl,
                label: 'Konfirmasi Password',
                obscureText: _obscurePass,
                prefixIcon: const Icon(Icons.lock_outline),
                textInputAction: TextInputAction.done,
                onSubmitted: _isLoading ? null : _resetPassword,
                enabled: !_isLoading,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Reset Password'),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => setState(() {
                  _otpSent = false;
                  _errorMsg = null;
                }),
                child: const Text('Kirim ulang OTP'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

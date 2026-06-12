// lib/features/attendance/presentation/screens/qr_generator_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/attendance.dart';
import '../providers/attendance_provider.dart';

class QrGeneratorScreen extends ConsumerStatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  ConsumerState<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends ConsumerState<QrGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime _startsAt = DateTime.now();
  DateTime _endsAt = DateTime.now().add(const Duration(hours: 2));
  bool _loading = false;

  // countdown
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    _courseCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _startCountdown(DateTime endsAt) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final diff = endsAt.difference(DateTime.now());
      setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
      if (diff.isNegative) _timer?.cancel();
    });
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
  String _dtStr(DateTime d) =>
      '${d.year}-${_pad(d.month)}-${_pad(d.day)} ${_pad(d.hour)}:${_pad(d.minute)}:00';

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startsAt : _endsAt,
      firstDate: DateTime.now().subtract(const Duration(minutes: 5)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startsAt : _endsAt),
    );
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startsAt = dt;
        if (_endsAt.isBefore(dt)) _endsAt = dt.add(const Duration(hours: 1));
      } else {
        _endsAt = dt;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final err = await ref.read(createSessionProvider.notifier).create({
      'course_name': _courseCtrl.text.trim(),
      if (_locationCtrl.text.trim().isNotEmpty)
        'location': _locationCtrl.text.trim(),
      'starts_at': _dtStr(_startsAt),
      'ends_at': _dtStr(_endsAt),
    });

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(createSessionProvider);
    final session = sessionState.asData?.value;

    if (session != null) {
      _startCountdown(session.endsAt);
      return _QrDisplay(
        session: session,
        remaining: _remaining,
        onReset: () {
          _timer?.cancel();
          ref.read(createSessionProvider.notifier).reset();
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Buat Sesi Presensi')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _courseCtrl,
                label: 'Nama Mata Kuliah / Kegiatan',
                hint: 'mis. Pemrograman Bergerak',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _locationCtrl,
                label: 'Lokasi (opsional)',
                hint: 'mis. Ruang Lab Komputer 2',
              ),
              const SizedBox(height: 20),
              _DateTimeTile(
                label: 'Mulai',
                value: _dtStr(_startsAt),
                onTap: () => _pickDateTime(true),
              ),
              const SizedBox(height: 12),
              _DateTimeTile(
                label: 'Selesai',
                value: _dtStr(_endsAt),
                onTap: () => _pickDateTime(false),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            label: 'Buat Sesi & Tampilkan QR',
            onPressed: _submit,
            loading: _loading,
          ),
        ),
      ),
    );
  }
}

class _QrDisplay extends StatelessWidget {
  final AttendanceSessionEntity session;
  final Duration remaining;
  final VoidCallback onReset;
  const _QrDisplay(
      {required this.session,
      required this.remaining,
      required this.onReset});

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Color get _countdownColor {
    if (session.isExpired || remaining.inMinutes < 1) return AppColors.danger;
    if (remaining.inMinutes < 10) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('QR Presensi'),
          actions: [
            TextButton(
              onPressed: onReset,
              child: const Text('Buat Baru'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(session.courseName,
                  style: AppTextStyles.headingMedium,
                  textAlign: TextAlign.center),
              if (session.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(session.location!, style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // QR Code
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: QrImageView(
                  data: session.sessionCode,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Countdown
              if (!session.isExpired) ...[
                Text('Sesi berakhir dalam',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 6),
                Text(
                  _fmt(remaining),
                  style: AppTextStyles.displayMedium
                      .copyWith(color: _countdownColor),
                ),
              ] else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Sesi telah berakhir',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.danger)),
                ),

              const SizedBox(height: 20),

              // Attendee count
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_outline_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${session.attendeeCount ?? 0} peserta hadir',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _DateTimeTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateTimeTile(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.labelSmall),
                  Text(value,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        ),
      );
}

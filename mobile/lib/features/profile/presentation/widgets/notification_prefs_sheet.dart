// path: lib/features/profile/presentation/widgets/notification_prefs_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/profile.dart';
import '../providers/profile_provider.dart';
import '../../../../shared/theme/app_colors.dart';

class NotificationPrefsSheet extends ConsumerStatefulWidget {
  final NotificationPrefs prefs;

  const NotificationPrefsSheet({
    super.key,
    required this.prefs,
  });

  @override
  ConsumerState<NotificationPrefsSheet> createState() =>
      _NotificationPrefsSheetState();
}

class _NotificationPrefsSheetState
    extends ConsumerState<NotificationPrefsSheet> {
  late bool _schedule;
  late bool _task;
  late bool _announcement;
  late bool _attendance;
  String? _savingKey;

  @override
  void initState() {
    super.initState();
    _schedule = widget.prefs.schedule;
    _task = widget.prefs.task;
    _announcement = widget.prefs.announcement;
    _attendance = widget.prefs.attendance;
  }

  Future<void> _save(String key, bool value) async {
    setState(() => _savingKey = key);

    final prefs = {
      'schedule': _schedule,
      'task': _task,
      'announcement': _announcement,
      'attendance': _attendance,
    };

    final err =
        await ref.read(profileProvider.notifier).updateNotificationPrefs(prefs);

    if (!mounted) return;
    setState(() => _savingKey = null);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tersimpan'),
        backgroundColor: AppColors.success,
        duration: Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Pengaturan Notifikasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _tile(
              keyName: 'schedule',
              icon: Icons.calendar_month_rounded,
              title: 'Jadwal Kuliah',
              subtitle: 'Reminder H-1, H-3 jam, H-30 menit',
              value: _schedule,
              onChanged: (v) async {
                setState(() => _schedule = v);
                await _save('schedule', v);
              },
            ),
            _tile(
              keyName: 'task',
              icon: Icons.check_circle_outline_rounded,
              title: 'Deadline Tugas',
              subtitle: 'Pengingat mendekati batas waktu',
              value: _task,
              onChanged: (v) async {
                setState(() => _task = v);
                await _save('task', v);
              },
            ),
            _tile(
              keyName: 'announcement',
              icon: Icons.campaign_rounded,
              title: 'Pengumuman',
              subtitle: 'Notifikasi pengumuman baru',
              value: _announcement,
              onChanged: (v) async {
                setState(() => _announcement = v);
                await _save('announcement', v);
              },
            ),
            _tile(
              keyName: 'attendance',
              icon: Icons.pin_drop_rounded,
              title: 'Presensi',
              subtitle: 'Pengingat presensi kelas',
              value: _attendance,
              onChanged: (v) async {
                setState(() => _attendance = v);
                await _save('attendance', v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required String keyName,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: _savingKey != null ? null : onChanged,
      activeColor: AppColors.primary,
      title: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(title),
          if (_savingKey == keyName) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }
}

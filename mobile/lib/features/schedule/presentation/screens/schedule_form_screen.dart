// lib/features/schedule/presentation/screens/schedule_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../providers/schedule_provider.dart';

class ScheduleFormScreen extends ConsumerStatefulWidget {
  final String? id; // null = create, non-null = edit
  const ScheduleFormScreen({super.key, this.id});

  @override
  ConsumerState<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends ConsumerState<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEdit = false;
  bool _loading = false;
  bool _prefilling = false;

  final _titleCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  final _lecturerCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _category = 'lecture';
  int _dayOfWeek = 1;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _recurrence = 'weekly';
  bool _isActive = true;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  static const _categories = [
    ('lecture', 'Kuliah'),
    ('practicum', 'Praktikum'),
    ('seminar', 'Seminar'),
    ('organization', 'Organisasi'),
    ('task', 'Tugas'),
    ('exam', 'Ujian'),
    ('custom', 'Lainnya'),
  ];

  static const _days = [
    (0, 'Min'),
    (1, 'Sen'),
    (2, 'Sel'),
    (3, 'Rab'),
    (4, 'Kam'),
    (5, 'Jum'),
    (6, 'Sab'),
  ];

  static const _recurrences = [
    ('once', 'Sekali'),
    ('weekly', 'Setiap Minggu'),
    ('biweekly', '2 Minggu Sekali'),
  ];

  @override
  void initState() {
    super.initState();
    _isEdit = widget.id != null;
    if (_isEdit) _prefill();
  }

  Future<void> _prefill() async {
    setState(() => _prefilling = true);
    final id = int.tryParse(widget.id!);
    if (id == null) {
      setState(() => _prefilling = false);
      return;
    }

    try {
      final schedule = await ref.read(scheduleByIdProvider(id).future);
      if (!mounted) return;

      _titleCtrl.text = schedule.title;
      _roomCtrl.text = schedule.room ?? '';
      _lecturerCtrl.text = schedule.lecturer ?? '';
      _notesCtrl.text = schedule.notes ?? '';

      final sp = schedule.startTime.split(':');
      final ep = schedule.endTime.split(':');

      setState(() {
        _category = schedule.category;
        _dayOfWeek = schedule.dayOfWeek;
        _startTime =
            TimeOfDay(hour: int.parse(sp[0]), minute: int.parse(sp[1]));
        _endTime =
            TimeOfDay(hour: int.parse(ep[0]), minute: int.parse(ep[1]));
        _recurrence = schedule.recurrence;
        _isActive = schedule.isActive;
        _startDate = schedule.startDate;
        _endDate = schedule.endDate;
        _prefilling = false;
      });
    } catch (_) {
      if (mounted) setState(() => _prefilling = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _roomCtrl.dispose();
    _lecturerCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
  String _timeStr(TimeOfDay t) => '${_pad(t.hour)}:${_pad(t.minute)}';
  String _dateStr(DateTime d) =>
      '${d.year}-${_pad(d.month)}-${_pad(d.day)}';

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
        final startMin = picked.hour * 60 + picked.minute;
        final endMin = _endTime.hour * 60 + _endTime.minute;
        if (endMin <= startMin) {
          final newEnd = startMin + 60;
          _endTime =
              TimeOfDay(hour: newEnd ~/ 60 % 24, minute: newEnd % 60);
        }
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? _startDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'category': _category,
      'day_of_week': _dayOfWeek,
      'start_time': _timeStr(_startTime),
      'end_time': _timeStr(_endTime),
      'recurrence': _recurrence,
      'start_date': _dateStr(_startDate),
      'is_active': _isActive,
      if (_endDate != null) 'end_date': _dateStr(_endDate!),
      if (_roomCtrl.text.trim().isNotEmpty) 'room': _roomCtrl.text.trim(),
      if (_lecturerCtrl.text.trim().isNotEmpty)
        'lecturer': _lecturerCtrl.text.trim(),
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
    };

    String? err;
    if (_isEdit) {
      err = await ref
          .read(scheduleListProvider.notifier)
          .updateSchedule(int.parse(widget.id!), data);
    } else {
      err = await ref
          .read(scheduleListProvider.notifier)
          .createSchedule(data);
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.danger),
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_prefilling) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
            title: Text(_isEdit ? 'Edit Jadwal' : 'Tambah Jadwal')),
        body: const Padding(
            padding: EdgeInsets.all(16), child: SkeletonList(count: 6)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:
          AppBar(title: Text(_isEdit ? 'Edit Jadwal' : 'Tambah Jadwal')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _titleCtrl,
                label: 'Judul Jadwal',
                hint: 'mis. Pemrograman Bergerak',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Judul wajib diisi'
                    : null,
              ),
              const SizedBox(height: 20),

              const _SectionLabel('Kategori'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  final selected = _category == c.$1;
                  final color = AppColors.categoryColor(c.$1);
                  return GestureDetector(
                    onTap: () => setState(() => _category = c.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withValues(alpha: 0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? color : AppColors.border,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        c.$2,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: selected
                              ? color
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              const _SectionLabel('Hari'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _days.map((d) {
                  final selected = _dayOfWeek == d.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _dayOfWeek = d.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        d.$2,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              const _SectionLabel('Waktu'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _TimeTile(
                      label: 'Mulai',
                      time: _timeStr(_startTime),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeTile(
                      label: 'Selesai',
                      time: _timeStr(_endTime),
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const _SectionLabel('Pengulangan'),
              const SizedBox(height: 8),
              ..._recurrences.map((r) => GestureDetector(
                    onTap: () => setState(() => _recurrence = r.$1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _recurrence == r.$1
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: _recurrence == r.$1 ? 5 : 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(r.$2, style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 12),

              const _SectionLabel('Tanggal Mulai'),
              const SizedBox(height: 8),
              _DateTile(
                label: _dateStr(_startDate),
                onTap: () => _pickDate(true),
              ),
              const SizedBox(height: 12),
              const _SectionLabel('Tanggal Selesai (opsional)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DateTile(
                      label: _endDate != null
                          ? _dateStr(_endDate!)
                          : 'Tidak ditentukan',
                      onTap: () => _pickDate(false),
                      muted: _endDate == null,
                    ),
                  ),
                  if (_endDate != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.clear_rounded,
                          color: AppColors.textMuted),
                      onPressed: () => setState(() => _endDate = null),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              AppTextField(
                controller: _roomCtrl,
                label: 'Ruangan (opsional)',
                hint: 'mis. Lab Komputer 1',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _lecturerCtrl,
                label: 'Dosen / Pembimbing (opsional)',
                hint: 'mis. Dr. Budi Santoso',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _notesCtrl,
                label: 'Catatan (opsional)',
                hint: 'Tambahkan catatan tambahan...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: SwitchListTile(
                  title: Text('Jadwal Aktif',
                      style: AppTextStyles.bodyMedium),
                  value: _isActive,
                  activeTrackColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            label: _isEdit ? 'Simpan Perubahan' : 'Tambah Jadwal',
            onPressed: _submit,
            loading: _loading,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.labelMedium);
}

class _TimeTile extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;
  const _TimeTile(
      {required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.labelSmall),
                  Text(time,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        ),
      );
}

class _DateTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool muted;
  const _DateTile(
      {required this.label, required this.onTap, this.muted = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: muted
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
}

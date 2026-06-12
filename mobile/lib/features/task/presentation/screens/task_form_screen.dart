// lib/features/task/presentation/screens/task_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../providers/task_provider.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final String? id; // null = create, non-null = edit
  const TaskFormScreen({super.key, this.id});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEdit = false;
  bool _loading = false;
  bool _prefilling = false;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _priority = 'medium';
  String _status = 'pending';
  DateTime? _deadline;

  static const _priorities = [
    ('low', 'Rendah'),
    ('medium', 'Sedang'),
    ('high', 'Tinggi'),
    ('critical', 'Kritis'),
  ];

  static const _statuses = [
    ('pending', 'Belum Mulai'),
    ('in_progress', 'Dikerjakan'),
    ('completed', 'Selesai'),
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
      final task = await ref.read(taskByIdProvider(id).future);
      if (!mounted) return;
      _titleCtrl.text = task.title;
      _descCtrl.text = task.description ?? '';
      setState(() {
        _priority = task.priority;
        _status = task.status == 'overdue' ? 'in_progress' : task.status;
        _deadline = task.deadline;
        _prefilling = false;
      });
    } catch (_) {
      if (mounted) setState(() => _prefilling = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
  String _dateTimeStr(DateTime d) =>
      '${d.year}-${_pad(d.month)}-${_pad(d.day)} ${_pad(d.hour)}:${_pad(d.minute)}:00';

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _deadline != null
          ? TimeOfDay.fromDateTime(_deadline!)
          : const TimeOfDay(hour: 23, minute: 59),
    );
    if (time == null || !mounted) return;

    setState(() {
      _deadline = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'priority': _priority,
      'status': _status,
      if (_descCtrl.text.trim().isNotEmpty)
        'description': _descCtrl.text.trim(),
      if (_deadline != null) 'deadline': _dateTimeStr(_deadline!),
    };

    String? err;
    if (_isEdit) {
      err = await ref
          .read(taskListProvider.notifier)
          .updateTask(int.parse(widget.id!), data);
    } else {
      err = await ref.read(taskListProvider.notifier).createTask(data);
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
            title: Text(_isEdit ? 'Edit Tugas' : 'Tambah Tugas')),
        body: const Padding(
            padding: EdgeInsets.all(16), child: SkeletonList(count: 5)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:
          AppBar(title: Text(_isEdit ? 'Edit Tugas' : 'Tambah Tugas')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _titleCtrl,
                label: 'Judul Tugas',
                hint: 'mis. Laporan Praktikum Jaringan',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Judul wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descCtrl,
                label: 'Deskripsi (opsional)',
                hint: 'Detail tambahan tentang tugas ini...',
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Priority
              const _SectionLabel('Prioritas'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _priorities.map((p) {
                  final selected = _priority == p.$1;
                  final color = AppColors.priorityColor(p.$1);
                  return GestureDetector(
                    onTap: () => setState(() => _priority = p.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                        p.$2,
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

              // Status
              const _SectionLabel('Status'),
              const SizedBox(height: 8),
              ..._statuses.map((s) => GestureDetector(
                    onTap: () => setState(() => _status = s.$1),
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
                                color: _status == s.$1
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: _status == s.$1 ? 5 : 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(s.$2, style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 20),

              // Deadline
              const _SectionLabel('Deadline (opsional)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDeadline,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_rounded,
                                size: 18,
                                color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            Text(
                              _deadline != null
                                  ? _formatDeadline(_deadline!)
                                  : 'Pilih tanggal & waktu',
                              style:
                                  AppTextStyles.bodyMedium.copyWith(
                                color: _deadline != null
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_deadline != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.clear_rounded,
                          color: AppColors.textMuted),
                      onPressed: () =>
                          setState(() => _deadline = null),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            label: _isEdit ? 'Simpan Perubahan' : 'Tambah Tugas',
            onPressed: _submit,
            loading: _loading,
          ),
        ),
      ),
    );
  }

  String _formatDeadline(DateTime d) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${months[d.month]} ${d.year}, ${_pad(d.hour)}:${_pad(d.minute)}';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.labelMedium);
}

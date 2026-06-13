// lib/features/organization/presentation/screens/org_event_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import 'org_dashboard_screen.dart';

class OrgEventFormScreen extends ConsumerStatefulWidget {
  const OrgEventFormScreen({super.key});

  @override
  ConsumerState<OrgEventFormScreen> createState() => _State();
}

class _State extends ConsumerState<OrgEventFormScreen> {
  final _titleCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _maxCtrl      = TextEditingController();
  DateTime? _eventDate, _endDate, _regDeadline;
  bool _publishNow = false;
  bool _saving     = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Buat Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(_titleCtrl, 'Judul Event *'),
            const SizedBox(height: 12),
            _field(_descCtrl, 'Deskripsi *', maxLines: 4),
            const SizedBox(height: 12),
            _field(_locationCtrl, 'Lokasi'),
            const SizedBox(height: 12),
            _field(_maxCtrl, 'Maks Peserta', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _datePicker('Tanggal Mulai *', _eventDate, (d) => setState(() => _eventDate = d)),
            const SizedBox(height: 8),
            _datePicker('Tanggal Selesai', _endDate,   (d) => setState(() => _endDate = d)),
            const SizedBox(height: 8),
            _datePicker('Deadline Registrasi', _regDeadline, (d) => setState(() => _regDeadline = d)),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _publishNow,
              onChanged: (v) => setState(() => _publishNow = v),
              title: const Text('Publish Langsung', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: const Text('Event akan langsung terlihat publik', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_publishNow ? 'Buat & Publish' : 'Simpan Draft'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty || _eventDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Judul, deskripsi, dan tanggal mulai wajib diisi')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(orgRepositoryProvider).createEvent({
        'title':                 _titleCtrl.text.trim(),
        'description':           _descCtrl.text.trim(),
        'event_date':            _eventDate!.toIso8601String(),
        if (_endDate != null)     'end_date': _endDate!.toIso8601String(),
        if (_locationCtrl.text.isNotEmpty) 'location': _locationCtrl.text.trim(),
        if (_maxCtrl.text.isNotEmpty)      'max_participants': int.tryParse(_maxCtrl.text),
        if (_regDeadline != null) 'registration_deadline': _regDeadline!.toIso8601String(),
        'status': _publishNow ? 'published' : 'draft',
      });
      ref.invalidate(orgEventsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event berhasil dibuat')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(TextEditingController ctrl, String label, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
      ),
    );
  }

  Widget _datePicker(String label, DateTime? value, ValueChanged<DateTime> onPicked) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 730)),
        );
        if (d != null) onPicked(d);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Text(
              value == null ? label : '$label: ${value.day}/${value.month}/${value.year}',
              style: TextStyle(color: value == null ? AppColors.textMuted : AppColors.textPrimary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

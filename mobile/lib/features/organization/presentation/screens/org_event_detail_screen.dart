// lib/features/organization/presentation/screens/org_event_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/theme/app_colors.dart';
import 'org_dashboard_screen.dart';

part 'org_event_detail_screen.g.dart';

@riverpod
Future<Map<String, dynamic>> orgEventDetail(Ref ref, String eventId) =>
    ref.read(orgRepositoryProvider).getEventDetail(eventId);

@riverpod
Future<List<dynamic>> orgEventRegistrations(Ref ref, String eventId) =>
    ref.read(orgRepositoryProvider).getEventRegistrations(eventId);

class OrgEventDetailScreen extends ConsumerWidget {
  const OrgEventDetailScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(orgEventDetailProvider(eventId));
    final regsAsync  = ref.watch(orgEventRegistrationsProvider(eventId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Detail Event'),
        actions: [
          eventAsync.when(
            data: (e) => PopupMenuButton<String>(
              color: AppColors.surfaceElevated,
              icon: const Icon(Icons.more_vert),
              onSelected: (action) => _handleAction(context, ref, action, e),
              itemBuilder: (_) {
                final status = e['status'] as String? ?? '';
                return [
                  if (status == 'draft')
                    const PopupMenuItem(
                        value: 'publish',
                        child: Text('Publikasikan',
                            style: TextStyle(color: AppColors.textPrimary))),
                  if (status != 'cancelled' && status != 'completed')
                    const PopupMenuItem(
                        value: 'cancel',
                        child: Text('Batalkan Event',
                            style: TextStyle(color: AppColors.danger))),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text('Hapus',
                          style: TextStyle(color: AppColors.danger))),
                ];
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
        data: (event) {
          final eventDate   = DateTime.tryParse(event['event_date'] as String? ?? '');
          final endDate     = DateTime.tryParse(event['end_date'] as String? ?? '');
          final regDeadline =
              DateTime.tryParse(event['registration_deadline'] as String? ?? '');
          final status  = event['status'] as String? ?? 'draft';
          final maxPart = event['max_participants'] as int?;
          final regCount = event['registration_count'] as int? ?? 0;

          final statusColor = switch (status) {
            'published' => AppColors.success,
            'ongoing'   => AppColors.primary,
            'completed' => AppColors.textMuted,
            'cancelled' => AppColors.danger,
            _           => AppColors.warning,
          };

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(orgEventDetailProvider(eventId));
              ref.invalidate(orgEventRegistrationsProvider(eventId));
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event['title'] as String? ?? '',
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (eventDate != null)
                          _InfoRow(Icons.calendar_today_outlined, 'Tanggal Mulai',
                              '${eventDate.day}/${eventDate.month}/${eventDate.year} ${_timeStr(eventDate)}'),
                        if (endDate != null)
                          _InfoRow(Icons.calendar_month_outlined, 'Tanggal Selesai',
                              '${endDate.day}/${endDate.month}/${endDate.year} ${_timeStr(endDate)}'),
                        if (regDeadline != null)
                          _InfoRow(Icons.timer_outlined, 'Deadline Registrasi',
                              '${regDeadline.day}/${regDeadline.month}/${regDeadline.year}'),
                        if (event['location'] != null)
                          _InfoRow(Icons.location_on_outlined, 'Lokasi',
                              event['location'] as String),
                        _InfoRow(
                          Icons.people_outline_rounded,
                          'Peserta',
                          maxPart != null
                              ? '$regCount / $maxPart'
                              : '$regCount pendaftar',
                        ),
                        const SizedBox(height: 16),
                        const Text('Deskripsi',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(height: 6),
                        Text(
                          event['description'] as String? ?? '',
                          style: const TextStyle(
                              color: AppColors.textSecondary, height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        const Text('Daftar Pendaftar',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
                regsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Center(
                        child: Text('$e',
                            style: const TextStyle(color: AppColors.danger))),
                  ),
                  data: (regs) {
                    if (regs.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('Belum ada pendaftar',
                                style: TextStyle(color: AppColors.textMuted)),
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      sliver: SliverList.separated(
                        itemCount: regs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (_, i) => _RegCard(reg: regs[i]),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _timeStr(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _handleAction(BuildContext context, WidgetRef ref,
      String action, Map<String, dynamic> event) async {
    final repo = ref.read(orgRepositoryProvider);
    try {
      switch (action) {
        case 'publish':
          await repo.publishEvent(event['id'] as String);
          ref.invalidate(orgEventDetailProvider(eventId));
          ref.invalidate(orgEventsProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Event dipublikasikan')));
          }
        case 'cancel':
          await repo.updateEvent(event['id'] as String, {'status': 'cancelled'});
          ref.invalidate(orgEventDetailProvider(eventId));
          ref.invalidate(orgEventsProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Event dibatalkan')));
          }
        case 'delete':
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Hapus Event',
                  style: TextStyle(color: AppColors.textPrimary)),
              content: const Text('Yakin ingin menghapus event ini?',
                  style: TextStyle(color: AppColors.textSecondary)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger),
                  child: const Text('Hapus'),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await repo.deleteEvent(event['id'] as String);
            ref.invalidate(orgEventsProvider);
            if (context.mounted) context.pop();
          }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13))),
        ],
      ),
    );
  }
}

class _RegCard extends StatelessWidget {
  const _RegCard({required this.reg});
  final dynamic reg;

  @override
  Widget build(BuildContext context) {
    final status = reg['status'] as String? ?? 'registered';
    final statusColor = switch (status) {
      'confirmed' => AppColors.success,
      'cancelled' => AppColors.danger,
      _           => AppColors.primary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              (reg['name'] as String? ?? '?').substring(0, 1).toUpperCase(),
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reg['name'] as String? ?? '-',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                Text(reg['nim'] as String? ?? '',
                    style:
                        const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

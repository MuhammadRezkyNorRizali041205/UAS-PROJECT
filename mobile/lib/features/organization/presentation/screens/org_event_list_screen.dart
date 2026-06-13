// lib/features/organization/presentation/screens/org_event_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import 'org_dashboard_screen.dart';

class OrgEventListScreen extends ConsumerStatefulWidget {
  const OrgEventListScreen({super.key});

  @override
  ConsumerState<OrgEventListScreen> createState() => _State();
}

class _State extends ConsumerState<OrgEventListScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  static const _statuses = ['', 'published', 'ongoing', 'completed', 'draft'];
  static const _labels   = ['Semua', 'Akan Datang', 'Berlangsung', 'Selesai', 'Draft'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Event Organisasi'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/org/events/create'),
        icon: const Icon(Icons.add),
        label: const Text('Buat Event'),
      ),
      body: TabBarView(
        controller: _tab,
        children: _statuses.map((status) => _EventTab(status: status)).toList(),
      ),
    );
  }
}

class _EventTab extends ConsumerWidget {
  const _EventTab({required this.status});
  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(orgEventsProvider);
    return events.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
      data: (list) {
        final filtered = status.isEmpty ? list : list.where((e) => e['status'] == status).toList();
        if (filtered.isEmpty) {
          return const Center(child: Text('Tidak ada event', style: TextStyle(color: AppColors.textMuted)));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(orgEventsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _EventTile(event: filtered[i], onAction: () => ref.invalidate(orgEventsProvider)),
          ),
        );
      },
    );
  }
}

class _EventTile extends ConsumerWidget {
  const _EventTile({required this.event, required this.onAction});
  final dynamic event;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventDate = DateTime.tryParse(event['event_date'] ?? '');
    final status    = event['status'] as String? ?? 'draft';
    final regCount  = event['registration_count'] as int? ?? 0;

    final statusColor = switch (status) {
      'published' => AppColors.success,
      'ongoing'   => AppColors.primary,
      'completed' => AppColors.textMuted,
      'cancelled' => AppColors.danger,
      _           => AppColors.warning,
    };

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(event['title'] ?? '', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (eventDate != null)
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('${eventDate.day}/${eventDate.month}/${eventDate.year}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ]),
            if (event['location'] != null) ...[
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(event['location'], style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ]),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text('$regCount pendaftar', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const Spacer(),
                if (status == 'draft')
                  TextButton(
                    onPressed: () async {
                      await ref.read(orgRepositoryProvider).publishEvent(event['id']);
                      onAction();
                    },
                    child: const Text('Publikasikan'),
                  ),
                TextButton(
                  onPressed: () => context.push('/org/events/${event['id']}'),
                  child: const Text('Detail'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

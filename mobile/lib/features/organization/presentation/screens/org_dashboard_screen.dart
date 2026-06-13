// lib/features/organization/presentation/screens/org_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../data/org_repository.dart';

part 'org_dashboard_screen.g.dart';

@riverpod
OrgRepository orgRepository(Ref ref) => OrgRepository(ref.read(dioClientProvider));

@riverpod
Future<Map<String, dynamic>> orgDashboard(Ref ref) =>
    ref.read(orgRepositoryProvider).getDashboard();

@riverpod
Future<List<dynamic>> orgEvents(Ref ref) =>
    ref.read(orgRepositoryProvider).getEvents();

@riverpod
Future<List<dynamic>> orgMembers(Ref ref) =>
    ref.read(orgRepositoryProvider).getMembers();

class OrgDashboardScreen extends ConsumerWidget {
  const OrgDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(orgDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(orgDashboardProvider);
            ref.invalidate(orgEventsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              dashboard.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('$e', style: const TextStyle(color: AppColors.danger)),
                data: (d) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, d['organization'] as Map<String, dynamic>? ?? {}),
                    const SizedBox(height: 20),
                    _buildStats(d['stats'] as Map<String, dynamic>? ?? {}),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionHeader('Event Mendatang', onMore: () => context.go('/org/events')),
              const SizedBox(height: 12),
              dashboard.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (d) {
                  final events = (d['upcoming_events'] as List?) ?? [];
                  if (events.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('Tidak ada event mendatang', style: TextStyle(color: AppColors.textMuted)));
                  return SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: events.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _EventCard(event: events[i]),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildSectionHeader('Anggota Aktif', onMore: () => context.go('/org/members')),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) {
                  final members = ref.watch(orgMembersProvider);
                  return members.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('$e', style: const TextStyle(color: AppColors.danger)),
                    data: (list) {
                      final top = list.take(5).toList();
                      return Row(
                        children: [
                          ...top.map((m) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                              backgroundColor: AppColors.roleOrganization.withValues(alpha: 0.2),
                              child: Text(
                                (m['name'] as String? ?? '?').substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: AppColors.roleOrganization),
                              ),
                            ),
                          )),
                          if (list.length > 5)
                            Text('+${list.length - 5} lainnya', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> org) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.roleOrganization.withValues(alpha: 0.2),
          child: const Icon(Icons.account_balance_rounded, color: AppColors.roleOrganization, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(org['name'] ?? 'Organisasi',
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.roleOrganization.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text((org['category'] as String? ?? '').toUpperCase(),
                        style: const TextStyle(color: AppColors.roleOrganization, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  if (org['is_verified'] == true) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded, color: AppColors.primary, size: 16),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard('Total Anggota',    '${stats['total_members'] ?? 0}',       Icons.people_rounded,        AppColors.primary),
        _StatCard('Event Aktif',      '${stats['active_events'] ?? 0}',       Icons.event_rounded,         AppColors.success),
        _StatCard('Akan Datang',      '${stats['upcoming_events'] ?? 0}',     Icons.upcoming_rounded,      AppColors.info),
        _StatCard('Pendaftar',        '${stats['total_registrations'] ?? 0}', Icons.person_add_rounded,    AppColors.warning),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onMore}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        if (onMore != null)
          TextButton(onPressed: onMore, child: const Text('Lihat Semua', style: TextStyle(fontSize: 12))),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.icon, this.color);
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});
  final dynamic event;

  @override
  Widget build(BuildContext context) {
    final eventDate = DateTime.tryParse(event['event_date'] ?? '');
    final regCount  = event['registration_count'] as int? ?? 0;

    return GestureDetector(
      onTap: () => context.push('/org/events/${event['id']}'),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A5F), Color(0xFF0F2040)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: const Text('Published', style: TextStyle(color: AppColors.success, fontSize: 10)),
            ),
            const Spacer(),
            Text(event['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            if (eventDate != null)
              Text('${eventDate.day}/${eventDate.month}/${eventDate.year}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
            Text('$regCount pendaftar', style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

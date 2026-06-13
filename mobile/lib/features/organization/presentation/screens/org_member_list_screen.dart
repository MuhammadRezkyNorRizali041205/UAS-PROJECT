// lib/features/organization/presentation/screens/org_member_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import 'org_dashboard_screen.dart';

class OrgMemberListScreen extends ConsumerWidget {
  const OrgMemberListScreen({super.key});

  static const _roles = ['leader', 'vice_leader', 'secretary', 'treasurer', 'member'];
  static const _roleLabels = {
    'leader':      'Ketua',
    'vice_leader': 'Wakil Ketua',
    'secretary':   'Sekretaris',
    'treasurer':   'Bendahara',
    'member':      'Anggota',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(orgMembersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Anggota Organisasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => _showAddMemberDialog(context, ref),
          ),
        ],
      ),
      body: members.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
        data: (list) => list.isEmpty
            ? const Center(child: Text('Belum ada anggota', style: TextStyle(color: AppColors.textMuted)))
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(orgMembersProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _MemberCard(
                    member: list[i],
                    roleLabels: _roleLabels,
                    roles: _roles,
                    onChanged: () => ref.invalidate(orgMembersProvider),
                    ref: ref,
                  ),
                ),
              ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    String selectedRole = 'member';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Undang Anggota', style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Email atau NIM',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                ),
                items: _roles.map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(_roleLabels[r] ?? r, style: const TextStyle(color: AppColors.textPrimary)),
                )).toList(),
                onChanged: (v) => setState(() => selectedRole = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (ctrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                try {
                  await ref.read(orgRepositoryProvider).addMember(ctrl.text.trim(), selectedRole);
                  ref.invalidate(orgMembersProvider);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anggota berhasil ditambahkan')));
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                }
              },
              child: const Text('Undang'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.roleLabels, required this.roles, required this.onChanged, required this.ref});
  final dynamic member;
  final Map<String, String> roleLabels;
  final List<String> roles;
  final VoidCallback onChanged;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final role  = member['role'] as String? ?? 'member';
    final label = roleLabels[role] ?? role;

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.roleOrganization.withValues(alpha: 0.15),
          child: Text(
            (member['name'] as String? ?? '?').substring(0, 1).toUpperCase(),
            style: const TextStyle(color: AppColors.roleOrganization, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(member['name'] ?? '', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text('${member['nim'] ?? '-'} • $label', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        trailing: PopupMenuButton<String>(
          color: AppColors.surfaceElevated,
          icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
          onSelected: (action) async {
            if (action == 'remove') {
              await ref.read(orgRepositoryProvider).removeMember(member['id']);
              onChanged();
            } else {
              await ref.read(orgRepositoryProvider).updateMemberRole(member['id'], action);
              onChanged();
            }
          },
          itemBuilder: (_) => [
            ...roles.where((r) => r != role).map((r) => PopupMenuItem(
              value: r,
              child: Text('Jadikan ${roleLabels[r]}', style: const TextStyle(color: AppColors.textPrimary)),
            )),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'remove',
              child: Text('Nonaktifkan', style: TextStyle(color: AppColors.danger)),
            ),
          ],
        ),
      ),
    );
  }
}

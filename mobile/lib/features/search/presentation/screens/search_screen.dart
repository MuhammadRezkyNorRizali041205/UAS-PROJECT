// lib/features/search/presentation/screens/search_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../search/data/search_repository.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

const _kRecentKey = 'recent_searches';
const _kMaxRecent = 5;

Future<List<String>> _loadRecent() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(_kRecentKey) ?? [];
}

Future<void> _saveRecent(String q) async {
  final prefs = await SharedPreferences.getInstance();
  final list  = prefs.getStringList(_kRecentKey) ?? [];
  list.remove(q);
  list.insert(0, q);
  if (list.length > _kMaxRecent) list.removeLast();
  await prefs.setStringList(_kRecentKey, list);
}

Future<void> _deleteRecent(String q) async {
  final prefs = await SharedPreferences.getInstance();
  final list  = prefs.getStringList(_kRecentKey) ?? [];
  list.remove(q);
  await prefs.setStringList(_kRecentKey, list);
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl   = TextEditingController();
  final _focus  = FocusNode();
  Timer? _debounce;

  String _type    = 'all';
  bool   _loading = false;
  String? _error;
  Map<String, dynamic>? _results;
  int _total = 0;

  List<String> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadRecent().then((list) {
      if (mounted) setState(() => _recent = list);
    });
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    if (q.trim().length < 2) {
      setState(() { _results = null; _error = null; _loading = false; });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 400), () => _doSearch(q.trim()));
  }

  Future<void> _doSearch(String q) async {
    setState(() { _loading = true; _error = null; });
    try {
      final repo    = SearchRepository(ref.read(dioClientProvider));
      final data    = await repo.search(q, type: _type);
      final results = data['results'] as Map<String, dynamic>? ?? {};
      final total   = data['total'] as int? ?? 0;
      await _saveRecent(q);
      if (mounted) {
        setState(() {
          _results = results;
          _total   = total;
          _loading = false;
        });
        _loadRecent().then((list) {
          if (mounted) setState(() => _recent = list);
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = '$e'; _loading = false; });
    }
  }

  void _selectRecent(String q) {
    _ctrl.text = q;
    _ctrl.selection = TextSelection.collapsed(offset: q.length);
    _onChanged(q);
  }

  void _setType(String t) {
    setState(() => _type = t);
    if (_ctrl.text.trim().length >= 2) _doSearch(_ctrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _ctrl,
          focusNode:  _focus,
          onChanged:  _onChanged,
          onSubmitted: (q) { if (q.trim().length >= 2) _doSearch(q.trim()); },
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText:  'Cari jadwal, tugas, pengumuman...',
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            border: InputBorder.none,
            suffixIcon: _ctrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 18),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() { _results = null; _error = null; _loading = false; });
                    },
                  )
                : null,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter chips ──────────────────────────────────────────────────
          _FilterChips(selected: _type, onSelect: _setType),

          // ── Body ──────────────────────────────────────────────────────────
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _ErrorView(message: _error!, onRetry: () => _doSearch(_ctrl.text.trim()));
    }
    if (_results == null) {
      return _RecentSearches(
        recent: _recent,
        onSelect: _selectRecent,
        onDelete: (q) async {
          await _deleteRecent(q);
          final list = await _loadRecent();
          if (mounted) setState(() => _recent = list);
        },
      );
    }
    if (_total == 0) {
      return const _EmptyResults();
    }
    return _ResultsView(results: _results!);
  }
}

// ─── Filter Chips ─────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelect});
  final String selected;
  final void Function(String) onSelect;

  static const _filters = [
    ('all',          'Semua'),
    ('schedule',     'Jadwal'),
    ('task',         'Tugas'),
    ('announcement', 'Pengumuman'),
    ('user',         'Pengguna'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: _filters.map((f) {
          final isActive = selected == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(f.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  f.$2,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Recent Searches ──────────────────────────────────────────────────────────

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({
    required this.recent,
    required this.onSelect,
    required this.onDelete,
  });
  final List<String> recent;
  final void Function(String) onSelect;
  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    if (recent.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 64, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text('Cari apa yang kamu butuhkan',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
            SizedBox(height: 4),
            Text('Minimal 2 karakter untuk memulai pencarian',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Pencarian Terakhir',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...recent.map((q) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.history_rounded, color: AppColors.textMuted, size: 20),
          title: Text(q, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          trailing: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
            onPressed: () => onDelete(q),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          onTap: () => onSelect(q),
        )),
      ],
    );
  }
}

// ─── Results View ─────────────────────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  const _ResultsView({required this.results});
  final Map<String, dynamic> results;

  @override
  Widget build(BuildContext context) {
    final schedules     = (results['schedules']     as List?) ?? [];
    final tasks         = (results['tasks']         as List?) ?? [];
    final users         = (results['users']         as List?) ?? [];
    final announcements = (results['announcements'] as List?) ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (schedules.isNotEmpty) ...[
          _GroupHeader(icon: Icons.calendar_today_rounded, label: 'Jadwal', count: schedules.length),
          ...schedules.map((s) => _ScheduleResultTile(item: s)),
          const SizedBox(height: 12),
        ],
        if (tasks.isNotEmpty) ...[
          _GroupHeader(icon: Icons.task_alt_rounded, label: 'Tugas', count: tasks.length),
          ...tasks.map((t) => _TaskResultTile(item: t)),
          const SizedBox(height: 12),
        ],
        if (announcements.isNotEmpty) ...[
          _GroupHeader(icon: Icons.campaign_rounded, label: 'Pengumuman', count: announcements.length),
          ...announcements.map((a) => _AnnouncementResultTile(item: a)),
          const SizedBox(height: 12),
        ],
        if (users.isNotEmpty) ...[
          _GroupHeader(icon: Icons.people_rounded, label: 'Pengguna', count: users.length),
          ...users.map((u) => _UserResultTile(item: u)),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 60),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.icon, required this.label, required this.count});
  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ScheduleResultTile extends StatelessWidget {
  const _ScheduleResultTile({required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return _ResultTile(
      icon: Icons.calendar_today_rounded,
      iconColor: AppColors.primary,
      title: item['title'] ?? '',
      subtitle: '${item['day_name'] ?? ''} • ${item['start_time'] ?? ''} - ${item['end_time'] ?? ''}${item['room'] != null ? ' • ${item['room']}' : ''}',
      onTap: () => context.push('/schedule/${item['id']}'),
    );
  }
}

class _TaskResultTile extends StatelessWidget {
  const _TaskResultTile({required this.item});
  final dynamic item;

  static Color _priorityColor(String? p) => switch (p) {
    'critical' => AppColors.priorityCritical,
    'high'     => AppColors.priorityHigh,
    'medium'   => AppColors.priorityMedium,
    _          => AppColors.priorityLow,
  };

  @override
  Widget build(BuildContext context) {
    final deadline = DateTime.tryParse(item['deadline'] ?? '');
    final sub = deadline != null
        ? 'Deadline: ${deadline.day}/${deadline.month}/${deadline.year}'
        : 'Tanpa deadline';

    return _ResultTile(
      icon: Icons.task_alt_rounded,
      iconColor: _priorityColor(item['priority']),
      title: item['title'] ?? '',
      subtitle: sub,
      onTap: () => context.push('/task/${item['id']}'),
    );
  }
}

class _AnnouncementResultTile extends StatelessWidget {
  const _AnnouncementResultTile({required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return _ResultTile(
      icon: Icons.campaign_rounded,
      iconColor: item['is_urgent'] == true ? AppColors.danger : AppColors.info,
      title: item['title'] ?? '',
      subtitle: item['category'] ?? '',
      onTap: () => context.push('/dashboard/announcement/${item['id']}'),
    );
  }
}

class _UserResultTile extends StatelessWidget {
  const _UserResultTile({required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return _ResultTile(
      icon: Icons.person_rounded,
      iconColor: AppColors.roleColor(item['role'] ?? ''),
      title: item['name'] ?? '',
      subtitle: '${item['nim'] ?? ''} • ${item['role'] ?? ''}',
      onTap: () {},
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(title,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
      ),
    );
  }
}

// ─── Empty / Error ────────────────────────────────────────────────────────────

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text('Tidak ditemukan', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Coba kata kunci yang lain', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}

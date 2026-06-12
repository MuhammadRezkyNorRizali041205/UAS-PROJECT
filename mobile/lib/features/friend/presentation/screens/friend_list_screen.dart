// lib/features/friend/presentation/screens/friend_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';

part 'friend_list_screen.g.dart';

// ─── Simple inline provider (no separate file needed) ─────────────────────────

@riverpod
Future<List<Map<String, dynamic>>> friends(Ref ref) async {
  final client = ref.watch(dioClientProvider);
  final res = await client.get<Map<String, dynamic>>(
    '/friends',
    fromJson: (d) => d as Map<String, dynamic>,
  );
  return (res['data'] as List)
      .map((e) => e as Map<String, dynamic>)
      .toList();
}

@riverpod
Future<List<Map<String, dynamic>>> friendRequests(Ref ref) async {
  final client = ref.watch(dioClientProvider);
  final res = await client.get<Map<String, dynamic>>(
    '/friends/requests',
    fromJson: (d) => d as Map<String, dynamic>,
  );
  return (res['data'] as List)
      .map((e) => e as Map<String, dynamic>)
      .toList();
}

// ─── Screen ────────────────────────────────────────────────────────────────────

class FriendListScreen extends ConsumerStatefulWidget {
  const FriendListScreen({super.key});

  @override
  ConsumerState<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends ConsumerState<FriendListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _acceptRequest(String friendshipId) async {
    final client = ref.read(dioClientProvider);
    await client.post<void>('/friends/$friendshipId/accept');
    ref.invalidate(friendRequestsProvider);
    ref.invalidate(friendsProvider);
  }

  Future<void> _removeFriend(String friendshipId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Teman'),
        content: const Text('Yakin ingin menghapus teman ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true) return;
    final client = ref.read(dioClientProvider);
    await client.delete('/friends/$friendshipId');
    ref.invalidate(friendsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teman'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Teman Saya'),
            Tab(text: 'Permintaan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _FriendTab(onRemove: _removeFriend),
          _RequestTab(onAccept: _acceptRequest),
        ],
      ),
    );
  }
}

class _FriendTab extends ConsumerWidget {
  const _FriendTab({required this.onRemove});

  final Future<void> Function(String) onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(friendsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(
              child: Text('Belum ada teman', style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final f = list[i];
            return ListTile(
              leading: CircleAvatar(
                child: Text(
                    (f['name'] as String).substring(0, 1).toUpperCase()),
              ),
              title:    Text(f['name'] as String),
              subtitle: Text(f['email'] as String),
              trailing: IconButton(
                icon: const Icon(Icons.person_remove_outlined,
                    color: Colors.red),
                onPressed: () =>
                    onRemove(f['friendship_id'] as String? ?? f['id'] as String),
              ),
            );
          },
        );
      },
    );
  }
}

class _RequestTab extends ConsumerWidget {
  const _RequestTab({required this.onAccept});

  final Future<void> Function(String) onAccept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(friendRequestsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(
              child: Text('Tidak ada permintaan',
                  style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final r    = list[i];
            final from = r['from'] as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                child: Text(
                    (from['name'] as String).substring(0, 1).toUpperCase()),
              ),
              title:    Text(from['name'] as String),
              subtitle: Text(from['email'] as String),
              trailing: FilledButton.tonal(
                onPressed: () => onAccept(r['friendship_id'] as String),
                child: const Text('Terima'),
              ),
            );
          },
        );
      },
    );
  }
}

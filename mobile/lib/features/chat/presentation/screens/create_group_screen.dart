// lib/features/chat/presentation/screens/create_group_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/chat_user.dart';
import '../providers/chat_providers.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameCtrl    = TextEditingController();
  final _searchCtrl  = TextEditingController();
  final _selected    = <ChatUser>[];
  bool  _loading     = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _selected.isEmpty) return;
    setState(() => _loading = true);
    try {
      final id = await ref
          .read(conversationListProvider.notifier)
          .createGroup(name, _selected.map((u) => u.id).toList());
      if (mounted) {
        context
          ..pop()
          ..push('/chat/$id');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(userSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Grup'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _create,
            child: _loading
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Buat'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Grup',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_selected.isNotEmpty)
            SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _selected.length,
                itemBuilder: (_, i) {
                  final u = _selected[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(u.name),
                      onDeleted: () =>
                          setState(() => _selected.remove(u)),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Cari anggota...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (q) =>
                  ref.read(userSearchProvider.notifier).search(q),
            ),
          ),
          Expanded(
            child: users.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) => ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final u       = list[i];
                  final checked = _selected.any((s) => s.id == u.id);
                  return CheckboxListTile(
                    value:    checked,
                    title:    Text(u.name),
                    subtitle: Text(u.email),
                    onChanged: (_) => setState(() {
                      if (checked) {
                        _selected.removeWhere((s) => s.id == u.id);
                      } else {
                        _selected.add(u);
                      }
                    }),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

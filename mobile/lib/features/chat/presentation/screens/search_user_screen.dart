// lib/features/chat/presentation/screens/search_user_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/chat_providers.dart';

class SearchUserScreen extends ConsumerStatefulWidget {
  const SearchUserScreen({super.key});

  @override
  ConsumerState<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends ConsumerState<SearchUserScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(userSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Cari nama atau email...',
            border: InputBorder.none,
          ),
          onChanged: (q) =>
              ref.read(userSearchProvider.notifier).search(q),
        ),
      ),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty && _ctrl.text.length >= 2) {
            return const Center(child: Text('Tidak ditemukan'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final u = list[i];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(u.name.substring(0, 1).toUpperCase()),
                ),
                title: Text(u.name),
                subtitle: Text(u.email),
                onTap: () async {
                  final id = await ref
                      .read(conversationListProvider.notifier)
                      .getOrCreateDirect(u.id);
                  if (context.mounted) {
                    context
                      ..pop()
                      ..push('/chat/$id');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

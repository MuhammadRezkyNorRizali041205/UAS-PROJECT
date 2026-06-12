// lib/features/chat/presentation/screens/chat_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_providers.dart';
import '../widgets/achievement_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller   = TextEditingController();
  final _scrollCtrl   = ScrollController();
  bool  _isTyping     = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(messageProvider(widget.conversationId).notifier).loadMore();
    }
  }

  void _onTextChanged(String text) {
    final notifier = ref.read(chatRepositoryProvider);
    if (!_isTyping && text.isNotEmpty) {
      _isTyping = true;
      notifier.sendTyping(widget.conversationId, isTyping: true);
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        notifier.sendTyping(widget.conversationId, isTyping: false);
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _isTyping = false;
    _typingTimer?.cancel();
    await ref
        .read(messageProvider(widget.conversationId).notifier)
        .send(text);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messageProvider(widget.conversationId));
    final typing   = ref.watch(typingIndicatorProvider(widget.conversationId));

    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, _) {
            final convs = ref.watch(conversationListProvider).value ?? [];
            final conv  = convs.where((c) => c.id == widget.conversationId).firstOrNull;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(conv?.name ?? 'Chat',
                    style: const TextStyle(fontSize: 16)),
                if (typing.values.any((v) => v))
                  const Text('mengetik...',
                      style: TextStyle(fontSize: 11, color: Colors.green)),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (msgs) => msgs.isEmpty
                  ? const Center(
                      child: Text('Belum ada pesan',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      controller:    _scrollCtrl,
                      reverse:       true,
                      padding:       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount:     msgs.length,
                      itemBuilder:   (_, i) => _MessageTile(
                        message: msgs[i],
                        isMine:  _isMine(msgs[i]),
                      ),
                    ),
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  bool _isMine(ChatMessage msg) {
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) return false;
    return msg.senderId == auth.user.id;
  }

  Widget _buildInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _onTextChanged,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Tulis pesan...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              onPressed: _send,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMine)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                message.senderName,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            constraints: const BoxConstraints(maxWidth: 280),
            child: message.isAchievement && message.achievementData != null
                ? AchievementBubble(
                    data:   message.achievementData!,
                    isMine: isMine,
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMine
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft:     const Radius.circular(18),
                        topRight:    const Radius.circular(18),
                        bottomLeft:  Radius.circular(isMine ? 18 : 4),
                        bottomRight: Radius.circular(isMine ? 4 : 18),
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isMine ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              timeago.format(message.createdAt, locale: 'id'),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

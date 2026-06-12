// lib/features/chat/presentation/providers/chat_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/websocket_service.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_user.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';

part 'chat_providers.g.dart';

// ─── Repository ────────────────────────────────────────────────────────────────

@riverpod
ChatRepository chatRepository(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  final ds  = ChatRemoteDatasource(dio);
  return ChatRepositoryImpl(ds);
}

// ─── Conversation List ──────────────────────────────────────────────────────────

@riverpod
class ConversationListNotifier extends _$ConversationListNotifier {
  @override
  Future<List<Conversation>> build() async {
    return ref.read(chatRepositoryProvider).getConversations();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(chatRepositoryProvider).getConversations());
  }

  Future<String> getOrCreateDirect(int userId) async {
    final conv = await ref.read(chatRepositoryProvider).getOrCreateDirect(userId);
    final current = state.value ?? [];
    if (!current.any((c) => c.id == conv.id)) {
      state = AsyncData([conv, ...current]);
    }
    return conv.id;
  }

  Future<String> createGroup(String name, List<int> memberIds) async {
    final conv = await ref.read(chatRepositoryProvider).createGroup(name, memberIds);
    final current = state.value ?? [];
    state = AsyncData([conv, ...current]);
    return conv.id;
  }

  void markConversationRead(String conversationId) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.map((c) {
      if (c.id != conversationId) return c;
      return Conversation(
        id:            c.id,
        type:          c.type,
        name:          c.name,
        avatar:        c.avatar,
        participants:  c.participants,
        lastMessage:   c.lastMessage,
        lastMessageAt: c.lastMessageAt,
        unreadCount:   0,
      );
    }).toList());
  }
}

// ─── Message List (per conversation) ──────────────────────────────────────────

@riverpod
class MessageNotifier extends _$MessageNotifier {
  String? _nextCursor;
  bool    _hasMore = true;

  @override
  Future<List<ChatMessage>> build(String conversationId) async {
    final repo  = ref.read(chatRepositoryProvider);
    final wsSvc = ref.read(webSocketServiceProvider);

    await wsSvc.connect();
    await wsSvc.subscribePrivate('conversation.$conversationId');

    void onMessage(Map<String, dynamic> data) {
      final newMsg = _parseMessage(data, conversationId);
      final current = state.value ?? [];
      if (current.any((m) => m.id == newMsg.id)) return;
      state = AsyncData([newMsg, ...current]);
    }

    wsSvc.on('conversation.$conversationId', 'message.sent', onMessage);

    ref.onDispose(() {
      wsSvc.off('conversation.$conversationId', 'message.sent', onMessage);
      wsSvc.unsubscribe('conversation.$conversationId');
    });

    final result = await repo.getMessages(conversationId);
    _nextCursor = result.nextCursor;
    _hasMore    = result.hasMore;

    repo.markRead(conversationId);
    ref.read(conversationListProvider.notifier).markConversationRead(conversationId);

    return result.messages;
  }

  Future<void> loadMore() async {
    if (!_hasMore || _nextCursor == null) return;
    final repo   = ref.read(chatRepositoryProvider);
    final result = await repo.getMessages(conversationId, cursor: _nextCursor);
    _nextCursor  = result.nextCursor;
    _hasMore     = result.hasMore;
    final current = state.value ?? [];
    state = AsyncData([...current, ...result.messages]);
  }

  Future<void> send(String content) async {
    final msg     = await ref.read(chatRepositoryProvider).sendMessage(conversationId, content);
    final current = state.value ?? [];
    state = AsyncData([msg, ...current]);
  }

  Future<void> shareAchievement(Map<String, dynamic> achievement) async {
    final msg     = await ref.read(chatRepositoryProvider).shareAchievement(conversationId, achievement);
    final current = state.value ?? [];
    state = AsyncData([msg, ...current]);
  }

  ChatMessage _parseMessage(Map<String, dynamic> data, String convId) {
    return ChatMessage(
      id:              data['id'] as String,
      conversationId:  convId,
      senderId:        (data['sender_id'] as num).toInt(),
      senderName:      (data['sender']?['name'] as String?) ?? '',
      content:         (data['content'] as String?) ?? '',
      type:            (data['type'] as String?) ?? 'text',
      createdAt:       DateTime.parse(data['created_at'] as String),
      achievementData: data['achievement_data'] as Map<String, dynamic>?,
    );
  }
}

// ─── Typing indicator ──────────────────────────────────────────────────────────

@riverpod
class TypingIndicator extends _$TypingIndicator {
  @override
  Map<int, bool> build(String conversationId) {
    final wsSvc = ref.read(webSocketServiceProvider);

    void onTyping(Map<String, dynamic> data) {
      final userId   = (data['user_id'] as num).toInt();
      final isTyping = data['is_typing'] as bool;
      state = {...state, userId: isTyping};
    }

    wsSvc.on('conversation.$conversationId', 'user.typing', onTyping);
    ref.onDispose(() => wsSvc.off('conversation.$conversationId', 'user.typing', onTyping));

    return {};
  }

  bool get anyoneTyping => state.values.any((v) => v);
}

// ─── User search ───────────────────────────────────────────────────────────────

@riverpod
class UserSearch extends _$UserSearch {
  @override
  Future<List<ChatUser>> build() async => [];

  Future<void> search(String query) async {
    if (query.length < 2) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(chatRepositoryProvider).searchUsers(query));
  }
}

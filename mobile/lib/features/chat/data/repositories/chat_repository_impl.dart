// lib/features/chat/data/repositories/chat_repository_impl.dart

import '../../domain/entities/chat_user.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._ds);

  final ChatRemoteDatasource _ds;

  @override
  Future<List<Conversation>> getConversations() async {
    final models = await _ds.getConversations();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Conversation> getOrCreateDirect(int targetUserId) async {
    final model = await _ds.getOrCreateDirect(targetUserId);
    return model.toEntity();
  }

  @override
  Future<Conversation> createGroup(String name, List<int> memberIds) async {
    final model = await _ds.createGroup(name, memberIds);
    return model.toEntity();
  }

  @override
  Future<({List<ChatMessage> messages, String? nextCursor, bool hasMore})>
      getMessages(String conversationId, {String? cursor}) async {
    final result = await _ds.getMessages(conversationId, cursor: cursor);
    return (
      messages:   result.messages.map((m) => m.toEntity()).toList(),
      nextCursor: result.nextCursor,
      hasMore:    result.hasMore,
    );
  }

  @override
  Future<ChatMessage> sendMessage(String conversationId, String content) async {
    final model = await _ds.sendMessage(conversationId, content);
    return model.toEntity();
  }

  @override
  Future<ChatMessage> shareAchievement(
      String conversationId, Map<String, dynamic> achievement) async {
    final model = await _ds.shareAchievement(conversationId, achievement);
    return model.toEntity();
  }

  @override
  Future<void> markRead(String conversationId) => _ds.markRead(conversationId);

  @override
  Future<void> sendTyping(String conversationId, {required bool isTyping}) =>
      _ds.sendTyping(conversationId, isTyping: isTyping);

  @override
  Future<List<ChatUser>> searchUsers(String query) => _ds.searchUsers(query);
}

// lib/features/chat/domain/repositories/chat_repository.dart

import '../entities/chat_user.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract interface class ChatRepository {
  Future<List<Conversation>> getConversations();

  Future<Conversation> getOrCreateDirect(int targetUserId);

  Future<Conversation> createGroup(String name, List<int> memberIds);

  Future<({List<ChatMessage> messages, String? nextCursor, bool hasMore})>
      getMessages(String conversationId, {String? cursor});

  Future<ChatMessage> sendMessage(String conversationId, String content);

  Future<ChatMessage> shareAchievement(
      String conversationId, Map<String, dynamic> achievement);

  Future<void> markRead(String conversationId);

  Future<void> sendTyping(String conversationId, {required bool isTyping});

  Future<List<ChatUser>> searchUsers(String query);
}

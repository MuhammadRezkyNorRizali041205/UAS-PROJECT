// lib/features/chat/data/datasources/chat_remote_datasource.dart

import '../../../../core/network/dio_client.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../../domain/entities/chat_user.dart';

class ChatRemoteDatasource {
  const ChatRemoteDatasource(this._client);

  final DioClient _client;

  Future<List<ConversationModel>> getConversations() async {
    final data = await _client.get<List<dynamic>>('/chat/conversations',
        fromJson: (d) => (d['data'] as List));
    return data.map((e) => ConversationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ConversationModel> getOrCreateDirect(int userId) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/chat/conversations/direct',
      data: {'user_id': userId},
      fromJson: (d) => d['data'] as Map<String, dynamic>,
    );
    return ConversationModel.fromJson({...data, 'participants': [], 'unread_count': 0});
  }

  Future<ConversationModel> createGroup(String name, List<int> memberIds) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/chat/conversations/group',
      data: {'name': name, 'member_ids': memberIds},
      fromJson: (d) => d['data'] as Map<String, dynamic>,
    );
    return ConversationModel.fromJson({...data, 'participants': [], 'unread_count': 0});
  }

  Future<({List<MessageModel> messages, String? nextCursor, bool hasMore})>
      getMessages(String conversationId, {String? cursor}) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/chat/conversations/$conversationId/messages',
      queryParameters: cursor != null ? {'cursor': cursor} : null,
      fromJson: (d) => d as Map<String, dynamic>,
    );
    final messages = (res['data'] as List)
        .map((e) => MessageModel.fromJson(
              e as Map<String, dynamic>,
              conversationId: conversationId,
            ))
        .toList();
    return (
      messages:   messages,
      nextCursor: res['next_cursor'] as String?,
      hasMore:    (res['has_more'] as bool?) ?? false,
    );
  }

  Future<MessageModel> sendMessage(String conversationId, String content) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/chat/conversations/$conversationId/messages',
      data: {'content': content, 'type': 'text'},
      fromJson: (d) => d['data'] as Map<String, dynamic>,
    );
    return MessageModel.fromJson(data, conversationId: conversationId);
  }

  Future<MessageModel> shareAchievement(
      String conversationId, Map<String, dynamic> achievement) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/chat/conversations/$conversationId/share-achievement',
      data: achievement,
      fromJson: (d) => d['data'] as Map<String, dynamic>,
    );
    return MessageModel.fromJson(data, conversationId: conversationId);
  }

  Future<void> markRead(String conversationId) async {
    await _client.post<void>('/chat/conversations/$conversationId/read');
  }

  Future<void> sendTyping(String conversationId, {required bool isTyping}) async {
    await _client.post<void>(
      '/chat/conversations/$conversationId/typing',
      data: {'is_typing': isTyping},
    );
  }

  Future<List<ChatUser>> searchUsers(String query) async {
    final data = await _client.get<List<dynamic>>(
      '/chat/users/search',
      queryParameters: {'q': query},
      fromJson: (d) => d['data'] as List,
    );
    return data
        .map((e) => ChatUser(
              id:    (e['id'] as num).toInt(),
              name:  e['name'] as String,
              email: (e['email'] as String?) ?? '',
            ))
        .toList();
  }
}

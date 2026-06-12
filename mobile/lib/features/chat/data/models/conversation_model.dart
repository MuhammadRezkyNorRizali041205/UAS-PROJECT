// lib/features/chat/data/models/conversation_model.dart

import '../../domain/entities/chat_user.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import 'message_model.dart';

class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.type,
    required this.name,
    required this.participants,
    required this.unreadCount,
    this.avatar,
    this.lastMessage,
    this.lastMessageAt,
  });

  final String id;
  final String type;
  final String name;
  final String? avatar;
  final List<ChatUser> participants;
  final ChatMessage? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final participants = (json['participants'] as List? ?? [])
        .map((p) => ChatUser(
              id:      p['id'] as int,
              name:    p['name'] as String,
              isAdmin: (p['is_admin'] as bool?) ?? false,
            ))
        .toList();

    ChatMessage? lastMsg;
    if (json['last_message'] != null) {
      lastMsg = MessageModel.fromJson(
        json['last_message'] as Map<String, dynamic>,
        conversationId: json['id'] as String,
      ).toEntity();
    }

    return ConversationModel(
      id:            json['id'] as String,
      type:          json['type'] as String,
      name:          (json['name'] as String?) ?? '',
      avatar:        json['avatar'] as String?,
      participants:  participants,
      lastMessage:   lastMsg,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount:   (json['unread_count'] as int?) ?? 0,
    );
  }

  Conversation toEntity() => Conversation(
        id:            id,
        type:          type,
        name:          name,
        avatar:        avatar,
        participants:  participants,
        lastMessage:   lastMessage,
        lastMessageAt: lastMessageAt,
        unreadCount:   unreadCount,
      );
}

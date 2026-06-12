// lib/features/chat/domain/entities/conversation.dart

import 'chat_user.dart';
import 'message.dart';

class Conversation {
  const Conversation({
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
  final String type; // direct | group
  final String name;
  final String? avatar;
  final List<ChatUser> participants;
  final ChatMessage? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  bool get isDirect => type == 'direct';
  bool get isGroup  => type == 'group';
}

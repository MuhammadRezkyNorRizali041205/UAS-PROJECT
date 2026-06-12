// lib/features/chat/domain/entities/message.dart

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.createdAt,
    this.achievementData,
    this.isRead = false,
  });

  final String id;
  final String conversationId;
  final int senderId;
  final String senderName;
  final String content;
  final String type; // text | image | achievement
  final DateTime createdAt;
  final Map<String, dynamic>? achievementData;
  final bool isRead;

  bool get isAchievement => type == 'achievement';
}

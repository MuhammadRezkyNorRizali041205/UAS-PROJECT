// lib/features/chat/data/models/message_model.dart

import '../../domain/entities/message.dart';

class MessageModel {
  const MessageModel({
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
  final String type;
  final DateTime createdAt;
  final Map<String, dynamic>? achievementData;
  final bool isRead;

  factory MessageModel.fromJson(
    Map<String, dynamic> json, {
    required String conversationId,
  }) {
    final sender = json['sender'] as Map<String, dynamic>?;
    return MessageModel(
      id:               json['id'] as String,
      conversationId:   conversationId,
      senderId:         (json['sender_id'] as num).toInt(),
      senderName:       (sender?['name'] as String?) ?? '',
      content:          (json['content'] as String?) ?? '',
      type:             (json['type'] as String?) ?? 'text',
      createdAt:        DateTime.parse(json['created_at'] as String),
      achievementData:  json['achievement_data'] as Map<String, dynamic>?,
      isRead:           (json['is_read'] as bool?) ?? false,
    );
  }

  ChatMessage toEntity() => ChatMessage(
        id:              id,
        conversationId:  conversationId,
        senderId:        senderId,
        senderName:      senderName,
        content:         content,
        type:            type,
        createdAt:       createdAt,
        achievementData: achievementData,
        isRead:          isRead,
      );
}

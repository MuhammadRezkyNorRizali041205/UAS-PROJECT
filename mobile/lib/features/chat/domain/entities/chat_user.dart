// lib/features/chat/domain/entities/chat_user.dart

class ChatUser {
  const ChatUser({
    required this.id,
    required this.name,
    this.email = '',
    this.isAdmin = false,
  });

  final int id;
  final String name;
  final String email;
  final bool isAdmin;
}

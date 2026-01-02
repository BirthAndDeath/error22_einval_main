import '/data/chat_db.dart';

class Message {
  final int? id;
  final String content;
  final DateTime timestamp;
  final bool isUser;

  Message({
    this.id,
    required this.content,
    required this.timestamp,
    required this.isUser,
  });

  factory Message.fromTable(ChatMessage t) => Message(
    id: t.id,
    content: t.content,
    timestamp: DateTime.fromMillisecondsSinceEpoch(t.timestamp),
    isUser: t.isUser,
  );
}

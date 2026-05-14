class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  factory Message.user(String text) => Message(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      );

  factory Message.ai(String text) => Message(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      );
}

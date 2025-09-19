class Message {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      sender: MessageSender.values.firstWhere(
        (e) => e.toString().split('.').last == json['sender'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum MessageSender { user, bot }
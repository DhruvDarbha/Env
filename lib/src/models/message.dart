import 'recipe.dart';

class Message {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final String? senderName;
  final Recipe? detectedRecipe;

  Message({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.senderName,
    this.detectedRecipe,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      sender: MessageSender.values.firstWhere(
        (e) => e.toString().split('.').last == json['sender'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      senderName: json['senderName'],
      detectedRecipe: json['detectedRecipe'] != null
          ? Recipe.fromJson(json['detectedRecipe'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'senderName': senderName,
      'detectedRecipe': detectedRecipe?.toJson(),
    };
  }
}

enum MessageSender { user, bot }
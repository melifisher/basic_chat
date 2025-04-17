import './response_model.dart';

class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  Response? response;
  int? feedback; // null = no feedback, 1 = positive, 0 = negative

  Message({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
    this.response,
    this.feedback,
  }) : timestamp = timestamp ?? DateTime.now();
}
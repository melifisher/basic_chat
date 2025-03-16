import 'message_model.dart';

class Chat {
  final List<Message> messages;

  Chat({List<Message>? messages}) : messages = messages ?? [];

  void addMessage(Message message) {
    messages.add(message);
  }
}



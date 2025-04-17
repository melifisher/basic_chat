import 'message_model.dart';

class Chat {
  List<Message> messages = [];

  void addMessage(Message message) {
    messages.add(message);
  }

  void updateMessage(int index, Message message) {
    if (index >= 0 && index < messages.length) {
      messages[index] = message;
    }
  }
}
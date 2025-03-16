import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../utils/markdown_formatter.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final timeFormat = DateFormat('HH:mm');
    
    // Estilo base para el texto
    final TextStyle baseStyle = TextStyle(
      color: isUser ? Colors.white : Colors.black,
      fontSize: 16.0,
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: Colors.blue[700],
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.asset('deepseek-logo-inverted.png'),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Usar RichText con spans formateados para mostrar markdown
                  RichText(
                    text: TextSpan(
                      children: isUser 
                        ? [TextSpan(text: message.content, style: baseStyle)]
                        : MarkdownFormatter.formatText(message.content, baseStyle),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeFormat.format(message.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: isUser ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text('Yo'),
            ),
        ],
      ),
    );
  }
}
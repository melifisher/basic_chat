import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';

class ApiService {
  final String baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  final String apiKey = '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'; // Reemplazar con tu API key

  Future<String> sendMessage(List<Message> messages) async {
    try {

      final List<Map<String, dynamic>> formattedMessages = [
        {
          'role': 'system',
          'content': 'Eres un asistente virtual amigable. Responde siempre en español, independientemente del idioma en que te hablen. Puedes usar markdown para dar formato a tus respuestas.',
        },
        ...messages.map((message) => {
          'role': message.isUser ? 'user' : 'assistant',
          'content': message.content,
        }).toList(),
      ];

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'https://app-with-deepseek.com', // Requerido por OpenRouter
          'X-Title': 'Flutter Deepseek Chat App', // Nombre de tu aplicación
        },
        body: jsonEncode({
          'model': 'deepseek/deepseek-chat',
          'messages': formattedMessages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Error al enviar mensaje: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la comunicación con la API: $e');
    }
  }
}
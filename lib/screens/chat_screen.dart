import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../services/api_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/speak_button.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Chat _chat = Chat();
  final ApiService _apiService = ApiService();
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _isLoading = false;

  void requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  @override
  void initState() {
    super.initState();
    requestMicrophonePermission();
    // Mensaje de bienvenida
    _chat.addMessage(Message(
      content: "¡Hola! Soy Deepseek. ¿En qué puedo ayudarte hoy?",
      isUser: false,
    ));
  }

  void _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    setState(() {
      // Agregar mensaje del usuario
      _chat.addMessage(Message(content: content, isUser: true));
      _isLoading = true;
    });

    try {
      // Enviar mensaje a la API
      final response = await _apiService.sendMessage(_chat.messages);
      
      setState(() {
        // Agregar respuesta del asistente
        _chat.addMessage(Message(content: response, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _chat.addMessage(Message(
          content: "Error: No se pudo conectar con Deepseek. Por favor, intenta de nuevo.",
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat con Deepseek'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _chat.messages.length,
              reverse: false,
              itemBuilder: (context, index) {
                final message = _chat.messages[index];
                return ChatBubble(message: message,
                ttsService: _ttsService);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          MessageInput(onSendMessage: _sendMessage),
        ],
      ),
    );
  }
}
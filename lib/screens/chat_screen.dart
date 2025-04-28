import 'package:basic_chat/models/context_cache.dart';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../services/langachain_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/drawer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Chat _chat = Chat();
  final LangchainService _apiService = LangchainService();
  bool _isLoading = false;
  final contextCache = ContextCache();

  void requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  void initCache() async {
    await contextCache.init();
  }

  @override
  void initState() {
    super.initState();
    requestMicrophonePermission();
    initCache();
  }

  void _sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    String tempHistory = "";

    setState(() {
      // Agregar mensaje del usuario
      _chat.addMessage(Message(content: content, isUser: true));
      _isLoading = true;
    });

    try {
      // Enviar mensaje a la API
      // Usando operadores null-coalescing para valores por defecto
      final oldQuestion = await contextCache.getUltimateQuestion() ?? "";
      final oldResponseFull = await contextCache.getUltimateAnswerFull() ?? "";

      final List<HistoryEntry> historial = await contextCache.getSummaries(
        limit: 8,
      );

      final responseApi = await _apiService.search(
        content,
        oldQuestion,
        oldResponseFull,
        historial,
      );

      if (responseApi.isNewContext) {
        await contextCache.clearHistory();
        await contextCache.addEntry(
          question: responseApi.query,
          answerFull: responseApi.results,
          answerSummary: responseApi.response,
        );
      }
      tempHistory =
          "pregunta: $content <;>  su respuesta: ${responseApi.response}";
      //Almacena en la tabla symmary la pregunta y respuesta resumida

      await contextCache.addSummary(summary: tempHistory);
      //await contextCache.clearSummaries();

      setState(() {
        // Agregar respuesta del asistente
        _chat.addMessage(
          Message(
            content: responseApi.response,
            isUser: false,
            response: responseApi,
          ),
        );

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _chat.addMessage(
          Message(
            content:
                "Error: No se pudo conectar con Deepseek. Por favor, intenta de nuevo.",
            isUser: false,
          ),
        );
        _isLoading = false;
      });
    }
  }

  void _submitFeedback(Message message, int rating) async {
    try {
      // Find the user query that corresponds to this response
      int responseIndex = _chat.messages.indexOf(message);
      String userQuery = "";

      // Search backwards from the response to find the last user message
      for (int i = responseIndex - 1; i >= 0; i--) {
        if (_chat.messages[i].isUser) {
          userQuery = _chat.messages[i].content;
          break;
        }
      }

      if (userQuery.isNotEmpty) {
        // Submit feedback
        final result = await _apiService.feedback(
          userQuery,
          message.content,
          rating == 1 ? 5 : 0,
          message.response!.results,
        );

        // Update message with feedback status
        setState(() {
          final updatedMessages = List<Message>.from(_chat.messages);
          final messageIndex = updatedMessages.indexOf(message);
          if (messageIndex != -1) {
            updatedMessages[messageIndex] = Message(
              content: message.content,
              isUser: message.isUser,
              response: message.response,
              timestamp: message.timestamp,
              feedback: rating,
            );
            _chat.messages = updatedMessages;
          }
        });

        // Optional: Show a snackbar to confirm feedback was sent
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Gracias por tu feedback!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Handle feedback submission error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al enviar feedback. Por favor, intenta de nuevo.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente Vial BO'),
      ),
      drawer: DrawerWidget(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _chat.messages.length + 1,
              reverse: false,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    child: Text(
                      '¿Con qué puedo ayudarte?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(185, 158, 158, 158),
                      ),
                    ),
                  );
                }
                final message = _chat.messages[index - 1];
                return ChatBubble(
                  message: message,
                  onFeedback: !message.isUser ? _submitFeedback : null,
                );
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

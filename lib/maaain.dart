import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() async {
  // await dotenv.load();
  runApp(DeepseekChatApp());
}

class DeepseekChatApp extends StatelessWidget {
  const DeepseekChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat con Deepseek',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

}
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final FlutterTts flutterTts = FlutterTts();

  final String apiUrl = "https://models.inference.ai.azure.com";
  // String get apiKey => dotenv.env['AZURE_API_KEY'] ?? '';
  String apiKey = "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";
  String get endpoint => "/chat/completions";

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          text: userMessage,
          isUser: true
        ),
      );
      _isLoading = true;
    });
    
    _scrollToBottom();

    try {
      final messages = _messages
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.text,
              })
          .toList();

      final response = await http.post(
        Uri.parse('$apiUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': "DeepSeek-R1",
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final botResponse = data['choices'][0]['message']['content'];
        
        setState(() {
          _messages.add(
            ChatMessage(
              text: botResponse,
              isUser: false,
              tts: flutterTts,
            )
          );
          _isLoading = false;
        });

        // final responseWithoutThink = botResponse.split('</think>').last;
        // flutterTts.speak(responseWithoutThink);
        
        _scrollToBottom();
      } else {
        setState(() {
          _messages.add(
            ChatMessage(
              text: "Error: No se pudo obtener respuesta. Código: ${response.statusCode}\n${response.body}",
              isUser: false,
              tts: flutterTts,
            ),
          );
          _isLoading = false;
        });
        
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Error de conexión: $e",
            isUser: false,
            tts: flutterTts,
          ),
        );
        _isLoading = false;
      });
      
      _scrollToBottom();
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat con Deepseek'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16.0),
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[_messages.length - 1 - index];
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    ),
                    SizedBox(width: 12),
                    Text("Deepseek está procesando..."),
                  ],
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, -2),
                  )
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Escribe un mensaje...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                      ),
                      minLines: 1,
                      maxLines: 5,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    mini: true,
                    child: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ChatMessage extends StatefulWidget {
  final String text;
  final bool isUser;
  final FlutterTts? tts;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    this.tts,
  });

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    if(widget.tts!=null){
      widget.tts!.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            isSpeaking = false;
          });
        }
      });
      _speak();
    }
  }

  void _speak() async {
    await widget.tts!.stop();
    
    setState(() {
      isSpeaking = true;
    });
    
    final responseWithoutThink = widget.text.split('</think>').last;
    await widget.tts!.speak(responseWithoutThink);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!widget.isUser)
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.asset('deepseek-logo.png'),
              ),            
            ),
          SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isUser ? Colors.purple[100] : Colors.indigo[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          if (widget.isUser)
            CircleAvatar(
              backgroundColor: Colors.purple[600],
              child: Text('Yo', style: TextStyle(color: Colors.white)),
            ),
          if (!widget.isUser)
            IconButton(
              icon: Icon(
                Icons.volume_up,
                size: 20,
                // Cambiar el color cuando está hablando
                color: isSpeaking ? Colors.indigo : Colors.grey[600],
              ),
              // Cambiar el fondo cuando está hablando
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  isSpeaking ? Colors.grey[300] : Colors.transparent,
                ),
              ),
              onPressed: _speak,
            ),        
          ],
      ),
    );
  }
}
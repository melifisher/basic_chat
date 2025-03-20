import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:permission_handler/permission_handler.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;

  const MessageInput({super.key, required this.onSendMessage});

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  double _confidence = 0.0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _controller.dispose();
    // Asegúrate de detener la escucha al eliminar el widget
    if (_isListening) {
      _speechToText.stop();
    }
    super.dispose();
  }

  /// Inicializa el reconocimiento de voz con mejor manejo de errores
  Future<void> _initSpeech() async {
    try {
      print('Intentando inicializar el reconocimiento de voz...');
      // Solicita permisos antes de inicializar
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        setState(() {
          _errorMessage = 'Permiso de micrófono necesario';
          _speechEnabled = false;
        });
        return;
      }

      // Inicializa el motor de reconocimiento de voz
      _speechEnabled = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: (errorNotification) {
          print('Error del reconocimiento de voz: ${errorNotification.errorMsg}');
          setState(() {
            _errorMessage = 'Error: ${errorNotification.errorMsg}';
            _isListening = false;
          });
        },
        debugLogging: true, // Activa el registro de depuración
      );
      
      // Verifica los idiomas disponibles
      var locales = await _speechToText.locales();
      bool hasSpanish = locales.any((locale) => 
        locale.localeId.startsWith('es_') || locale.localeId == 'es');
      
      print('Speech initialization complete: $_speechEnabled');
      print('Idiomas disponibles: ${locales.map((e) => e.localeId).toList()}');
      print('Español disponible: $hasSpanish');
      
      setState(() {});
    } catch (e) {
      print('Error al inicializar el reconocimiento de voz: $e');
      setState(() {
        _errorMessage = 'Error inicializando: $e';
        _speechEnabled = false;
        _isListening = false;
      });
    }
  }

  /// Callback para cambios de estado del reconocimiento de voz
  void _onSpeechStatus(String status) {
    print('Estado del reconocimiento: $status');
    
    if (status == 'done' || status == 'notListening') {
      if (mounted) {
        setState(() {
          _isListening = false;
        });
        
        // Si hay texto reconocido, lo mantenemos en el campo
        if (_lastWords.isNotEmpty) {
          _controller.text = _lastWords;
          if (mounted) {
            setState(() {
              _lastWords = '';
            });
          }
        }
      }
    } else if (status == 'listening') {
      if (mounted) {
        setState(() {
          _isListening = true;
          _errorMessage = '';
        });
      }
    }
  }

  /// Maneja el resultado del reconocimiento de voz
  void _onSpeechResult(SpeechRecognitionResult result) {
    print('Texto reconocido: ${result.recognizedWords}');
    if (mounted) {
      setState(() {
        _lastWords = result.recognizedWords;
        if (result.hasConfidenceRating && result.confidence > 0) {
          _confidence = result.confidence;
        }
      });
      
      // Actualizamos el texto en el campo de entrada
      _controller.text = _lastWords;
      _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
    }
  }

  Future<void> _startListening() async {
    print('startListening');
    // Limpiar mensajes de error previos
    setState(() {
      _errorMessage = '';
      _lastWords = '';
    });
    
    // Verificar si ya tenemos el permiso
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        setState(() {
          _errorMessage = 'Permiso de micrófono denegado';
        });
        return;
      }
    }
    
    if (!_speechEnabled) {
      await _initSpeech();
      if (!_speechEnabled) {
        setState(() {
          _errorMessage = 'No se pudo inicializar el reconocimiento de voz';
        });
        return;
      }
    }
    
    try {
      var locales = await _speechToText.locales();
      String localeId = 'es_ES';
      
      // Buscar si hay alguna versión de español disponible
      var spanishLocale = locales.firstWhere(
        (locale) => locale.localeId.startsWith('es_'),
        orElse: () => locales.firstWhere(
          (locale) => locale.localeId == 'es',
          orElse: () => LocaleName('en_US', 'English'),
        ),
      );
      
      localeId = spanishLocale.localeId;
      print('Usando idioma: $localeId');
      
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30), // Escucha hasta 30 segundos
        pauseFor: const Duration(seconds: 2), // Pausa de 2 segundos para considerar fin del habla
        partialResults: true,
        localeId: 'es_MX',   //localeId
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
      
      setState(() {
        _isListening = true;
      });
    } catch (e) {
      print('Error al iniciar la escucha: $e');
      setState(() {
        _errorMessage = 'Error al iniciar micrófono: $e';
        _isListening = false;
      });
    }
  }

  /// Detiene la escucha manualmente
  void _stopListening() async {
    print('stopListening');

    try {
      await _speechToText.stop();
    } catch (e) {
      print('Error al detener la escucha: $e');
    }
    
    setState(() {
      _isListening = false;
    });
  }

  void _handleSubmit() {
    final message = _controller.text;
    if (message.trim().isNotEmpty) {
      widget.onSendMessage(message);
      _controller.clear();
      setState(() {
        _lastWords = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pa mostrar el mensaje de error
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _errorMessage,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[700],
                ),
              ),
            ),
            
          if (_isListening)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _lastWords.isEmpty 
                  ? 'Escuchando...'
                  : 'Reconocido: $_lastWords',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            
          Row(
            children: [
              // Botón de micrófono con efecto de glow cuando está activo
              AvatarGlow(
                animate: _isListening,
                glowColor: Theme.of(context).primaryColor,
                // endRadius: 25.0,
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                child: Material(
                  elevation: 2.0,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () {
                      print('Botón de micrófono presionado');
                      print('Estado de escucha: $_isListening');
                      print('Speech habilitado: $_speechEnabled');
                      
                      if (_isListening) {
                        _stopListening();
                      } else {
                        _startListening();
                      }
                    },
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Campo de texto
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: _speechEnabled
                        ? 'Escribe o habla tu mensaje...'
                        : 'Escribe un mensaje...',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSubmit(),
                ),
              ),
              const SizedBox(width: 8),
              // Botón de enviar
              FloatingActionButton(
                onPressed: _handleSubmit,
                mini: true,
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
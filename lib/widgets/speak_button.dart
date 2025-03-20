import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;
  Function()? onStateChanged;

  TextToSpeechService._internal() {
    _initTts();
  }

  FlutterTts flutterTts = FlutterTts();
  bool _isSpeaking = false;
  
  bool get isSpeaking => _isSpeaking;
  
  void _initTts() async {
    await flutterTts.setLanguage("es-MX");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);  
    
    flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      if (onStateChanged != null) {
        onStateChanged!();
      }
    });
  }
  
  Future<void> speak(String text) async {
    if (_isSpeaking) {
      await stop();
    }else{
      // Remove any markdown or special formatting before speaking
      final cleanText = text.replaceAll(RegExp(r'<.*?>'), '')
          .replaceAll(RegExp(r'\*'), '') 
          .replaceAll(RegExp(r'#'), '');
      _isSpeaking = true;
      if (onStateChanged != null) {
        onStateChanged!();
      }
      await flutterTts.speak(cleanText);
    }
  }
  
  Future<void> stop() async {
    _isSpeaking = false;
    if (onStateChanged != null) {
      onStateChanged!();
    }
    await flutterTts.stop();
  }
  
  void dispose() {
    flutterTts.stop();
  }
}

class SpeakButton extends StatefulWidget {
  final String text;
  final TextToSpeechService ttsService;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;
  final Color activeBackgroundColor;
  
  const SpeakButton({
    super.key,
    required this.text,
    required this.ttsService,
    this.size = 20,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.backgroundColor = Colors.transparent,
    this.activeBackgroundColor = const Color(0xFFE0E0E0),
  });

  @override
  State<SpeakButton> createState() => _SpeakButtonState();
}

class _SpeakButtonState extends State<SpeakButton> {
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    
    widget.ttsService.onStateChanged = () {
      if (mounted) {
        setState(() {
          _isSpeaking = widget.ttsService.isSpeaking;
          debugPrint('State changed to $_isSpeaking');
        });
      }
    };
  }

  @override
  void dispose() {
    // Clean up by removing our callback
    if (widget.ttsService.onStateChanged == setState) {
      widget.ttsService.onStateChanged = null;
    }
    super.dispose();
  }

  void _speak() async {
    await widget.ttsService.speak(widget.text);
    // setState(() {
    //   _isSpeaking = widget.ttsService.isSpeaking;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.volume_up,
        size: widget.size,
        color: _isSpeaking ? widget.activeColor : widget.inactiveColor,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          _isSpeaking ? widget.activeBackgroundColor : widget.backgroundColor,
        ),
      ),
      onPressed: _speak,
    );
  }
}
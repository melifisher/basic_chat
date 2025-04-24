import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tts_provider.dart';

class SpeakButton extends StatelessWidget {
  final String text;
  final String id;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;
  final Color activeBackgroundColor;

  const SpeakButton({
    super.key,
    required this.text,
    required this.id,
    this.size = 20,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.backgroundColor = Colors.transparent,
    this.activeBackgroundColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TtsProvider>(
      builder: (context, ttsProvider, _) {
        final bool isActive = ttsProvider.activeSpeakerId == id && ttsProvider.isSpeaking;
        
        return IconButton(
          icon: Icon(
            Icons.volume_up,
            size: size,
            color: isActive ? activeColor : inactiveColor,
          ),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              isActive ? activeBackgroundColor : backgroundColor,
            ),
          ),
          onPressed: () => ttsProvider.speak(text, id),
        );
      },
    );
  }
}
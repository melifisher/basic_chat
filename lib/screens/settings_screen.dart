import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tts_provider.dart';

class VoiceSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TtsProvider>(
      builder: (context, ttsProvider, _) {
        return Scaffold(
          appBar: AppBar(title: Text('Configuración de voz')),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Control para cambiar idioma
              DropdownButtonFormField<String>(
                value: ttsProvider.language,
                decoration: InputDecoration(labelText: 'Idioma'),
                items: [
                  DropdownMenuItem(value: 'es-MX', child: Text('Español (México)')),
                  DropdownMenuItem(value: 'en-US', child: Text('Inglés (Estados Unidos)')),
                  // Más idiomas...
                ],
                onChanged: (value) {
                  if (value != null) ttsProvider.setLanguage(value);
                },
              ),
              
              // Control para cambiar género de voz
              DropdownButtonFormField<String>(
                value: ttsProvider.voiceGender,
                decoration: InputDecoration(labelText: 'Género de voz'),
                items: [
                  DropdownMenuItem(value: 'female', child: Text('Femenino')),
                  DropdownMenuItem(value: 'male', child: Text('Masculino')),
                ],
                onChanged: (value) {
                  if (value != null) ttsProvider.setVoiceGender(value);
                },
              ),
              
              // Slider para velocidad de habla
              Slider(
                value: ttsProvider.speechRate,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                label: ttsProvider.speechRate.toStringAsFixed(1),
                onChanged: (value) => ttsProvider.setSpeechRate(value),
              ),
              Text('Velocidad: ${ttsProvider.speechRate.toStringAsFixed(1)}'),
              
              // Controles similares para volumen y tono...
              
              // Botón para probar la configuración actual
              ElevatedButton(
                onPressed: () => ttsProvider.speak('Este es un texto de prueba para verificar la configuración de voz.', 'test'),
                child: Text('Probar configuración'),
              ),
            ],
          ),
        );
      },
    );
  }
}
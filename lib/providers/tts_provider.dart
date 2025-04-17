// tts_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsProvider extends ChangeNotifier {
  final FlutterTts flutterTts = FlutterTts();
  bool _isSpeaking = false;
  String? _activeSpeakerId;
  
  // Configuraciones de voz
  String _language = "es-MX";
  double _speechRate = 0.6;
  double _volume = 1.0;
  double _pitch = 1.5;
  String _voiceGender = "female";
  
  // Getters
  bool get isSpeaking => _isSpeaking;
  String? get activeSpeakerId => _activeSpeakerId;
  String get language => _language;
  double get speechRate => _speechRate;
  double get volume => _volume;
  double get pitch => _pitch;
  String get voiceGender => _voiceGender;
  
  TtsProvider() {
    _loadPreferences();
    _initTts();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    _language = prefs.getString('tts_language') ?? "es-MX";
    _speechRate = prefs.getDouble('tts_speech_rate') ?? 0.6;
    _volume = prefs.getDouble('tts_volume') ?? 1.0;
    _pitch = prefs.getDouble('tts_pitch') ?? 1.5;
    _voiceGender = prefs.getString('tts_voice_gender') ?? "female";
    
    await _applySettings();
    notifyListeners();
  }
  
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('tts_language', _language);
    await prefs.setDouble('tts_speech_rate', _speechRate);
    await prefs.setDouble('tts_volume', _volume);
    await prefs.setDouble('tts_pitch', _pitch);
    await prefs.setString('tts_voice_gender', _voiceGender);
  }
  
  Future<void> _initTts() async {
    await _applySettings();
    
    flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _activeSpeakerId = null;
      notifyListeners();
    });
  }
  
  Future<void> _applySettings() async {
    await flutterTts.setLanguage(_language);
    await flutterTts.setSpeechRate(_speechRate);
    await flutterTts.setVolume(_volume);
    await flutterTts.setPitch(_pitch);
    await setVoiceGender(_voiceGender);
  }

  Future<void> setVoiceGender(String gender) async {
  //   List<dynamic> voices = await flutterTts.
  }

  //Don't know if this is ok
  Future<void> setLanguage(String language) async {
    _language = language;
    await flutterTts.setLanguage(language);
    await _savePreferences();
    notifyListeners();
  }
  void setSpeechRate(double rate) {
    _speechRate = rate;
    flutterTts.setSpeechRate(rate);
    _savePreferences();
    notifyListeners();
  }

  Future<void> speak(String text, String id) async {
    if (_isSpeaking) {
      await stop(id);
    }else{
      // Remove any markdown or special formatting before speaking
      final cleanText = text.replaceAll(RegExp(r'<.*?>'), '')
          .replaceAll(RegExp(r'\*'), '') 
          .replaceAll(RegExp(r'#'), '');
      _isSpeaking = true;
      _activeSpeakerId = id;
      await flutterTts.speak(cleanText);
      notifyListeners();
    }
  }
  
  Future<void> stop(String id) async {
    _isSpeaking = false;
    _activeSpeakerId = id;
    await flutterTts.stop();
    notifyListeners();
  }
}
 
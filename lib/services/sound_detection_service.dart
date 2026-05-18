import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';

class SoundDetectionService {
  static final SoundDetectionService _instance = SoundDetectionService._internal();
  factory SoundDetectionService() => _instance;
  SoundDetectionService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isActive = false;
  Timer? _restartTimer;
  Function(ThreatAlert)? _onThreat;

  static const List<String> _distressWords = [
    'help', 'save me', 'sahayam', 'bachao', 'vidoo',
    'leave me', 'let go', 'stop', 'no no no',
    'vedana', 'bhayam', 'emergency', 'police', 'sos',
    'amma', 'achan', 'please stop', 'scared',
  ];

  static const List<String> _threatWords = [
    'shut up', 'quiet', 'silent', 'nobody will know',
    'come with me', 'parayaruthu', 'nokkaruthu',
  ];

  Future<bool> initialize() async {
    return await _speech.initialize();
  }

  Future<void> startDetection(Function(ThreatAlert) onThreat) async {
    if (_isActive) return;
    _isActive = true;
    _onThreat = onThreat;
    await _listen();
  }

  Future<void> _listen() async {
    if (!_isActive) return;
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _analyzeText(result.recognizedWords.toLowerCase());
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: 'ml_IN',
      listenMode: ListenMode.dictation,
    );
    _restartTimer = Timer(const Duration(seconds: 12), () {
      if (_isActive) _listen();
    });
  }

  void _analyzeText(String text) {
    if (text.isEmpty) return;
    for (final word in _distressWords) {
      if (text.contains(word)) {
        _onThreat?.call(ThreatAlert(
          type: ThreatType.distressSignal,
          detectedWord: word,
          fullText: text,
          severity: ThreatSeverity.critical,
          message: 'Distress signal detected',
          silentMode: false,
        ));
        return;
      }
    }
    for (final word in _threatWords) {
      if (text.contains(word)) {
        _onThreat?.call(ThreatAlert(
          type: ThreatType.threatDetected,
          detectedWord: word,
          fullText: text,
          severity: ThreatSeverity.critical,
          message: 'Threat detected',
          silentMode: true,
        ));
        return;
      }
    }
  }

  void stopDetection() {
    _isActive = false;
    _restartTimer?.cancel();
    _speech.stop();
  }
}

enum ThreatType { distressSignal, threatDetected }
enum ThreatSeverity { high, critical }

class ThreatAlert {
  final ThreatType type;
  final String detectedWord;
  final String fullText;
  final ThreatSeverity severity;
  final String message;
  final bool silentMode;
  final DateTime time;

  ThreatAlert({
    required this.type,
    required this.detectedWord,
    required this.fullText,
    required this.severity,
    required this.message,
    required this.silentMode,
  }) : time = DateTime.now();
}

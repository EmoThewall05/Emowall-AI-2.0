// lib/care/guardian_ai.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class GuardianAIScreen extends StatefulWidget {
  const GuardianAIScreen({super.key});

  @override
  State<GuardianAIScreen> createState() => _GuardianAIScreenState();
}

class _GuardianAIScreenState extends State<GuardianAIScreen>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isListening = false;
  bool _emergencyMode = false;
  String _lastHeard = '';
  String _statusMessage = 'Guardian AI Ready 🛡️';
  int _painLevel = 0;

  // 👨‍👩‍👧 Family contacts
  final List<Map<String, String>> _familyContacts = [
    {'name': 'Family Member 1', 'phone': '+91XXXXXXXXXX'},
    {'name': 'Family Member 2', 'phone': '+91XXXXXXXXXX'},
    {'name': 'Doctor', 'phone': '+91XXXXXXXXXX'},
  ];

  // ⏰ Medicine schedule
  final List<Map<String, dynamic>> _medicineSchedule = [
    {'name': 'Morning Medicine', 'time': '08:00', 'taken': false},
    {'name': 'Afternoon Medicine', 'time': '13:00', 'taken': false},
    {'name': 'Night Medicine', 'time': '21:00', 'taken': false},
  ];

  late AnimationController _pulseController;
  late AnimationController _heartController;
  Timer? _medicineTimer;
  Timer? _continuousListenTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _initAll();
  }

  Future<void> _initAll() async {
    // TTS setup — slow gentle voice
    await _tts.setLanguage('ml-IN');
    await _tts.setSpeechRate(0.35);
    await _tts.setPitch(1.1);
    await _tts.setVolume(1.0);

    // Speech recognition
    await _speech.initialize();

    // Notifications
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications.initialize(
      const InitializationSettings(android: android),
    );

    // Start medicine timer check
    _startMedicineTimer();

    // Welcome message
    await _speak(
      'Guardian AI ready. Ningalkku enthu veenam ennal paranjal mathi. '
      'I am always here for you.',
    );
  }

  // 🗣️ AI speaks
  Future<void> _speak(String text) async {
    setState(() => _statusMessage = text);
    await _tts.speak(text);
  }

  // 👂 Continuous voice listening
  Future<void> _startContinuousListening() async {
    setState(() => _isListening = true);

    _continuousListenTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        if (!_isListening) return;
        await _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              _processVoiceCommand(result.recognizedWords.toLowerCase());
            }
          },
          listenFor: const Duration(seconds: 4),
          localeId: 'ml_IN',
        );
      },
    );

    await _speak('Listening started. Paranjal mathi, ഞാൻ കേൾക്കുന്നുണ്ട്!');
  }

  void _stopListening() {
    _continuousListenTimer?.cancel();
    _speech.stop();
    setState(() => _isListening = false);
  }

  // 🧠 Process voice commands — Malayalam + English
  void _processVoiceCommand(String command) {
    setState(() => _lastHeard = command);

    // 💧 Water
    if (command.contains('water') ||
        command.contains('വെള്ളം') ||
        command.contains('vellam') ||
        command.contains('drink')) {
      _triggerCareAlert('water');
    }

    // 🍜 Food
    else if (command.contains('food') ||
        command.contains('കഴിക്കാൻ') ||
        command.contains('kazikkan') ||
        command.contains('hungry') ||
        command.contains('വിശക്കുന്നു')) {
      _triggerCareAlert('food');
    }

    // 💊 Medicine
    else if (command.contains('medicine') ||
        command.contains('മരുന്ന്') ||
        command.contains('marunn') ||
        command.contains('tablet')) {
      _triggerCareAlert('medicine');
    }

    // 🤕 Pain
    else if (command.contains('pain') ||
        command.contains('വേദന') ||
        command.contains('vedana') ||
        command.contains('hurt') ||
        command.contains('avastha')) {
      _triggerCareAlert('pain');
    }

    // 🚨 Emergency
    else if (command.contains('help') ||
        command.contains('emergency') ||
        command.contains('സഹായം') ||
        command.contains('sahayam') ||
        command.contains('sos')) {
      _triggerEmergency();
    }

    // 😰 Stress
    else if (command.contains('stress') ||
        command.contains('tension') ||
        command.contains('സ്ട്രെസ്') ||
        command.contains('worried')) {
      _triggerCareAlert('stress');
    }
  }

  // 🚨 Care Alert System
  Future<void> _triggerCareAlert(String type) async {
    final Map<String, Map<String, String>> alerts = {
      'water': {
        'message': '💧 വെള്ളം കുടിക്കണം! Patient needs water!',
        'voice': 'Vellam veenam. Caretaker ine ariyikkunnu!',
        'whatsapp': '💧 ALERT: Patient needs WATER immediately!',
        'color': 'blue',
      },
      'food': {
        'message': '🍜 ഭക്ഷണം വേണം! Patient needs food!',
        'voice': 'Bhakshanam veenam. Caretaker ine ariyikkunnu!',
        'whatsapp': '🍜 ALERT: Patient needs FOOD now!',
        'color': 'orange',
      },
      'medicine': {
        'message': '💊 മരുന്ന് സമയമായി! Medicine time!',
        'voice': 'Marunn samayam aayi. Caretaker ine ariyikkunnu!',
        'whatsapp': '💊 ALERT: Patient needs MEDICINE now!',
        'color': 'green',
      },
      'pain': {
        'message': '🤕 വേദന ഉണ്ട്! Patient is in pain!',
        'voice': 'Vedana undu. Undil caretaker ine vilikkunnu!',
        'whatsapp': '🚨 URGENT: Patient is in PAIN! Please come immediately!',
        'color': 'red',
      },
      'stress': {
        'message': '😰 Stress detected! Calming patient...',
        'voice':
            'Ningal relax cheyyuka. Breathe slowly. Amma koode undu. Everything is okay.',
        'whatsapp': '😰 ALERT: Patient is stressed. Please check!',
        'color': 'purple',
      },
    };

    final alert = alerts[type]!;

    // 1. Speak to patient first
    await _speak(alert['voice']!);

    // 2. Send notifications
    await _sendNotification(alert['message']!);

    // 3. WhatsApp all family
    await _sendWhatsAppAlert(alert['whatsapp']!);

    // 4. Update UI
    setState(() => _statusMessage = alert['message']!);
  }

  // 🚨 EMERGENCY — calls + WhatsApp + alarm
  Future<void> _triggerEmergency() async {
    setState(() => _emergencyMode = true);

    // Play loud alarm
    await _audioPlayer.play(
      UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'),
    );

    // Speak emergency
    await _speak(
      'Emergency! Sahayam veenam! Caretaker ine undil vilikkunnu!',
    );

    // Notify all contacts
    for (final contact in _familyContacts) {
      await _sendWhatsAppAlert(
        '🚨🚨 EMERGENCY! ${contact['name']} — '
        'Patient needs IMMEDIATE help! Please come NOW! 🚨🚨',
      );
    }

    // Auto call first family member
    await Future.delayed(const Duration(seconds: 2));
    await _makeEmergencyCall(_familyContacts[0]['phone']!);

    // Send notification
    await _sendNotification('🚨 EMERGENCY! Patient needs help NOW!');
  }

  // 📱 Send local notification
  Future<void> _sendNotification(String message) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'guardian_ai',
        'Guardian AI Alerts',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );
    await _notifications.show(0, '🛡️ Guardian AI Alert', message, details);
  }

  // 💬 WhatsApp alert
  Future<void> _sendWhatsAppAlert(String message) async {
    for (final contact in _familyContacts) {
      final phone = contact['phone']!.replaceAll('+', '');
      final url = 'https://wa.me/$phone?text=${Uri.encodeComponent(message)}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  // 📞 Emergency call
  Future<void> _makeEmergencyCall(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  // ⏰ Medicine timer
  void _startMedicineTimer() {
    _medicineTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final now = TimeOfDay.now();
      final currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      for (final med in _medicineSchedule) {
        if (med['time'] == currentTime && !med['taken']) {
          _triggerCareAlert('medicine');
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _heartController.dispose();
    _medicineTimer?.cancel();
    _continuousListenTimer?.cancel();
    _tts.stop();
    _speech.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _emergencyMode
          ? const Color(0xFF1A0000)
          : const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Row(
          children: [
            Text('🛡️', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Guardian AI',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🚨 Emergency Banner
            if (_emergencyMode)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Color.lerp(Colors.red.shade900,
                        Colors.red.shade700, _pulseController.value),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('🚨', style: TextStyle(fontSize: 48)),
                      const Text(
                        'EMERGENCY ACTIVATED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Calling family + WhatsApp sent!',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white),
                        onPressed: () {
                          _audioPlayer.stop();
                          setState(() => _emergencyMode = false);
                        },
                        child: const Text('Cancel Emergency',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ),

            // 🎙️ Voice Status
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isListening
                        ? const Color(0xFF00FF88)
                            .withOpacity(0.5 + _pulseController.value * 0.5)
                        : const Color(0xFF1E2736),
                    width: _isListening ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _isListening ? '🎙️' : '🎤',
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isListening
                          ? 'Listening... Paranjal mathi!'
                          : 'Voice Guardian OFF',
                      style: TextStyle(
                        color: _isListening
                            ? const Color(0xFF00FF88)
                            : Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_lastHeard.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Heard: "$_lastHeard"',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E2736)),
              ),
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),

            const SizedBox(height: 20),

            // 🟢 Listen Toggle
            GestureDetector(
              onTap: _isListening
                  ? _stopListening
                  : _startContinuousListening,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isListening
                        ? [Colors.red.shade700, Colors.red.shade900]
                        : [
                            const Color(0xFF00FF88),
                            const Color(0xFF00E5FF),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening
                              ? Colors.red
                              : const Color(0xFF00FF88))
                          .withOpacity(0.4),
                      blurRadius: 20,
                    )
                  ],
                ),
                child: Text(
                  _isListening
                      ? '🛑 Stop Listening'
                      : '🎙️ Start Voice Guardian',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔴 Quick Alert Buttons — big for paralysed people
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '⚡ Quick Alerts',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _BigAlertButton(
                  emoji: '💧',
                  label: 'Water\nവെള്ളം',
                  color: Colors.blue,
                  onTap: () => _triggerCareAlert('water'),
                ),
                _BigAlertButton(
                  emoji: '🍜',
                  label: 'Food\nഭക്ഷണം',
                  color: Colors.orange,
                  onTap: () => _triggerCareAlert('food'),
                ),
                _BigAlertButton(
                  emoji: '💊',
                  label: 'Medicine\nമരുന്ന്',
                  color: Colors.green,
                  onTap: () => _triggerCareAlert('medicine'),
                ),
                _BigAlertButton(
                  emoji: '🤕',
                  label: 'Pain\nവേദന',
                  color: Colors.red,
                  onTap: () => _triggerCareAlert('pain'),
                ),
                _BigAlertButton(
                  emoji: '😰',
                  label: 'Stress\nടെൻഷൻ',
                  color: Colors.purple,
                  onTap: () => _triggerCareAlert('stress'),
                ),
                _BigAlertButton(
                  emoji: '🚨',
                  label: 'EMERGENCY\nSOS',
                  color: Colors.red,
                  onTap: _triggerEmergency,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🤕 Pain Level Slider
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E2736)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🤕 ',
                          style: TextStyle(fontSize: 20)),
                      const Text(
                        'Pain Level',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _painLevel > 7
                              ? Colors.red.withOpacity(0.3)
                              : _painLevel > 4
                                  ? Colors.orange.withOpacity(0.3)
                                  : Colors.green.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_painLevel / 10',

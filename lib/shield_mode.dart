import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

class ShieldModeScreen extends StatefulWidget {
  const ShieldModeScreen({super.key});
  @override
  State<ShieldModeScreen> createState() => _ShieldModeScreenState();
}

class _ShieldModeScreenState extends State<ShieldModeScreen> {
  final FlutterTts _tts = FlutterTts();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  bool _fallDetectOn = false;
  bool _accidentDetectOn = false;
  bool _isEmergency = false;
  String _status = 'Shield Mode Ready ⚔️';
  double _lastAccel = 0;
  Timer? _sosCountdown;
  int _countdown = 10;

  StreamSubscription? _accelSub;

  final List<Map<String, String>> _contacts = [
    {'name': 'Emergency Contact 1', 'phone': '+91XXXXXXXXXX'},
  ];

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ml-IN');
    await _tts.setSpeechRate(0.4);
  }

  Future<void> _initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications.initialize(const InitializationSettings(android: android));
  }

  void _startFallDetection() {
    setState(() {
      _fallDetectOn = true;
      _status = '🟢 Fall Detection ACTIVE — Monitoring...';
    });
    _tts.speak('Fall detection started. I am watching.');

    _accelSub = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z
      );

      // Free fall = magnitude near 0, impact = magnitude > 25
      if (magnitude < 2 && _lastAccel > 8) {
        _onFallDetected('free_fall');
      } else if (magnitude > 25) {
        _onFallDetected('impact');
      }
      _lastAccel = magnitude;
    });
  }

  void _stopFallDetection() {
    _accelSub?.cancel();
    setState(() {
      _fallDetectOn = false;
      _status = 'Shield Mode Ready ⚔️';
    });
  }

  void _onFallDetected(String type) {
    if (_isEmergency) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _isEmergency = true;
      _countdown = 10;
      _status = type == 'free_fall'
          ? '⚠️ FALL DETECTED! SOS in 10 seconds...'
          : '⚠️ IMPACT DETECTED! SOS in 10 seconds...';
    });

    _tts.speak('Fall detected! SOS will be sent in 10 seconds. Press cancel to stop.');

    _sosCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        _triggerSOS('Auto-detected: ${type == 'free_fall' ? 'Fall' : 'Impact'}');
      }
    });
  }

  void _cancelAutoSOS() {
    _sosCountdown?.cancel();
    setState(() {
      _isEmergency = false;
      _status = '✅ SOS Cancelled — Monitoring continues...';
    });
    _tts.speak('SOS cancelled. I am still watching.');
  }

  Future<void> _triggerSOS(String reason) async {
    HapticFeedback.heavyImpact();
    setState(() => _status = '🚨 SOS SENT! Help is coming...');
    await _tts.speak('Emergency! SOS sent! Please help!');

    await _notifications.show(
      0,
      '🚨 EMERGENCY SOS',
      reason,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'shield_sos', 'Shield SOS',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
        ),
      ),
    );

    for (final contact in _contacts) {
      final phone = contact['phone']!.replaceAll('+', '');
      final msg = Uri.encodeComponent(
        '🚨 EMERGENCY! Emowall Shield Mode detected: $reason\nPlease help immediately!'
      );
      final url = 'https://wa.me/$phone?text=$msg';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }

    if (_contacts.isNotEmpty) {
      final callUrl = 'tel:${_contacts[0]['phone']}';
      if (await canLaunchUrl(Uri.parse(callUrl))) {
        await launchUrl(Uri.parse(callUrl));
      }
    }

    setState(() => _isEmergency = false);
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _sosCountdown?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isEmergency ? const Color(0xFF1A0000) : const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0F14),
        title: Text('⚔️ Shield Mode', style: GoogleFonts.syne(fontWeight: FontWeight.w800, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // 🚨 Emergency Countdown
          if (_isEmergency)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade900,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                const Text('🚨', style: TextStyle(fontSize: 48)),
                Text('FALL DETECTED!', style: GoogleFonts.syne(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('SOS in $_countdown seconds...', style: GoogleFonts.jetBrainsMono(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                  onPressed: _cancelAutoSOS,
                  child: Text('✋ I AM OK — Cancel SOS', style: GoogleFonts.syne(color: Colors.red, fontWeight: FontWeight.w900)),
                ),
              ]),
            ),

          // Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF111519),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
            ),
            child: Text(_status, textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF8892A4))),
          ),

          // Manual SOS
          GestureDetector(
            onLongPress: () => _triggerSOS('Manual SOS'),
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444).withOpacity(0.15),
                border: Border.all(color: const Color(0xFFEF4444), width: 3),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.sos, color: Color(0xFFEF4444), size: 56),
                Text('HOLD FOR SOS', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: const Color(0xFFEF4444), fontWeight: FontWeight.w700)),
              ]),
            ),
          ),

          const SizedBox(height: 24),

          // Fall Detection Toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111519),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3B82F6).withOpacity(_fallDetectOn ? 0.8 : 0.2)),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('👴 Auto Fall Detection', style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Accelerometer detects falls & sends SOS', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF8892A4))),
                if (_fallDetectOn)
                  Text('● LIVE', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF00E676))),
              ])),
              Switch(
                value: _fallDetectOn,
                onChanged: (v) => v ? _startFallDetection() : _stopFallDetection(),
                activeColor: const Color(0xFF3B82F6),
              ),
            ]),
          ),

          const SizedBox(height: 12),

          // Accident Detection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111519),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00E676).withOpacity(_accidentDetectOn ? 0.8 : 0.2)),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('🚗 Accident Detection', style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: Colors.white)),
                Text('High impact detection → auto SOS', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF8892A4))),
              ])),
              Switch(
                value: _accidentDetectOn,
                onChanged: (v) {
                  setState(() => _accidentDetectOn = v);
                  if (v && !_fallDetectOn) _startFallDetection();
                },
                activeColor: const Color(0xFF00E676),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

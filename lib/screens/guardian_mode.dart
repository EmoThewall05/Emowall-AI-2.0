import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../services/sound_detection_service.dart';
import '../services/verification_chain_service.dart';
import '../services/location_service.dart';
import '../services/alert_service.dart';

class GuardianModeScreen extends StatefulWidget {
  const GuardianModeScreen({super.key});
  @override
  State<GuardianModeScreen> createState() => _GuardianModeScreenState();
}

class _GuardianModeScreenState extends State<GuardianModeScreen> {
  final SoundDetectionService _soundService = SoundDetectionService();
  final VerificationChainService _chainService = VerificationChainService();
  final LocationService _locationService = LocationService();
  final AlertService _alertService = AlertService();

  bool _isActive = false;
  bool _soundDetectOn = false;
  bool _isEmergency = false;
  bool _chainActive = false;
  String _status = '🛡️ Guardian Mode Ready';
  String _chainStatus = '';
  int _sosCountdown = 10;
  Timer? _sosTimer;

  final List<Map<String, String>> _contacts = [
    {'name': 'Parent/Guardian', 'phone': '+91XXXXXXXXXX'},
    {'name': 'Relative', 'phone': '+91XXXXXXXXXX'},
    {'name': 'School Principal', 'phone': '+91XXXXXXXXXX'},
  ];

  @override
  void initState() {
    super.initState();
    _soundService.initialize();
  }

  // 🟢 Activate full protection
  Future<void> _activateProtection() async {
    setState(() {
      _isActive = true;
      _status = '🟢 PROTECTION ACTIVE — Monitoring silently...';
    });

    // Start sound detection
    await _startSoundDetection();

    // Notify via Telegram + Discord
    await _alertService.sendInfoAlert(
      '🟢 Emowall Guardian Mode ACTIVATED\n'
      'Silent monitoring started.\n'
      'Child is protected. 🛡️',
    );
  }

  void _deactivateProtection() {
    _soundService.stopDetection();
    _locationService.stopTracking();
    setState(() {
      _isActive = false;
      _soundDetectOn = false;
      _status = '🛡️ Guardian Mode Ready';
    });
  }

  Future<void> _startSoundDetection() async {
    setState(() => _soundDetectOn = true);

    await _soundService.startDetection((threat) async {
      if (threat.silentMode) {
        // 🔕 Silent — no sound, no screen wake
        await _triggerSilentSOS(threat.message);
      } else {
        // ⚠️ Show alert to child
        await _showThreatAlert(threat.message);
      }
    });
  }

  // 🔕 Silent SOS — attacker never knows
  Future<void> _triggerSilentSOS(String reason) async {
    if (_chainActive) return;
    _chainActive = true;

    // Silent — no vibration, no sound, no screen
    await _chainService.startChain(
      reason: reason,
      onStatusUpdate: (status) {
        if (mounted) {
          setState(() => _chainStatus = status.message);
        }
      },
    );

    // Telegram + Discord silent alert
    await _alertService.sendEmergencyAlert(
      childName: 'Child',
      reason: reason,
      location: 'Live location tracking active',
      country: 'India',
      isFree: true,
    );
  }

  Future<void> _showThreatAlert(String reason) async {
    if (!mounted) return;
    setState(() {
      _isEmergency = true;
      _sosCountdown = 10;
      _status = '⚠️ $reason';
    });

    HapticFeedback.heavyImpact();

    _sosTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _sosCountdown--);
      if (_sosCountdown <= 0) {
        timer.cancel();
        _triggerFullSOS(reason);
      }
    });
  }

  Future<void> _triggerFullSOS(String reason) async {
    setState(() {
      _isEmergency = false;
      _chainActive = true;
      _status = '🚨 SOS TRIGGERED — Verification chain started!';
    });

    // Start verification chain
    await _chainService.startChain(
      reason: reason,
      onStatusUpdate: (status) {
        if (mounted) setState(() => _chainStatus = status.message);
      },
    );

    // Start live GPS
    await _locationService.startLiveTracking(
      contacts: _contacts,
      reason: reason,
    );

    // Telegram + Discord
    await _alertService.sendEmergencyAlert(
      childName: 'Child',
      reason: reason,
      location: 'Live GPS Active',
      country: 'India',
      isFree: true,
    );
  }

  void _cancelSOS() {
    _sosTimer?.cancel();
    setState(() {
      _isEmergency = false;
      _sosCountdown = 10;
      _status = '🟢 PROTECTION ACTIVE — Monitoring silently...';
    });
  }

  // Manual SOS
  Future<void> _manualSOS() async {
    HapticFeedback.heavyImpact();
    await _triggerFullSOS('Manual SOS — Child pressed emergency button');
  }

  @override
  void dispose() {
    _sosTimer?.cancel();
    _soundService.stopDetection();
    _locationService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isEmergency
          ? const Color(0xFF1A0000)
          : const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0F14),
        title: Text('🛡️ Guardian Mode',
            style: GoogleFonts.syne(
                fontWeight: FontWeight.w800, color: Colors.white)),
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
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade900,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                const Text('🚨', style: TextStyle(fontSize: 48)),
                Text('THREAT DETECTED!',
                    style: GoogleFonts.syne(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('SOS in $_sosCountdown seconds...',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50)),
                  onPressed: _cancelSOS,
                  child: Text('✋ I AM SAFE — Cancel SOS',
                      style: GoogleFonts.syne(
                          color: Colors.red, fontWeight: FontWeight.w900)),
                ),
              ]),
            ),

          // Chain Status
          if (_chainStatus.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF5500).withOpacity(0.5)),
              ),
              child: Text(_chainStatus,
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 11, color: const Color(0xFFFF5500))),
            ),

          // Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF111519),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _isActive
                      ? const Color(0xFF00E676).withOpacity(0.5)
                      : const Color(0xFF3B82F6).withOpacity(0.3)),
            ),
            child: Text(_status,
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: _isActive
                        ? const Color(0xFF00E676)
                        : const Color(0xFF8892A4))),
          ),

          // Manual SOS Button
          GestureDetector(
            onLongPress: _manualSOS,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444).withOpacity(0.15),
                border: Border.all(color: const Color(0xFFEF4444), width: 3),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.sos, color: Color(0xFFEF4444), size: 56),
                Text('HOLD FOR SOS',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: const Color(0xFFEF4444),
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          ),

          const SizedBox(height: 24),

          // Activate Protection Toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111519),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF00E676)
                      .withOpacity(_isActive ? 0.8 : 0.2)),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('🛡️ Active Protection',
                    style: GoogleFonts.syne(
                        fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Sound detection + Auto SOS + Chain alert',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 10, color: const Color(0xFF8892A4))),
                if (_isActive)
                  Text('● LIVE — Monitoring silently',
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 10, color: const Color(0xFF00E676))),
              ])),
              Switch(
                value: _isActive,
                onChanged: (v) =>
                    v ? _activateProtection() : _deactivateProtection(),
                activeColor: const Color(0xFF00E676),
              ),
            ]),
          ),

          const SizedBox(height: 12),

          // Sound Detection Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111519),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFFBBF24)
                      .withOpacity(_soundDetectOn ? 0.8 : 0.2)),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('👂 Sound Detection',
                    style: GoogleFonts.syne(
                        fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Detecting threats silently 24/7',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 10, color: const Color(0xFF8892A4))),
              ])),
              Icon(
                _soundDetectOn ? Icons.mic : Icons.mic_off,
                color: _soundDetectOn
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFF8892A4),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // Alert Channels Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111519),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('📡 Alert Channels',
                  style: GoogleFonts.syne(
                      fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 12),
              _alertChannel('📱 WhatsApp', true),
              _alertChannel('✈️ Telegram', true),
              _alertChannel('🎮 Discord', true),
              _alertChannel('🚔 Kerala Police', true),
              _alertChannel('📍 Live GPS', true),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _alertChannel(String name, bool active) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(
          active ? Icons.check_circle : Icons.cancel,
          color: active ? const Color(0xFF00E676) : const Color(0xFF8892A4),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(name,
            style: GoogleFonts.jetBrainsMono(
                fontSize: 12, color: Colors.white70)),
      ]),
    );
  }
}

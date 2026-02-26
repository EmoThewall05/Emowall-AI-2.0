
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class BabyCareMode extends StatefulWidget {
  const BabyCareMode({super.key});

  @override
  State<BabyCareMode> createState() => _BabyCareModeState();
}

class _BabyCareModeState extends State<BabyCareMode>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _accelerometerSub;
  StreamSubscription? _proximitySub;

  bool _babyModeActive = false;
  bool _dangerDetected = false;
  String _statusMessage = 'Baby Mode Ready 👶';
  late AnimationController _pulseController;
  late AnimationController _butterflyController;

  // 🎵 Lullaby songs list
  final List<String> _lullabies = [
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    // Add more lullaby URLs here
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _butterflyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  // 🍼 Start Baby Protection
  void _activateBabyMode() {
    setState(() {
      _babyModeActive = true;
      _statusMessage = '👶 Baby Mode ON — Watching...';
    });

    // 📱 Freefall Detection (phone dropped)
    _accelerometerSub = userAccelerometerEventStream().listen((event) {
      final total = event.x.abs() + event.y.abs() + event.z.abs();

      // Freefall = all axes near zero
      if (total < 2.0 && _babyModeActive) {
        _triggerDangerAlert('📱 Phone Dropped! Baby Alert! 🚨');
      }

      // Shaking detection (baby playing with phone)
      if (total > 25.0 && _babyModeActive) {
        _triggerDangerAlert('🤚 Baby Shaking Phone! 🚨');
      }
    });
  }

  // 🚨 Danger Alert
  void _triggerDangerAlert(String message) {
    if (_dangerDetected) return; // prevent spam
    setState(() {
      _dangerDetected = true;
      _statusMessage = message;
    });

    // Play crying sound / lullaby
    _playCryingMode();

    // Auto reset after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _dangerDetected = false;
          _statusMessage = '👶 Baby Mode ON — Watching...';
        });
      }
    });
  }

  // 🎵 Auto play lullaby when baby cries
  Future<void> _playCryingMode() async {
    await _audioPlayer.play(UrlSource(_lullabies[0]));
  }

  void _deactivateBabyMode() {
    _accelerometerSub?.cancel();
    _audioPlayer.stop();
    setState(() {
      _babyModeActive = false;
      _dangerDetected = false;
      _statusMessage = 'Baby Mode Ready 👶';
    });
  }

  @override
  void dispose() {
    _accelerometerSub?.cancel();
    _proximitySub?.cancel();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _butterflyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dangerDetected
          ? const Color(0xFF1A0000)
          : const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Row(
          children: [
            Text('👶', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Baby Care Mode',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🚨 Danger Alert Banner
            if (_dangerDetected)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      const Color(0xFFFF0000),
                      const Color(0xFF880000),
                      _pulseController.value,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('🚨', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(
                        _statusMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Playing lullaby to calm baby... 🎵',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

            // 🦋 Butterfly Animation for baby
            AnimatedBuilder(
              animation: _butterflyController,
              builder: (_, __) => Transform.scale(
                scale: 1.0 + (_butterflyController.value * 0.1),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: _babyModeActive
                          ? [
                              const Color(0xFF00FF88).withOpacity(0.3),
                              const Color(0xFF00E5FF).withOpacity(0.1),
                              Colors.transparent,
                            ]
                          : [
                              const Color(0xFF7C3AED).withOpacity(0.2),
                              Colors.transparent,
                            ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _babyModeActive ? '🦋' : '👶',
                      style: const TextStyle(fontSize: 72),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _babyModeActive
                      ? const Color(0xFF00FF88).withOpacity(0.5)
                      : const Color(0xFF1E2736),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _babyModeActive
                          ? const Color(0xFF00FF88)
                          : Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_babyModeActive) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF00FF88)),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔘 Activate Button
            GestureDetector(
              onTap: _babyModeActive
                  ? _deactivateBabyMode
                  : _activateBabyMode,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _babyModeActive
                        ? [const Color(0xFFFF3366), const Color(0xFF7C3AED)]
                        : [const Color(0xFF00E5FF), const Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_babyModeActive
                              ? const Color(0xFFFF3366)
                              : const Color(0xFF00E5FF))
                          .withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Text(
                  _babyModeActive
                      ? '🛑 Deactivate Baby Mode'
                      : '👶 Activate Baby Mode',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 📚 Baby Education Cards
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📚 Baby Learning Corner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: const [
                _BabyCard(emoji: '🔴', label: 'Red', color: Colors.red),
                _BabyCard(emoji: '💛', label: 'Yellow', color: Colors.yellow),
                _BabyCard(emoji: '🐘', label: 'Elephant', color: Color(0xFF7C3AED)),
                _BabyCard(emoji: '🦁', label: 'Lion', color: Colors.orange),
                _BabyCard(emoji: 'A', label: 'Apple', color: Color(0xFF00E5FF)),
                _BabyCard(emoji: 'B', label: 'Ball', color: Color(0xFF00FF88)),
              ],
            ),

            const SizedBox(height: 20),

            // ⚠️ Safety Warning
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Text('⚠️', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Never leave baby alone with phone.\nThis mode helps but does not replace supervision.',
                      style: TextStyle(color: Colors.amber, fontSize: 12),
                    ),
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

// 📚 Baby Education Card
class _BabyCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _BabyCard({
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

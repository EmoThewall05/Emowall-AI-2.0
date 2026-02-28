// lib/baby/digital_amma.dart
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:math';

class DigitalAmmaScreen extends StatefulWidget {
  const DigitalAmmaScreen({super.key});

  @override
  State<DigitalAmmaScreen> createState() => _DigitalAmmaScreenState();
}

class _DigitalAmmaScreenState extends State<DigitalAmmaScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  StreamSubscription? _accelerometerSub;

  bool _babyModeActive = false;
  bool _isCrying = false;
  bool _isSpecialMode = false;
  String _currentMood = 'happy';
  String _ammaMessage = 'Amma ithunde kuttiye! 🤗';
  String _selectedLanguage = 'both';
  late AnimationController _heartController;
  late AnimationController _glowController;
  late AnimationController _bounceController;

  // 🎵 Malayalam + English Lullabies
  final Map<String, List<Map<String, String>>> _lullabies = {
    'malayalam': [
      {
        'title': 'Omanathingal Kidavo',
        'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      },
      {
        'title': 'Kattu Mayamayil',
        'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      },
    ],
    'english': [
      {
        'title': 'Twinkle Twinkle',
        'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      },
      {
        'title': 'Rock a bye Baby',
        'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      },
    ],
  };

  // 💬 Amma Messages — Malayalam + English
  final Map<String, List<String>> _ammaMessages = {
    'comfort': [
      'Kuttiye... Amma ithunde, kandalle! Karayanda mole/mone 🤱',
      'Shh shh... Everything is okay baby! Amma is here 💕',
      'Ningal valare brave anu! You are so strong! 💪',
      'Karyamilla ketto! Amma padicchu tharum 📚',
    ],
    'phone_warning': [
      'Ayo! Phone vayilidal amma sammadhikkilla! 🚫',
      'No no baby! Phone dirty aanu, vayilidal venda! 🤧',
      'Phones are not food baby! Amma toys tharunn! 🧸',
      'Careful kuttiye! Phone tharayil idanda! 📱',
    ],
    'motivation': [
      'Ningal valare budhhimanu! You are so smart! 🧠✨',
      'Wow! Kuttiku ithu ariyam! Baby genius aanu! 🌟',
      'Very good! Adipoli! Keep trying baby! 👏',
      'Amma proud aanu ningalude! I am proud of you! 🏆',
    ],
    'autism_support': [
      'Take your time kuttiye, no rush at all 🌈',
      'You are perfect just the way you are! 💜',
      'Breathe slowly baby... in and out... 🌬️',
      'Amma always loves you, every single day 💕',
    ],
    'learning': [
      'Ningal nannaayi padikkunnu! Great learning! 📖',
      'One more time try cheyyam, you can do it! 💪',
      'Smart baby! So clever you are! 🌟',
      'Adipoli! Excellent work today! 🎉',
    ],
  };

  @override
  void initState() {
    super.initState();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _setupTTS();
  }

  Future<void> _setupTTS() async {
    await _tts.setLanguage('ml-IN'); // Malayalam default
    await _tts.setSpeechRate(0.4); // Slow and gentle for babies
    await _tts.setPitch(1.3); // Higher pitch — amma voice
    await _tts.setVolume(0.9);
  }

  // 🗣️ Amma speaks to baby
  Future<void> _ammaSpeak(String category) async {
    final messages = _ammaMessages[category]!;
    final msg = messages[Random().nextInt(messages.length)];
    setState(() => _ammaMessage = msg);

    // Switch language based on message content heuristics
    if (msg.contains('baby') || msg.contains('you') || msg.contains('Everything')) {
      await _tts.setLanguage('en-US');
    } else {
      await _tts.setLanguage('ml-IN');
    }
    await _tts.speak(msg);
  }

  // 😢 Baby crying detected — Auto song + Amma speaks
  Future<void> _babyCryingDetected() async {
    if (_isCrying) return;
    setState(() {
      _isCrying = true;
      _currentMood = 'crying';
      _ammaMessage = 'Karayanda kuttiye... Amma paattu paadunnu 🎵';
    });

    // Amma speaks first
    await _ammaSpeak('comfort');

    // Then play lullaby
    await _playLullaby();
  }

  // 🎵 Smart Lullaby Player
  Future<void> _playLullaby() async {
    List<Map<String, String>> songs = [];

    if (_selectedLanguage == 'both' || _selectedLanguage == 'malayalam') {
      songs.addAll(_lullabies['malayalam']!);
    }
    if (_selectedLanguage == 'both' || _selectedLanguage == 'english') {
      songs.addAll(_lullabies['english']!);
    }

    if (songs.isEmpty) return;

    final song = songs[Random().nextInt(songs.length)];
    setState(() => _ammaMessage = '🎵 Playing: ${song['title']}');

    try {
      await _audioPlayer.play(UrlSource(song['url']!));
    } catch (_) {
      // ignore play errors silently; keep UI responsive
    }

    // Auto stop after 3 minutes
    Future.delayed(const Duration(minutes: 3), () {
      if (mounted && _isCrying) {
        _audioPlayer.stop();
        setState(() => _isCrying = false);
      }
    });
  }

  // 📱 Phone protection sensors
  void _startSensors() {
    _accelerometerSub = userAccelerometerEventStream().listen((event) {
      final total = event.x.abs() + event.y.abs() + event.z.abs();

      // Freefall = phone dropped
      if (total < 1.5 && _babyModeActive) {
        _ammaSpeak('phone_warning');
        setState(() => _ammaMessage = '📱 Phone dropped! Careful kuttiye! 🚨');
      }

      // Heavy shake = baby playing rough
      if (total > 28.0 && _babyModeActive) {
        _ammaSpeak('phone_warning');
      }
    });
  }

  void _activateBabyMode() {
    setState(() => _babyModeActive = true);
    _startSensors();
    _ammaSpeak('comfort');
  }

  void _deactivateBabyMode() {
    _accelerometerSub?.cancel();
    _audioPlayer.stop();
    _tts.stop();
    setState(() {
      _babyModeActive = false;
      _isCrying = false;
      _currentMood = 'happy';
      _ammaMessage = 'Amma ithunde kuttiye! 🤗';
    });
  }

  @override
  void dispose() {
    _accelerometerSub?.cancel();
    _audioPlayer.dispose();
    _tts.stop();
    _heartController.dispose();
    _glowController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isCrying
          ? const Color(0xFF0A0015)
          : _isSpecialMode
              ? const Color(0xFF000A1A)
              : const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text(
          '👩‍👶 Digital Amma',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Special mode toggle
          GestureDetector(
            onTap: () => setState(() => _isSpecialMode = !_isSpecialMode),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _isSpecialMode
                    ? const Color(0xFF7C3AED).withOpacity(0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isSpecialMode
                      ? const Color(0xFF7C3AED)
                      : Colors.white24,
                ),
              ),
              child: Text(
                _isSpecialMode ? '🌈 Special ON' : '🌈 Special',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 👩 Amma Face Animation
            AnimatedBuilder(
              animation: _glowController,
              builder: (_, __) => Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isSpecialMode
                              ? const Color(0xFF7C3AED)
                              : _isCrying
                                  ? Colors.pink
                                  : const Color(0xFF00FF88))
                          .withOpacity(0.3 + _glowController.value * 0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ],
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _bounceController,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, _bounceController.value * 5),
                      child: Text(
                        _isCrying ? '🤱' : _isSpecialMode ? '🌈' : '👩‍👶',
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 💬 Amma Message Box
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isSpecialMode
                    ? const Color(0xFF7C3AED).withOpacity(0.15)
                    : const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isSpecialMode
                      ? const Color(0xFF7C3AED).withOpacity(0.5)
                      : _isCrying
                          ? Colors.pink.withOpacity(0.5)
                          : const Color(0xFF00FF88).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _heartController,
                    builder: (_, __) => Transform.scale(
                      scale: 1.0 + _heartController.value * 0.2,
                      child: const Text('💕',
                          style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _ammaMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🎮 Action Buttons Row
            Row(
              children: [
                // Baby crying button
                Expanded(
                  child: _ActionButton(
                    emoji: '😢',
                    label: 'Baby Crying',
                    color: Colors.pink,
                    onTap: _babyCryingDetected,
                  ),
                ),
                const SizedBox(width: 12),
                // Motivation button
                Expanded(
                  child: _ActionButton(
                    emoji: '⭐',
                    label: 'Motivate',
                    color: Colors.amber,
                    onTap: () => _ammaSpeak('motivation'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                // Learning button
                Expanded(
                  child: _ActionButton(
                    emoji: '📚',
                    label: 'Learning',
                    color: const Color(0xFF00E5FF),
                    onTap: () => _ammaSpeak('learning'),
                  ),
                ),
                const SizedBox(width: 12),
                // Calm button (autism support)
                Expanded(
                  child: _ActionButton(
                    emoji: '🌈',
                    label: 'Calm Down',
                    color: const Color(0xFF7C3AED),
                    onTap: () => _ammaSpeak('autism_support'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🌈 Special Needs / Autism Mode
            if (_isSpecialMode) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF7C3AED).withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🌈 Special Care Mode',
                      style: TextStyle(
                        color: Color(0xFF7C3AED),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Every child is unique and beautiful 💜\nAm here to support at their own pace.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    // Breathing exercise
                    GestureDetector(
                      onTap: () async {
                        await _tts.setLanguage('ml-IN');
                        await _tts.speak(
                          'Okay kuttiye... slowly breathe in... '
                          'and breathe out... '
                          'Ningal valare brave aanu... '
                          'Amma love cheyyunnu...',
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🌬️', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 10),
                            Text(
                              'Breathing Exercise\nNingalkku vendi...',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 📱 Visual Learning Cards
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '👁️ Visual Learning',
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
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _LearningCard(
                  emoji: '🌞',
                  word: 'Sun / Suryyan',
                  color: Colors.orange,
                  onTap: () async {
                    await _tts.setLanguage('ml-IN');
                    await _tts.speak('Suryyan! Sun! Valare nannaayi!');
                  },
                ),
                _LearningCard(
                  emoji: '🌙',
                  word: 'Moon / Chandran',
                  color: Colors.blue,
                  onTap: () async {
                    await _tts.speak('Chandran! Moon! Smart baby!');
                  },
                ),
                _LearningCard(
                  emoji: '⭐',
                  word: 'Star / Nakshathram',
                  color: Colors.amber,
                  onTap: () async {
                    await _tts.speak('Nakshathram! Star! Adipoli!');
                  },
                ),
                _LearningCard(
                  emoji: '🐘',
                  word: 'Elephant / Aana',
                  color: Colors.grey,
                  onTap: () async {
                    await _tts.speak('Aana! Elephant! Very good kuttiye!');
                  },
                ),
                _LearningCard(
                  emoji: '🦋',
                  word: 'Butterfly / Choola',
                  color: const Color(0xFF00E5FF),
                  onTap: () async {
                    await _tts.speak('Choola! Butterfly! Beautiful!');
                  },
                ),
                _LearningCard(
                  emoji: '🌸',
                  word: 'Flower / Poov',
                  color: Colors.pink,
                  onTap: () async {
                    await _tts.speak('Poov! Flower! Ningal valare smart!');
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🟢 Main Activate Button
            GestureDetector(
              onTap: _babyModeActive ? _deactivateBabyMode : _activateBabyMode,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _babyModeActive
                        ? [Colors.red.shade700, Colors.red.shade900]
                        : [
                            const Color(0xFF00FF88),
                            const Color(0xFF00E5FF),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_babyModeActive ? Colors.red : const Color(0xFF00FF88))
                          .withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Text(
                  _babyModeActive
                      ? '🛑 Deactivate Amma Mode'
                      : '👩‍👶 Activate Digital Amma',
                  textAlign: TextAl

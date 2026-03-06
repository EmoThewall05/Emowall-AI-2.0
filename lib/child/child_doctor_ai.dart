// lib/child/child_doctor_ai.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';

class ChildDoctorAI extends StatefulWidget {
  const ChildDoctorAI({super.key});

  @override
  State<ChildDoctorAI> createState() => _ChildDoctorAIState();
}

class _ChildDoctorAIState extends State<ChildDoctorAI>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Child profile
  String _childName = 'Kuttiye';
  int _childAge = 5;
  int _moodScore = 5;
  int _screenTimeMinutes = 0;
  int _rewardStars = 0;
  bool _isListening = false;
  bool _therapyMode = false;
  String _currentCondition = 'normal';
  String _aiMessage = 'Namaste! Emowall Doctor ithunde! 👨‍⚕️';
  String _lastHeard = '';

  // Screen time tracker
  Timer? _screenTimer;
  Timer? _speechTimer;
  late AnimationController _starController;
  late AnimationController _bounceController;
  late AnimationController _glowController;

  // 📊 Daily progress tracking
  final Map<String, bool> _dailyProgress = {
    'Talked to AI': false,
    'Breathing done': false,
    'Story listened': false,
    'No phone 1hr': false,
    'Good sleep': false,
  };

  // 🎭 Mood history
  final List<Map<String, dynamic>> _moodHistory = [];

  // 💬 AI Messages for each condition
  final Map<String, List<String>> _conditionMessages = {
    'speech_delay': [
      'Kuttiye, paranjal mathi! Slowly paranju nokku 🗣️',
      'Very good! Oru word koode paranjal mathi! 🌟',
      'Ningal valare nannaayi try cheyyunnu! Keep going! 💪',
      'Amma parayunnapole paranjal mathi, no hurry! 🤗',
      'Wow! That was perfect! Try one more time! ⭐',
    ],
    'anxiety': [
      'Ningal safe aanu kuttiye. Emowall koode undu 🤗',
      'Breathe slowly... in... and out... very good! 🌬️',
      'Ningalude fear normal aanu. Ellavarum afraid aakum 💜',
      'Brave baby! Nothing can hurt you here! 🦁',
      'Close your eyes... imagine a happy place... 🌈',
    ],
    'sleep': [
      'Ipo uyakkam varum kuttiye... eyes close cheyyuka 😴',
      'Stars are watching over you tonight 🌟',
      'Amma koode undu, safe aanu... sleep now 🌙',
      'Count with me... 1... 2... 3... slowly... 💤',
      'Tomorrow will be a beautiful day! Rest now 🌸',
    ],
    'anger': [
      'Okay okay... breathe first! In... out... 🌬️',
      'Ningal frustrated aanu, athu okay aanu 😊',
      'Count to 10 with me! 1... 2... 3... calm down 🧘',
      'Tell me what happened? Emowall kelkkam! 👂',
      'Angry feelings pass like clouds! 🌤️',
    ],
    'emotional': [
      'Ningal parayunnathu ഞാൻ kelkkuanu kuttiye 💕',
      'Cry cheyyal괜찮아... tears are okay! 😢',
      'You are loved so much! Amma loves you! 💜',
      'Tell me everything... safe space anu ithu! 🤗',
      'Tomorrow will be better, I promise! 🌈',
    ],
    'mobile_addiction': [
      'Kuttiye, phone vechu! Nature nokku! 🌿',
      'Eyes rest cheyyuka! 5 minutes break! 👀',
      'Real games are more fun! Go play outside! ⚽',
      'Phone break = Star reward! Ready? ⭐',
      'Ningalude eyes valare important! Care cheyyuka! 💚',
    ],
    'normal': [
      'Namaste kuttiye! Enthu parayano? 😊',
      'Today enthokke cheytu? Tell me! 🌟',
      'Ningal valare special aanu! Remember that! 💜',
      'Ready for a story? Game? Music? 🎮📚🎵',
    ],
  };

  // 📚 Malayalam + English Stories
  final List<Map<String, String>> _stories = [
    {
      'title': 'The Brave Little Star ⭐',
      'content':
          'Once upon a time, oru chinna star undayirunnu... '
          'Athu valare afraid ayirunnu darkness ine... '
          'Pakshey oru divasam, athu decide cheytu... '
          'SHINE cheyyaan! Angane athu ellavarudeyum light aayi! '
          'Ningalum aa star aanu kuttiye! Brave aanu ningal! 🌟',
    },
    {
      'title': 'Kutty Elephant 🐘',
      'content':
          'Oru kutty aanaye undayirunnu, athu parayan try cheyyum... '
          'Munpil sheriyaayi paranjillayirunnu... '
          'Pakshey every day practice cheytu... '
          'Oru divasam... perfect aayi paranju! '
          'Practice makes perfect kuttiye! 🎉',
    },
    {
      'title': 'Rainbow After Rain 🌈',
      'content':
          'Mazha peyyumbol kuttikalk sad aakum... '
          'Pakshey mazha kazhinjal rainbow varum! '
          'Ningalude sadness polum mazha pole aanu... '
          'Kazhinjal happiness rainbow varum! '
          'Always hope keep cheyyuka kuttiye! 🌈💜',
    },
  ];

  // 🎮 Therapy Games
  final List<Map<String, dynamic>> _therapyGames = [
    {
      'name': 'Breathing Star 🌬️',
      'description': 'Breathe in when star grows, out when shrinks',
      'type': 'breathing',
      'color': Colors.blue,
    },
    {
      'name': 'Happy Words 😊',
      'description': 'Say happy words and earn stars!',
      'type': 'speech',
      'color': Colors.amber,
    },
    {
      'name': 'Calm Colors 🎨',
      'description': 'Draw your feelings with colors',
      'type': 'drawing',
      'color': Colors.purple,
    },
    {
      'name': 'Music Mood 🎵',
      'description': 'Listen and feel better instantly',
      'type': 'music',
      'color': Colors.green,
    },
  ];

  // 👨‍⚕️ Doctor recommendations based on condition
  final Map<String, List<String>> _doctorAdvice = {
    'speech_delay': [
      '📋 See Speech Therapist if delay > 6 months',
      '🏥 Audiologist check recommended',
      '💊 No medication needed — therapy works!',
      '⏰ Daily 20min practice session recommended',
    ],
    'anxiety': [
      '📋 Child Psychologist consultation if severe',
      '🧘 Daily breathing exercises — 10 mins',
      '😴 Proper sleep schedule essential',
      '🚫 Reduce screen time before bed',
    ],
    'mobile_addiction': [
      '📱 Max 1hr screen time for under 5',
      '📱 Max 2hr screen time for 6-12 years',
      '🌿 Outdoor play minimum 1hr daily',
      '📋 See Pediatrician if addiction severe',
    ],
    'sleep': [
      '😴 Fixed sleep time 8:30 PM recommended',
      '📵 No screens 1hr before sleep',
      '🎵 Soft music helps sleep',
      '📋 Pediatrician if sleep issues > 2 weeks',
    ],
  };

  @override
  void initState() {
    super.initState();

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initTTS();
    _startScreenTimer();
    _welcome();
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage('ml-IN');
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.4); // Child-friendly high pitch
    await _tts.setVolume(1.0);
  }

  Future<void> _welcome() async {
    await Future.delayed(const Duration(seconds: 1));
    await _speak(
      'Namaste $_childName! Emowall Doctor ithunde! '
      'Ningalkku enthu feel aakunu today?',
    );
  }

  // 🗣️ AI Doctor speaks
  Future<void> _speak(String text) async {
    setState(() => _aiMessage = text);
    if (text.contains('baby') || text.contains('you') ||
        text.contains('star') || text.contains('perfect')) {
      await _tts.setLanguage('en-US');
    } else {
      await _tts.setLanguage('ml-IN');
    }
    await _tts.speak(text);
  }

  // 👂 Listen to child
  Future<void> _startListening() async {
    final available = await _speech.initialize();
    if (!available) return;

    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          setState(() => _lastHeard = result.recognizedWords);
          _analyzeChildSpeech(result.recognizedWords.toLowerCase());
        }
      },
      listenFor: const Duration(seconds: 10),
      localeId: 'ml_IN',
    );
  }

  // 🧠 AI analyzes what child says
  void _analyzeChildSpeech(String speech) {
    setState(() => _isListening = false);

    // Detect emotions and conditions
    if (speech.contains('sad') || speech.contains('cry') ||
        speech.contains('kadikkunnu') || speech.contains('വിഷമം')) {
      _setCondition('emotional');
      _addRewardStar('Talked about feelings!');
    } else if (speech.contains('scared') || speech.contains('afraid') ||
        speech.contains('bhayam') || speech.contains('ഭയം')) {
      _setCondition('anxiety');
    } else if (speech.contains('angry') || speech.contains('ദേഷ്യം') ||
        speech.contains('ദേഷ്യം')) {
      _setCondition('anger');
    } else if (speech.contains('phone') || speech.contains('game') ||
        speech.contains('youtube')) {
      _setCondition('mobile_addiction');
    } else if (speech.contains('sleep') || speech.contains('uyakkam') ||
        speech.contains('ഉറക്കം')) {
      _setCondition('sleep');
    } else {
      // Normal conversation — respond with encouragement
      _speak(
        'Valare nannaayi paranju kuttiye! '
        'You are doing great! One more star! ⭐',
      );
      _addRewardStar('Talked to Doctor!');
    }
  }

  // 🔄 Set condition and respond
  void _setCondition(String condition) {
    setState(() => _currentCondition = condition);
    final messages = _conditionMessages[condition]!;
    final msg = messages[Random().nextInt(messages.length)];
    _speak(msg);

    // Add to mood history
    _moodHistory.add({
      'condition': condition,
      'time': DateTime.now().toString().substring(11, 16),
    });
  }

  // ⭐ Reward system
  void _addRewardStar(String reason) {
    setState(() => _rewardStars++);
    _starController.forward(from: 0);
    _speak('⭐ Star earned! $_rewardStars stars total! $reason Great job!');

    // Daily progress update
    if (_rewardStars % 5 == 0) {
      _speak(
        'WOW! $_rewardStars stars! '
        'Ningal valare good child aanu! 🏆',
      );
    }
  }

  // ⏱️ Screen time tracker
  void _startScreenTimer() {
    _screenTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _screenTimeMinutes++);

      // Warnings at intervals
      if (_screenTimeMinutes == 30) {
        _speak(
          'Kuttiye! 30 minutes aayi! '
          'Eyes rest cheyyuka, 5 minutes break! 👀',
        );
      } else if (_screenTimeMinutes == 60) {
        _speak(
          'One hour aayi! Phone vechu! '
          'Go play outside! ⚽ Star reward waiting!',
        );
        _setCondition('mobile_addiction');
      } else if (_screenTimeMinutes == 120) {
        _speak(
          'Kuttiye! 2 hours screen time limit reached! '
          'Parents ine ariyikkunnu! 📱',
        );
      }
    });
  }

  // 🌬️ Breathing therapy
  Future<void> _startBreathingTherapy() async {
    setState(() => _therapyMode = true);
    await _speak('Okay kuttiye! Breathing game thodangam!');
    await Future.delayed(const Duration(seconds: 2));
    for (int i = 0; i < 5; i++) {
      await _speak('Breathe IN slowly... 1... 2... 3...');
      await Future.delayed(const Duration(seconds: 3));
      await _speak('Now breathe OUT... 1... 2... 3...');
      await Future.delayed(const Duration(seconds: 3));
    }
    await _speak(
      'Perfect! Valare nannaayi cheytu kuttiye! '
      'Feel better now? ⭐',
    );
    _addRewardStar('Breathing exercise completed!');
    setState(() => _therapyMode = false);
    setState(() => _dailyProgress['Breathing done'] = true);
  }

  // 📚 Story therapy
  Future<void> _tellStory(Map<String, String> story) async {
    await _speak('Oru story paranjal mathi! Ready? 📚');
    await Future.delayed(const Duration(seconds: 1));
    await _speak(story['content']!);
    await Future.delayed(const Duration(seconds: 2));
    await _speak(
      'Story kazhinju! Did you like it? '
      'Ningalkkum oru star! ⭐',
    );
    _addRewardStar('Listened to story!');
    setState(() => _dailyProgress['Story listened'] = true);
  }

  @override
  void dispose() {
    _starController.dispose();
    _bounceController.dispose();
    _glowController.dispose();
    _screenTimer?.cancel();
    _speechTimer?.cancel();
    _tts.stop();
    _speech.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Row(
          children: [
            Text('👨‍⚕️', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Child Doctor AI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Stars display
          AnimatedBuilder(
            animation: _starController,
            builder: (_, __) => Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  const Text('⭐'),
                  Text(
                    ' $_rewardStars',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 👨‍⚕️ Doctor Avatar
            AnimatedBuilder(
              animation: _glowController,
              builder: (_, __) => Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(
                        0.2 + _glowController.value * 0.3,
                      ),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _bounceController,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(
                        0, _bounceController.value * 5,
                      ),
                      child: Text(
                        _currentCondition == 'anxiety'
                            ? '🤗'
                            : _currentCondition == 'anger'
                                ? '😌'
                                : _currentCondition == 'sleep'
                                    ? '🌙'
                                    : _currentCondition == 'emotional'
                                        ? '💜'
                                        : '👨‍⚕️',
                        style: const TextStyle(fontSize: 70),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 💬 AI Doctor Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Text('💬', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text(
                    _aiMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  if (_lastHeard.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'You said: "$_lastHeard"',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 😊 Mood Check
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E2736)),
              ),
              child: Column(
                children: [
                  const Text(
                    '😊 How do you feel today?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MoodButton('😭', 1, _moodScore, (v) {
                        setState(() => _moodScore = v);
                        _setCondition('emotional');
                      }),
                      _MoodButton('😢', 3, _moodScore, (v) {
                        setState(() => _moodScore = v);
                        _setCondition('anxiety');
                      }),
                      _MoodButton('😐', 5, _moodScore, (v) {
                        setState(() => _moodScore = v);
                        _setCondition('normal');
                      }),
                      _MoodButton('😊', 7, _moodScore, (v) {
                        setState(() => _moodScore = v);
                        _speak('Wow! Happy aanu! ⭐ Star for you!');
                        _addRewardStar('Happy today!');
                      }),
                      _MoodButton('🤩', 10, _moodScore, (v) {
                        setState(() => _moodScore = v);
                        _speak(
                          'AMAZING! Adipoli! '
                          'Super happy! 2 stars for you! 🌟🌟',
                        );
                        _addRewardStar('Super happy!');
                        _addRewardStar('Excellent mood!');
                      }),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🎙️ Talk to Doctor
            GestureDetector(
              onTap: _isListening ? null : _startListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isListening
                        ? [Colors.red.shade700, Colors.red.shade900]
              

                        : [const Color(0xFF00E5FF), const Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _isListening ? '🛑 Stop Listening' : '🎙️ Talk to Doctor',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  final String emoji;
  final int value;
  final int current;
  final Function(int) onTap;

  const _MoodButton(this.emoji, this.value, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.white38 : Colors.transparent,
          ),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}

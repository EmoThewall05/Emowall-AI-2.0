import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';

class ButterflyAICharacter extends StatefulWidget {
  const ButterflyAICharacter({super.key});

  @override
  State<ButterflyAICharacter> createState() => _ButterflyAICharacterState();
}

class _ButterflyAICharacterState extends State<ButterflyAICharacter> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // പൂക്കളുടെ സ്ഥാനങ്ങൾ
  final List<Offset> flowerPositions = [
    const Offset(50, 150),
    const Offset(280, 400),
    const Offset(120, 650),
  ];

  // ഓരോ പൂവിലും ബട്ടർഫ്ലൈക്ക് കിട്ടേണ്ട നിറം
  final List<Color> butterflyColors = [
    Colors.pinkAccent,
    Colors.yellowAccent,
    Colors.purpleAccent,
  ];

  int currentTarget = 0;

  @override
  void initState() {
    super.initState();
    _startMovement();
  }

  void _startMovement() async {
    Future.doWhile(() async {
      await Future.delayed(4.seconds);
      if (mounted) {
        setState(() {
          currentTarget = (currentTarget + 1) % flowerPositions.length;
        });
        _playFlapSound();
      }
      return true;
    });
  }

  void _playFlapSound() async {
    try {
      await _audioPlayer.play(AssetSource('wing.wav'));
    } catch (e) {
      debugPrint("Sound play error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // പൂക്കൾ
        _buildFlower(flowerPositions[0], Colors.pink),
        _buildFlower(flowerPositions[1], Colors.yellow),
        _buildFlower(flowerPositions[2], Colors.purple),

        // പറക്കുന്ന ബട്ടർഫ്ലൈ
        AnimatedPositioned(
          duration: 2500.ms,
          curve: Curves.easeInOutCubic,
          left: flowerPositions[currentTarget].dx,
          top: flowerPositions[currentTarget].dy - 40,
          child: _buildButterfly(),
        ),
      ],
    );
  }

  Widget _buildFlower(Offset pos, Color color) {
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: Icon(Icons.local_florist, size: 50, color: color.withOpacity(0.8)),
    );
  }

  Widget _buildButterfly() {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        butterflyColors[currentTarget].withOpacity(0.5),
        BlendMode.modulate,
      ),
      child: Image.asset(
        'assets/orange_cyan_butterfly.png',
        width: 80,
        height: 80,
      ),
    )
    .animate(onPlay: (c) => c.repeat())
    .scaleXY(begin: 1.0, end: 0.7, duration: 400.ms, curve: Curves.easeInOut)
    .then()
    .shake(hz: 2);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

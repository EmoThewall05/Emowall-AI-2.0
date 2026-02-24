import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const EmowallApp());
}

// ─── App Entry ────────────────────────────────────────
class EmowallApp extends StatelessWidget {
  const EmowallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emowall AI 2.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF07080B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFF7C3AED),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ─── Splash Screen ────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ButterflyLogo(size: 100),
              const SizedBox(height: 28),
              const Text(
                'Emowall AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'version 2.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF00E5FF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Home Screen ──────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ChatScreen(),
    const RepairScreen(),
    const WalletScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        title: const Row(
          children: [
            ButterflyLogo(size: 32),
            SizedBox(width: 10),
            Text(
              'Emowall AI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(width: 8),
            _LiveBadge(),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0D1117),
        indicatorColor: const Color(0xFF00E5FF).withOpacity(0.2),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: Color(0xFF00E5FF)),
            label: 'AI Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build, color: Color(0xFF00E5FF)),
            label: 'Repair',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet,
                color: Color(0xFF00E5FF)),
            label: 'Wallet',
          ),
        ],
      ),
    );
  }
}

// ─── Chat Screen ──────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _loading = true;
    });
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('${const String.fromEnvironment('API_BASE')}/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text, 'history': _messages}),
      );
      final data = jsonDecode(response.body);
      setState(() {
        _messages.add({'role': 'assistant', 'content': data['reply']});
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': 'Connection error. Please try again! 😅'
        });
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ButterflyLogo(size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'Hi! I am Emowall AI 👋',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) {
                    final msg = _messages[i];
                    final isUser = msg['role'] == 'user';
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? const Color(0xFF00E5FF).withOpacity(0.15)
                              : const Color(0xFF0D1117),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isUser
                                ? const Color(0xFF00E5FF).withOpacity(0.3)
                                : const Color(0xFF1E2736),
                          ),
                        ),
                        child: Text(
                          msg['content']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(
              color: Color(0xFF00E5FF),
              strokeWidth: 2,
            ),
          ),
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF0D1117),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ask Emowall AI...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFF1E2736)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFF1E2736)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          const BorderSide(color: Color(0xFF00E5FF)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _sendMessage(_controller.text),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Repair Screen ────────────────────────────────────
class RepairScreen extends StatelessWidget {
  const RepairScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '🔧 Repair Booking\nComing Soon',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18),
      ),
    );
  }
}

// ─── Wallet Screen ────────────────────────────────────
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '💰 TheWall Crypto\nComing Soon',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18),
      ),
    );
  }
}

// ─── Live Badge ───────────────────────────────────────
class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF00FF88).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          _BlinkDot(),
          SizedBox(width: 4),
          Text('LIVE',
              style: TextStyle(
                  color: Color(0xFF00FF88),
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _BlinkDot extends StatefulWidget {
  const _BlinkDot();

  @override
  State<_BlinkDot> createState() => _BlinkDotState();
}

class _BlinkDotState extends State<_BlinkDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Color(0xFF00FF88),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── Butterfly Logo ───────────────────────────────────
class ButterflyLogo extends StatefulWidget {
  final double size;
  const ButterflyLogo({super.key, this.size = 80});

  @override
  State<ButterflyLogo> createState() => _ButterflyLogoState();
}

class _ButterflyLogoState extends State<ButterflyLogo>
    with TickerProviderStateMixin {
  late AnimationController _colorController;
  late AnimationController _wingController;
  late Animation<double> _wingAnimation;

  final List<Color> _colors = [
    const Color(0xFF00E5FF),
    const Color(0xFF7C3AED),
    const Color(0xFFFF6B00),
    const Color(0xFF00FF88),
    const Color(0xFFFF3366),
  ];

  int _colorIndex = 0;
  Color _currentColor = const Color(0xFF00E5FF);
  Color _nextColor = const Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    _wingController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _wingAnimation = Tween<double>(begin: -0.3, end: 0.3).animate(
      CurvedAnimation(parent: _wingController, curve: Curves.easeInOut),
    );

    _colorController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _colorController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _colorIndex = (_colorIndex + 1) % _colors.length;
          _currentColor = _colors[_colorIndex];
          _nextColor = _colors[(_colorIndex + 1) % _colors.length];
        });
        _colorController.reset();
        _colorController.forward();
      }
    });
  }

  @override
  void dispose() {
    _colorController.dispose();
    _wingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_wingController, _colorController]),
      builder: (context, child) {
        final color = Color.lerp(
            _currentColor, _nextColor, _colorController.value)!;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: ButterflyPainter(
              wingAngle: _wingAnimation.value,
              color: color,
            ),
          ),
        );
      },
    );
  }
}

class ButterflyPainter extends CustomPainter {
  final double wingAngle;
  final Color color;
  ButterflyPainter({required this.wingAngle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final glow = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    for (final mirror in [-1.0, 1.0]) {
      canvas.save();
      canvas.scale(mirror * (wingAngle.abs() + 0.7), 1.0);
      final upper = Path()
        ..moveTo(0, 0)..cubicTo(-30, -25, -35, -5, -20, 5)..close();
      final lower = Path()
        ..moveTo(0, 0)..cubicTo(-25, 10, -28, 25, -12, 18)..close();
      canvas.drawPath(upper, glow);
      canvas.drawPath(lower, glow);
      canvas.drawPath(upper, paint);
      canvas.drawPath(lower, paint);
      canvas.restore();
    }

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 5, height: 20),
      Paint()..color = Colors.white.withOpacity(0.9),
    );

    final line = Paint()..color = color..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, -10), const Offset(-8, -22), line);
    canvas.drawLine(const Offset(0, -10), const Offset(8, -22), line);
    canvas.drawCircle(const Offset(-8, -22), 2, paint);
    canvas.drawCircle(const Offset(8, -22), 2, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(ButterflyPainter old) => true;
}

import 'package:flutter/material.dart';
import 'screens/guardian_mode_screen.dart';
import 'screens/shield_mode_screen.dart';
import 'screens/care_mode_screen.dart';
import 'screens/child_doctor_screen.dart';
import 'screens/digital_amma_screen.dart';
import 'screens/womens_health_screen.dart';
import 'screens/media_verifier_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF07080B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const EmowallApp());
}

class EmowallApp extends StatelessWidget {
  const EmowallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emowall AI 2.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07080B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFF7C3AED),
          surface: Color(0xFF0D0D1A),
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ══════════════════════════════════════════
// SPLASH SCREEN
// ══════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Butterfly Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7C3AED).withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text('🦋', style: TextStyle(fontSize: 60)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Emowall',
                  style: GoogleFonts.syne(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'AI 2.0',
                  style: GoogleFonts.syne(
                    color: const Color(0xFF00E5FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your Silent Guardian',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white38,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: const Color(0xFF7C3AED).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// HOME SCREEN
// ══════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // All mode cards
  final List<_ModeCard> _modes = [
    _ModeCard(
      emoji: '🛡️',
      title: 'Guardian Mode',
      subtitle: 'Protect Your Children',
      color: const Color(0xFF00E5FF),
      features: ['Kidnap Detection', 'Route Alerts', 'Auto SOS', 'GPS Sharing'],
      screen: const GuardianModeScreen(),
    ),
    _ModeCard(
      emoji: '⚔️',
      title: 'Shield Mode',
      subtitle: 'Campus & College Safety',
      color: const Color(0xFF7C3AED),
      features: ['Ragging Detection', 'Evidence Recording', 'Multi-platform Alerts'],
      screen: const ShieldModeScreen(),
    ),
    _ModeCard(
      emoji: '♿',
      title: 'Care Mode',
      subtitle: 'Accessibility Support',
      color: const Color(0xFF00FF9D),
      features: ['Blind Assistance', 'Deaf Alerts', 'Speech SOS', 'Picture Comm'],
      screen: const CareModeScreen(),
    ),
    _ModeCard(
      emoji: '👨‍⚕️',
      title: 'Child Doctor AI',
      subtitle: 'Child Health & Wellness',
      color: const Color(0xFFFF6B6B),
      features: ['Anxiety Monitor', 'Mood Tracking', 'Comfort Detection'],
      screen: const ChildDoctorScreen(),
    ),
    _ModeCard(
      emoji: '👩‍👶',
      title: 'Digital Amma',
      subtitle: 'Baby Care & Support',
      color: const Color(0xFFFFB800),
      features: ['Cry Detection', 'Malayalam Lullabies', 'Autism Support'],
      screen: const DigitalAmmaScreen(),
    ),
    _ModeCard(
      emoji: '♀️',
      title: "Women's Health",
      subtitle: 'Gentle Health Companion',
      color: const Color(0xFFFF4FA3),
      features: ['Health Tracking', 'Empowerment', 'Emergency Contacts'],
      screen: const WomensHealthScreen(),
    ),
    _ModeCard(
      emoji: '🗣️',
      title: 'Guardian AI',
      subtitle: 'Elder Care Voice Assistant',
      color: const Color(0xFF4ECDC4),
      features: ['Voice Activated', 'Emergency Response', 'Malayalam+English'],
      screen: const GuardianAIScreen(),
    ),
    _ModeCard(
      emoji: '🔍',
      title: 'Media Verifier',
      subtitle: 'AI Authentication',
      color: const Color(0xFFE040FB),
      features: ['Real Detection', 'Edited Detection', 'AI Generated Detection'],
      screen: const MediaVerifierScreen(),
      isNew: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── APP BAR ──
          SliverAppBar(
            backgroundColor: const Color(0xFF07080B),
            expandedHeight: 140,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7C3AED).withOpacity(0.15),
                      const Color(0xFF07080B),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Text('🦋', style: TextStyle(fontSize: 28)),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Emowall AI 2.0',
                                  style: GoogleFonts.syne(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Your Silent Guardian',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: const Color(0xFF00E5FF),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // EmoCoins badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFFFB800).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color(0xFFFFB800)
                                        .withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Text('🏆',
                                      style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'EmoCoins',
                                    style: GoogleFonts.syne(
                                      color: const Color(0xFFFFB800),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── LIVE STATUS BANNER ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _buildLiveBanner(),
            ),
          ),

          // ── SECTION TITLE ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Text(
                    'SELECT MODE',
                    style: GoogleFonts.syne(
                      color: Colors.white38,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF00E5FF).withOpacity(0.3)),
                    ),
                    child: Text(
                      '${_modes.length} Modes',
                      style: GoogleFonts.syne(
                        color: const Color(0xFF00E5FF),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── MODE GRID ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildModeCard(_modes[index]),
                childCount: _modes.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
            ),
          ),

          // ── WHY EMOWALL ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildWhyEmowall(),
            ),
          ),

          // ── FOOTER ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: _buildFooter(),
            ),
          ),
        ],
      ),
    );
  }

  // ── LIVE BANNER ──
  Widget _buildLiveBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00E5FF).withOpacity(0.08),
            const Color(0xFF7C3AED).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF00E5FF).withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF00FF9D),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Now Live · AI 2.0 · v1.0.12',
            style: GoogleFonts.syne(
              color: const Color(0xFF00E5FF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            'No Subscription',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ── MODE CARD ──
  Widget _buildModeCard(_ModeCard mode) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => mode.screen,
          transitionsBuilder: (_, animation, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              mode.color.withOpacity(0.12),
              mode.color.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: mode.color.withOpacity(0.35), width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(mode.emoji, style: const TextStyle(fontSize: 28)),
                const Spacer(),
                if (mode.isNew == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: mode.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: mode.color.withOpacity(0.5), width: 1),
                    ),
                    child: Text(
                      'NEW',
                      style: GoogleFonts.syne(
                        color: mode.color,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mode.title,
              style: GoogleFonts.syne(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mode.subtitle,
              style: GoogleFonts.spaceGrotesk(
                color: mode.color.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
            const Spacer(),
            // Feature tags
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: mode.features
                  .take(2)
                  .map((f) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: mode.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          f,
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white54,
                            fontSize: 9,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Open',
                  style: GoogleFonts.syne(
                    color: mode.color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: mode.color, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── WHY EMOWALL ──
  Widget _buildWhyEmowall() {
    final features = [
      ('📵', 'Works Offline'),
      ('🆓', 'No Subscription'),
      ('👨‍👩‍👧‍👦', 'Family-wide Protection'),
      ('🤖', 'AI-powered Detection'),
      ('⚡', 'Instant Emergency Response'),
      ('🌐', 'Multi-language Support'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7C3AED).withOpacity(0.08),
            const Color(0xFF07080B),
          ],
        ),
        border: Border.all(
            color: const Color(0xFF7C3AED).withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHY EMOWALL?',
            style: GoogleFonts.syne(
              color: Colors.white38,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3.5,
            children: features
                .map((f) => Row(
                      children: [
                        Text(f.$1, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f.$2,
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── FOOTER ──
  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(color: Colors.white12),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🦋', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              'Emowall AI 2.0 · Emobies',
              style: GoogleFonts.syne(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'നിങ്ങളുടെ കുടുംബത്തിൻ്റെ സുരക്ഷ ഞങ്ങളുടെ ഉത്തരവാദിത്തം',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white24,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'v1.0.12 · com.emobies.emowall',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white24,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════
// MODE CARD MODEL
// ══════════════════════════════════════════
class _ModeCard {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final List<String> features;
  final Widget screen;
  final bool? isNew;

  const _ModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.features,
    required this.screen,
    this.isNew,
  });
}

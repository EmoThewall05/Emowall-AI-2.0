import 'package:flutter/material.dart';

// Screens
import 'baby/digital_amma.dart';
import 'child/child_doctor_ai.dart';
import 'care/guardian_ai.dart';
import 'health/womens_health_ai_screen.dart';

void main() {
  runApp(const EmowallApp());
}

class EmowallApp extends StatelessWidget {
  const EmowallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emowall AI 2.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF07080B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1117),
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// Splash Screen
// ─────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 70, color: Color(0xFF00E5FF)),
            const SizedBox(height: 24),
            const Text(
              'Emowall AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'version 2.0',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Home Screen / Dashboard
// ─────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      appBar: AppBar(
        title: const Text(
          'Emowall AI Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _header(),
          const SizedBox(height: 20),

          // Digital Amma
          _buildMenuCard(
            context,
            title: 'Digital Amma',
            subtitle: 'Baby Care • Lullaby • Autism Support',
            icon: Icons.child_care,
            gradient: const [Color(0xFFFF6B81), Color(0xFFFF9A9E)],
            screen: const DigitalAmmaScreen(),
          ),

          // Child Doctor AI
          _buildMenuCard(
            context,
            title: 'Child Doctor AI',
            subtitle: 'Emotional Support • Therapy • Stories',
            icon: Icons.medical_services,
            gradient: const [Color(0xFF00E5FF), Color(0xFF7C3AED)],
            screen: const ChildDoctorAI(),
          ),

          // Guardian AI
          _buildMenuCard(
            context,
            title: 'Guardian AI',
            subtitle: 'Elder Care • Medicine • Emergency',
            icon: Icons.security,
            gradient: const [Color(0xFF00FF88), Color(0xFF00E5FF)],
            screen: const GuardianAIScreen(),
          ),

          // ⭐ NEW — Women’s Health AI
          _buildMenuCard(
            context,
            title: 'Women\'s Health AI',
            subtitle: 'Breast • Thyroid • Varicose • Diet Awareness',
            icon: Icons.female,
            gradient: const [Color(0xFFFF4F9A), Color(0xFFFF9A9E)],
            screen: const WomensHealthAIScreen(),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Welcome to Emowall AI 2.0',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'World’s first life‑care AI ecosystem — from baby to elderly.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22).withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: gradient),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white38, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

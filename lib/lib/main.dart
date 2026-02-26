import 'package:flutter/material.dart';
import 'baby/digital_amma.dart';
import 'child/child_doctor_ai.dart';
import 'care/guardian_ai.dart';

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
      ),
      home: const SplashScreen(),
    );
  }
}

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
    return const Scaffold(
      backgroundColor: Color(0xFF07080B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:,
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emowall AI Dashboard'),
        backgroundColor: const Color(0xFF0D1117),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildMenuCard(
              context,
              'Digital Amma',
              'Baby Care & Lullaby',
              Icons.child_care,
              Colors.pinkAccent,
              const DigitalAmmaScreen(),
            ),
            const SizedBox(height: 15),
            _buildMenuCard(
              context,
              'Child Doctor AI',
              'Pediatric Support',
              Icons.medical_services,
              Colors.blueAccent,
              const ChildDoctorAI(),
            ),
            const SizedBox(height: 15),
            _buildMenuCard(
              context,
              'Guardian AI',
              'Elderly & Emergency Care',
              Icons.security,
              Colors.greenAccent,
              const GuardianAIScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String sub,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return Card(
      color: const Color(0xFF161B22),
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(sub, style: const TextStyle(color: Colors.white60)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        ),
      ),
    );
  }
}

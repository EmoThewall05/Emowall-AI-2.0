import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:emowall/firebase_options.dart';
import 'package:emowall/login_page.dart';
import 'package:emowall/baby/digital_amma.dart';
import 'package:emowall/child/child_doctor_ai.dart';
import 'package:emowall/care/guardian_ai.dart';
import 'package:emowall/health/women_ai.dart';
import 'package:emowall/widgets/butterfly_logo.dart';
import 'package:emowall/screens/media_verifier_ai.dart';
import 'package:emowall/screens/shield_mode.dart';
import 'package:emowall/screens/guardian_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const EmowallApp());
}

class EmowallApp extends StatelessWidget {
  const EmowallApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emowall AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF5500)),
        scaffoldBackgroundColor: const Color(0xFF07080B),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Waiting for Firebase to check auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF07080B),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFFF5500)),
              ),
            );
          }
          // User is logged in → go to home
          if (snapshot.hasData) {
            return const ModeSelectionScreen();
          }
          // Not logged in → show login
          return const LoginPage();
        },
      ),
    );
  }
}

// ==================== MODE SELECTION ====================
class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(child: ButterflyLogo(size: 70)),
              const SizedBox(height: 16),
              Text('Emowall', style: GoogleFonts.syne(fontSize: 36, fontWeight: FontWeight.w800, color: const Color(0xFFFF5500))),
              Text('Your Silent Guardian', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF8892A4))),
              const SizedBox(height: 8),
              Text('AI 2.0', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF00E676))),
              const SizedBox(height: 32),
              Text('🛡️ Safety', style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF8892A4))),
              const SizedBox(height: 12),
              _modeCard(context, '🛡️', 'Guardian Mode', 'Children & Women Safety', const Color(0xFF3B82F6), const GuardianModeScreen()),
              const SizedBox(height: 12),
              _modeCard(context, '⚔️', 'Shield Mode', 'Men, Elderly & College Safety', const Color(0xFF00E676), const ShieldModeScreen()),
              const SizedBox(height: 12),
              _modeCard(context, '♿', 'Care Mode', 'Blind, Deaf & Speech Support', const Color(0xFFA855F7), const CareModeScreen()),
              const SizedBox(height: 12),
              _modeCard(context, '🛡️🗣️', 'Guardian AI', 'Voice-activated Elder Care', const Color(0xFF00E5FF), const GuardianAIScreen()),
              const SizedBox(height: 24),
              Text('👶 Child & Family', style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF8892A4))),
              const SizedBox(height: 12),
              _modeCard(context, '👩‍👶', 'Digital Amma', 'Baby Care & Lullabies AI', const Color(0xFFFF4F9A), const DigitalAmmaScreen()),
              const SizedBox(height: 12),
              _modeCard(context, '👨‍⚕️', 'Child Doctor AI', 'Child Mental Health & Therapy', const Color(0xFFFFBF24), const ChildDoctorAI()),
              const SizedBox(height: 24),
              Text('💜 Health', style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF8892A4))),
              const SizedBox(height: 12),
              _modeCard(context, '♀️', "Women's Health", 'Gentle Health Companion', const Color(0xFFFF4F9A), const WomensHealthAIScreen()),
              const SizedBox(height: 24),
              Text('🔍 AI Tools', style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF8892A4))),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MediaVerifierScreen())),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111519),
                    border: Border.all(color: const Color(0xFFE040FB).withOpacity(0.6)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Text('🔍', style: TextStyle(fontSize: 36)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Media Verifier', style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE040FB).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFE040FB).withOpacity(0.6)),
                                  ),
                                  child: Text('NEW', style: GoogleFonts.syne(fontSize: 8, color: const Color(0xFFE040FB), fontWeight: FontWeight.bold, letterSpacing: 1)),
                                ),
                              ],
                            ),
                            Text('AI Deepfake & Edit Detection', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF8892A4))),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Color(0xFFE040FB), size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    const ButterflyLogo(size: 36),
                    const SizedBox(height: 8),
                    Text(
                      'Emowall AI 2.0 — Your Family\'s Guardian',
                      style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF8892A4)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeCard(BuildContext context, String emoji, String title, String subtitle, Color color, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF111519),
          border: Border.all(color: color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text(subtitle, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF8892A4))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

// ==================== GUARDIAN MODE ====================
class CareModeScreen extends StatefulWidget {
  const CareModeScreen({super.key});
  @override
  State<CareModeScreen> createState() => _CareModeScreenState();
}

class _CareModeScreenState extends State<CareModeScreen> {
  bool _blindEnabled = false;
  bool _deafEnabled = false;
  bool _speechEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0F14),
        title: Text('♿ Care Mode', style: GoogleFonts.syne(fontWeight: FontWeight.w800, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _careCard('👁️', 'Blind Support', ['Voice alerts in Malayalam + English', 'Vibration patterns (SOS = 3 long)', 'Audio GPS navigation', 'Road crossing AI assistant', 'Voice confirmation of all actions'], const Color(0xFF3B82F6), _blindEnabled, (v) { setState(() => _blindEnabled = v); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(v ? '👁️ Blind Support ENABLED' : '👁️ Blind Support disabled'), backgroundColor: const Color(0xFF3B82F6))); }),
          const SizedBox(height: 16),
          _careCard('👂', 'Deaf Support', ['Strong vibration alerts', 'LED flash SOS signal', 'Visual notifications', 'Phone screen flash alerts', 'Sign language video calls'], const Color(0xFF00E676), _deafEnabled, (v) { setState(() => _deafEnabled = v); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(v ? '👂 Deaf Support ENABLED' : '👂 Deaf Support disabled'), backgroundColor: const Color(0xFF00E676))); }),
          const SizedBox(height: 16),
          _careCard('🗣️', 'Speech Support', ['Pre-recorded SOS messages', 'One button voice message', 'AI speaks for the user', 'Picture-based communication'], const Color(0xFFA855F7), _speechEnabled, (v) { setState(() => _speechEnabled = v); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(v ? '🗣️ Speech Support ENABLED' : '🗣️ Speech Support disabled'), backgroundColor: const Color(0xFFA855F7))); }),
        ]),
      ),
    );
  }

  Widget _careCard(String emoji, String title, List<String> features, Color color, bool enabled, Function(bool) onToggle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111519), border: Border.all(color: enabled ? color : color.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))),
          Switch(value: enabled, onChanged: onToggle, activeColor: color),
        ]),
        const SizedBox(height: 12),
        ...features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            Icon(Icons.check_circle, color: enabled ? color : color.withOpacity(0.4), size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(f, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF8892A4)))),
          ]),
        )),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () => onToggle(!enabled),
          style: ElevatedButton.styleFrom(backgroundColor: enabled ? color : color.withOpacity(0.3), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: Text(enabled ? '✅ $title Active' : 'Enable $title', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
        )),
      ]),
    );
  }
}

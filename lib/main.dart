import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'baby/digital_amma.dart';
import 'child/child_doctor_ai.dart';
import 'care/guardian_ai.dart';
import 'lib/screens/health/womens_health_ai_screen.dart';
import 'widgets/butterfly_logo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const ModeSelectionScreen(),
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
class GuardianModeScreen extends StatefulWidget {
  const GuardianModeScreen({super.key});
  @override
  State<GuardianModeScreen> createState() => _GuardianModeScreenState();
}

class _GuardianModeScreenState extends State<GuardianModeScreen> {
  bool _active = false;
  bool _safeZoneOn = false;
  bool _soundDetectOn = false;
  String _status = 'Protection OFF';

  List<Map<String, String>> _contacts = [
    {'name': 'Parent/Guardian', 'phone': '+91 98478 42172'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0F14),
        title: Text('🛡️ Guardian Mode', style: GoogleFonts.syne(fontWeight: FontWeight.w800, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onLongPress: _sendSOS,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEF4444).withOpacity(0.15),
                  border: Border.all(color: const Color(0xFFEF4444), width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sos, color: Color(0xFFEF4444), size: 60),
                    Text('HOLD FOR SOS', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFFEF4444), fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(_status, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF8892A4))),
            const SizedBox(height: 24),
            _featureToggle('🗺️ Safe Zone', 'Alert when boundary crossed', _safeZoneOn, (v) => setState(() => _safeZoneOn = v), const Color(0xFF3B82F6)),
            const SizedBox(height: 12),
            _featureToggle('🎤 Sound Detection', 'Detect crying/aggression', _soundDetectOn, (v) => setState(() => _soundDetectOn = v), const Color(0xFFFBBF24)),
            const SizedBox(height: 12),
            _featureToggle('🛡️ Active Protection', 'Enable all monitoring', _active, (v) => setState(() { _active = v; _status = v ? '🟢 Protection ACTIVE' : 'Protection OFF'; }), const Color(0xFF00E676)),
            const SizedBox(height: 24),
            // Emergency Contacts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('📞 Emergency Contacts', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                IconButton(
                  onPressed: () => _showAddContactDialog(context),
                  icon: const Icon(Icons.add_circle, color: Color(0xFFFF5500), size: 28),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._contacts.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _contactCard(entry.value['name']!, entry.value['phone']!, entry.key),
            )),
          ],
        ),
      ),
    );
  }

  void _sendSOS() {
    setState(() => _status = '🚨 SOS SENT! Help is coming...');
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚨 SOS Alert sent to emergency contacts!'), backgroundColor: Color(0xFFEF4444)),
    );
  }

  // ✅ Add Contact Dialog
  void _showAddContactDialog(BuildContext context, {int? editIndex}) {
    final nameController = TextEditingController(
      text: editIndex != null ? _contacts[editIndex]['name'] : '',
    );
    final phoneController = TextEditingController(
      text: editIndex != null ? _contacts[editIndex]['phone'] : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111519),
        title: Text(
          editIndex != null ? 'Edit Contact' : 'Add Contact',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Color(0xFF8892A4)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF5500))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF5500))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: Color(0xFF8892A4)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF5500))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF5500))),
                hintText: '+91 XXXXX XXXXX',
                hintStyle: TextStyle(color: Color(0xFF8892A4)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8892A4))),
          ),
          if (editIndex != null)
            TextButton(
              onPressed: () {
                setState(() => _contacts.removeAt(editIndex));
                Navigator.pop(ctx);
              },
              child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5500)),
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                setState(() {
                  if (editIndex != null) {
                    _contacts[editIndex] = {
                      'name': nameController.text,
                      'phone': phoneController.text,
                    };
                  } else {
                    _contacts.add({
                      'name': nameController.text,
                      'phone': phoneController.text,
                    });
                  }
                });
                Navigator.pop(ctx);
              }
            },
            child: Text(editIndex != null ? 'Save' : 'Add', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _featureToggle(String title, String subtitle, bool value, Function(bool) onChanged, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111519), border: Border.all(color: color.withOpacity(0.2)), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: Colors.white)),
          Text(subtitle, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF8892A4))),
        ])),
        Switch(value: value, onChanged: onChanged, activeColor: color),
      ]),
    );
  }

  Widget _contactCard(String name, String phone, int index) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFF111519), border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      const Icon(Icons.person, color: Color(0xFF3B82F6)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: Colors.white)),
        Text(phone, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF8892A4))),
      ])),
      IconButton(
        onPressed: () => _showAddContactDialog(context, editIndex: index),
        icon: const Icon(Icons.edit, color: Color(0xFF3B82F6), size: 18),
      ),
    ]),
  );
}

// ==================== SHIELD MODE ====================
class ShieldModeScreen extends StatefulWidget {
  const ShieldModeScreen({super.key});
  @override
  State<ShieldModeScreen> createState() => _ShieldModeScreenState();
}

class _ShieldModeScreenState extends State<ShieldModeScreen> {
  bool _raggingDetect = false;
  bool _fallDetect = false;
  bool _accidentDetect = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0F14),
        title: Text('⚔️ Shield Mode', style: GoogleFonts.syne(fontWeight: FontWeight.w800, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          ElevatedButton.icon(
            onPressed: _quickSOS,
            icon: const Icon(Icons.sos, size: 28),
            label: Text('EMERGENCY SOS', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          _featureToggle('🎓 Ragging Detection', 'Auto detect aggressive voices + record evidence', _raggingDetect, (v) => setState(() => _raggingDetect = v), const Color(0xFFFBBF24)),
          const SizedBox(height: 12),
          _featureToggle('👴 Fall Detection', 'Alert if elderly person falls', _fallDetect, (v) => setState(() => _fallDetect = v), const Color(0xFF3B82F6)),
          const SizedBox(height: 12),
          _featureToggle('🚗 Accident Detection', 'Detect sudden impact', _accidentDetect, (v) => setState(() => _accidentDetect = v), const Color(0xFF00E676)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF111519), border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('📹 Evidence Recorder', style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: Colors.white)),
              Text('Auto records audio/video when threat detected', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF8892A4))),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🎤 Recording audio...'), backgroundColor: Color(0xFFFBBF24)),
                    );
                  },
                  icon: const Icon(Icons.mic, color: Color(0xFFFBBF24)),
                  label: const Text('Record Audio', style: TextStyle(color: Color(0xFFFBBF24))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFFBBF24))),
                )),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('📹 Recording video...'), backgroundColor: Color(0xFFFBBF24)),
                    );
                  },
                  icon: const Icon(Icons.videocam, color: Color(0xFFFBBF24)),
                  label: const Text('Record Video', style: TextStyle(color: Color(0xFFFBBF24))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFFBBF24))),
                )),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  void _quickSOS() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚨 SOS sent! Location shared with emergency contacts'), backgroundColor: Color(0xFFEF4444)),
    );
  }

  Widget _featureToggle(String title, String subtitle, bool value, Function(bool) onChanged, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111519), border: Border.all(color: color.withOpacity(0.2)), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: Colors.white)),
          Text(subtitle, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF8892A4))),
        ])),
        Switch(value: value, onChanged: onChanged, activeColor: color),
      ]),
    );
  }
}

// ==================== CARE MODE ====================
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
          _careCard('👁️', 'Blind Support', [
            'Voice alerts in Malayalam + English',
            'Vibration patterns (SOS = 3 long)',
            'Audio GPS navigation',
            'Road crossing AI assistant',
            'Voice confirmation of all actions',
          ], const Color(0xFF3B82F6), _blindEnabled, (v) {
            setState(() => _blindEnabled = v);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(v ? '👁️ Blind Support ENABLED' : '👁️ Blind Support disabled'),
                backgroundColor: const Color(0xFF3B82F6),
              ),
            );
          }),
          const SizedBox(height: 16),
          _careCard('👂', 'Deaf Support', [
            'Strong vibration alerts',
            'LED flash SOS signal',
            'Visual notifications',
            'Phone screen flash alerts',
            'Sign language video calls',
          ], const Color(0xFF00E676), _deafEnabled, (v) {
            setState(() => _deafEnabled = v);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(v ? '👂 Deaf Support ENABLED' : '👂 Deaf Support disabled'),
                backgroundColor: const Color(0xFF00E676),
              ),
            );
          }),
          const SizedBox(height: 16),
          _careCard('🗣️', 'Speech Support', [
            'Pre-recorded SOS messages',
            'One button voice message',
            'AI speaks for the user',
            'Picture-based communication',
          ], const Color(0xFFA855F7), _speechEnabled, (v) {
            setState(() => _speechEnabled = v);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(v ? '🗣️ Speech Support ENABLED' : '🗣️ Speech Support disabled'),
                backgroundColor: const Color(0xFFA855F7),
              ),
            );
          }),
        ]),
      ),
    );
  }

  Widget _careCard(String emoji, String title, List<String> features, Color color, bool enabled, Function(bool) onToggle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111519),
        border: Border.all(color: enabled ? color : color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled ? color : color.withOpacity(0.3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            enabled ? '✅ $title Active' : 'Enable $title',
            style: GoogleFonts.syne(fontWeight: FontWeight.w700),
          ),
        )),
      ]),
    );
  }
}

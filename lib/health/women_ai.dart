import 'package:flutter/material.dart';

class WomensHealthAIScreen extends StatefulWidget {
  const WomensHealthAIScreen({super.key});

  @override
  State<WomensHealthAIScreen> createState() => _WomensHealthAIScreenState();
}

class _WomensHealthAIScreenState extends State<WomensHealthAIScreen>
    with TickerProviderStateMixin {
  int _breastCheckDays = 0;
  int _thyroidCheckMonths = 0;
  int _legPainLevel = 0;
  bool _dietOnTrack = false;

  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text(
          'Women\'s Health AI (Support)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _breastHealthCard(),
            const SizedBox(height: 14),
            _thyroidCard(),
            const SizedBox(height: 14),
            _varicoseCard(),
            const SizedBox(height: 14),
            _dietCard(),
            const SizedBox(height: 20),
            _disclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _glowController,
          builder: (_, __) => Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4F9A)
                      .withOpacity(0.2 + _glowController.value * 0.4),
                  blurRadius: 24,
                  spreadRadius: 6,
                ),
              ],
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4F9A), Color(0xFFFF9A9E)],
              ),
            ),
            child: const Center(
              child: Text('♀', style: TextStyle(fontSize: 30)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gentle Health Companion',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Awareness • Tracking • Questions for your doctor\nNot a diagnosis. Not a replacement.',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _breastHealthCard() {
    return _sectionCard(
      title: 'Breast Health Awareness',
      emoji: '🎗️',
      color: const Color(0xFFFF4F9A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Self‑check reminder (monthly)',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Days since last self‑check: ',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                '$_breastCheckDays days',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: _breastCheckDays.toDouble(),
            min: 0,
            max: 60,
            divisions: 60,
            label: '$_breastCheckDays',
            activeColor: const Color(0xFFFF4F9A),
            onChanged: (v) => setState(() => _breastCheckDays = v.toInt()),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tips to ask your doctor about:\n• When to start mammograms\n• Family history risk\n• How to do proper self‑exam',
            style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _thyroidCard() {
    return _sectionCard(
      title: 'Thyroid & Energy',
      emoji: '🦋',
      color: const Color(0xFF7C3AED),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Track how long since last thyroid test (TSH, T3, T4).',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Months since last test: ',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                '$_thyroidCheckMonths months',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: _thyroidCheckMonths.toDouble(),
            min: 0,
            max: 36,
            divisions: 36,
            label: '$_thyroidCheckMonths',
            activeColor: const Color(0xFF7C3AED),
            onChanged: (v) => setState(() => _thyroidCheckMonths = v.toInt()),
          ),
          const SizedBox(height: 6),
          const Text(
            'Common things to discuss with your doctor:\n• Fatigue, weight changes, hair fall\n• Neck swelling, palpitations\n• How often you personally need tests',
            style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _varicoseCard() {
    return _sectionCard(
      title: 'Legs & Varicose Veins',
      emoji: '🦵',
      color: const Color(0xFF00E5FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Leg pain / heaviness: ',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                '$_legPainLevel / 10',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: _legPainLevel.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: '$_legPainLevel',
            activeColor: const Color(0xFF00E5FF),
            onChanged: (v) => setState(() => _legPainLevel = v.toInt()),
          ),
          const SizedBox(height: 6),
          const Text(
            'Supportive habits (ask your doctor if suitable for you):\n• Leg elevation breaks\n• Avoid long standing without movement\n• Compression stockings (only if prescribed)',
            style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _dietCard() {
    return _sectionCard(
      title: 'Diet & Daily Care',
      emoji: '🥗',
      color: const Color(0xFF00FF88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _dietOnTrack,
                activeColor: const Color(0xFF00FF88),
                onChanged: (v) => setState(() => _dietOnTrack = v ?? false),
              ),
              const Expanded(
                child: Text(
                  'Today I roughly followed my planned diet / doctor advice.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'General supportive ideas (always personalize with a doctor/dietitian):\n• More whole foods, less ultra‑processed\n• Enough protein & fiber\n• Regular meals instead of long gaps\n• Hydration throughout the day',
            style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _disclaimer() {
    return const Text(
      '⚠ This screen is for awareness, tracking, and preparing better questions for your doctor.\n'
      'It does NOT detect cancer, thyroid disease, or vein problems. Always rely on qualified medical professionals for tests, diagnosis, and treatment.',
      style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5),
    );
  }

  Widget _sectionCard({
    required String title,
    required String emoji,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class WordPressLoginPage extends StatefulWidget {
  const WordPressLoginPage({super.key});

  @override
  State<WordPressLoginPage> createState() => _WordPressLoginPageState();
}

class _WordPressLoginPageState extends State<WordPressLoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    // Logo "pulse" animation
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _logoAnimation = CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOutBack,
    );
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Styling constants
    const accentColor = Color(0xFFFF9F1C); // Summer Orange
    const cyanColor = Color(0xFF2EC4B6); // Cyan/Teal
    const darkBgColor = Color(0xFF10141C); // Matches domain screenshot
    const darkInputColor = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: darkBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Animated Butterfly Logo
              ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(_logoAnimation),
                child: RotationTransition(
                  turns: Tween<double>(begin: -0.01, end: 0.01).animate(_logoAnimation),
                  child: Image.asset(
                    'assets/orange_cyan_butterfly.png', // <-- Placeholder: Update this path!
                    height: 120,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Title and Subtitle
              const Text(
                'Log in to WordPress.com',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'e-mobies.com — Emowall Ai 2.0',
                style: TextStyle(
                  fontSize: 14,
                  color: cyanColor.withOpacity(0.8),
                ),
              ),

              const SizedBox(height: 40),

              // Input Fields
              const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: darkInputColor,
                  hintText: 'Email Address or Username',
                  hintStyle: TextStyle(color: Colors.white60),
                  prefixIcon: Icon(Icons.person_outline, color: accentColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: darkInputColor,
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.white60),
                  prefixIcon: Icon(Icons.lock_outline, color: accentColor),
                  suffixIcon: Icon(Icons.visibility_off_outlined, color: Colors.white60),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Forgot Password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: cyanColor, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Continue with butterfly key', // Custom text
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Alternate Login Methods
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.white24)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('OR', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.white24)),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Image.asset('assets/google_logo.png', height: 18), // Update path
                      label: const Text('Google'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.fingerprint, color: cyanColor),
                      label: const Text('Biometric'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Footer / Support
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Create an account',
                      style: TextStyle(color: cyanColor),
                    ),
                  ),
                  const Text('  •  ', style: TextStyle(color: Colors.white24)),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Support',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

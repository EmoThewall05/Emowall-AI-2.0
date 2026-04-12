import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/butterfly_controller.dart'; // നിന്റെ ButterflyController

class EmoLoginScreen extends StatefulWidget {
  const EmoLoginScreen({super.key});

  @override
  State<EmoLoginScreen> createState() => _EmoLoginScreenState();
}

class _EmoLoginScreenState extends State<EmoLoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();

    // ⭐ Divine Glow Animation for the Butterfly
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowOpacity = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ⭐ നിന്റെ ButterflyState watch ചെയ്യുക (നിറം മാറ്റാൻ)
    final butterfly = context.watch<ButterflyState>();

    return Scaffold(
      backgroundColor: const Color(0xFF030307), // അതീവ കറുത്ത ബാക്ക്ഗ്രൗണ്ട്
      body: Stack(
        children: [
          // Background Decor (ഒരു ചെറിയ നീല വെളിച്ചം)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00f2ff).withOpacity(0.05),
                blurRadius: 100,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // ⭐ The Pulsing Butterfly Guardian
                  AnimatedBuilder(
                    animation: _glowOpacity,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: butterfly.glowColor
                                  .withOpacity(_glowOpacity.value),
                              blurRadius: 50,
                              spreadRadius: 15,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/thewall_butterfly.png', // നിന്റെ ശലഭത്തിന്റെ ചിത്രം
                          width: 150,
                          height: 150,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Title & Subtitle
                  const Text(
                    "EMO AI PRO",
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk', // നീ ഉപയോഗിക്കുന്ന ഫോണ്ട്
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your Emotionally Intelligent Guardian",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Login Options Box
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13131A), // ഡാർക്ക് കാർഡ് കളർ
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        // Google Login Button
                        _buildLoginButton(
                          icon: 'assets/google_logo.png', // ഗൂഗിൾ ലോഗോ
                          label: "Continue with Google",
                          onPressed: () {
                            // TODO: Implement Google Sign-In
                          },
                        ),
                        const SizedBox(height: 16),
                        // WalletConnect Button (Web3 Integration)
                        _buildLoginButton(
                          icon: 'assets/walletconnect_logo.png', // വാർലെറ്റ് കണക്ട് ലോഗോ
                          label: "Connect with WalletConnect",
                          onPressed: () {
                            // TODO: Implement WalletConnect
                          },
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Footer Meta
                  Text(
                    "BUILT ON MOBILE • DXB 🇦🇪",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.3),
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton({
    required String icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleStyle(
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
          backgroundColor: const Color(0xFF1E1E26),
          shape: RoundedRectangleType(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, width: 22, height: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

// ─── Butterfly Logo ───────────────────────────────────
class ButterflyLogo extends StatefulWidget {
  final double size;
  const ButterflyLogo({super.key, this.size = 80});

  @override
  State<ButterflyLogo> createState() => _ButterflyLogoState();
}

class _ButterflyLogoState extends State<ButterflyLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
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
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE040FB).withOpacity(_glowAnimation.value),
                blurRadius: widget.size * 0.5,
                spreadRadius: widget.size * 0.05,
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/emowallai_logo.webp',
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}

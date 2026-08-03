import 'package:flutter/material.dart';

class ButterflyLogo extends StatefulWidget {
  final double size;
  const ButterflyLogo({super.key, this.size = 80});

  @override
  State<ButterflyLogo> createState() => _ButterflyLogoState();
}

class _ButterflyLogoState extends State<ButterflyLogo>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  late AnimationController _flutterController;
  late Animation<double> _flutterScale;
  late Animation<double> _flutterRotate;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _flutterController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);

    _flutterScale = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _flutterController, curve: Curves.easeInOut),
    );

    _flutterRotate = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _flutterController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _flutterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _flutterController]),
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF5500)
                    .withOpacity(_glowAnimation.value * 0.6),
                blurRadius: widget.size * 0.65,
                spreadRadius: widget.size * 0.08,
              ),
              BoxShadow(
                color: const Color(0xFFE040FB)
                    .withOpacity(_glowAnimation.value * 0.5),
                blurRadius: widget.size * 0.45,
                spreadRadius: widget.size * 0.03,
              ),
            ],
          ),
          child: Transform.rotate(
            angle: _flutterRotate.value,
            child: Transform.scale(
              scale: _flutterScale.value,
              child: Image.asset(
                'assets/images/emowallai_logo.webp',
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}

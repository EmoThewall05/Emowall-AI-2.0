import 'package:flutter/material.dart';

// ─── Butterfly Logo ───────────────────────────────────
class ButterflyLogo extends StatefulWidget {
  final double size;
  const ButterflyLogo({super.key, this.size = 80});

  @override
  State<ButterflyLogo> createState() => _ButterflyLogoState();
}

class _ButterflyLogoState extends State<ButterflyLogo>
    with TickerProviderStateMixin {
  late AnimationController _colorController;
  late AnimationController _wingController;
  late Animation<double> _wingAnimation;

  final List<Color> _colors = [
    const Color(0xFF00E5FF),
    const Color(0xFF7C3AED),
    const Color(0xFFFF6B00),
    const Color(0xFF00FF88),
    const Color(0xFFFF3366),
  ];

  int _colorIndex = 0;
  Color _currentColor = const Color(0xFF00E5FF);
  Color _nextColor = const Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();

    _wingController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _wingAnimation = Tween<double>(begin: -0.3, end: 0.3).animate(
      CurvedAnimation(parent: _wingController, curve: Curves.easeInOut),
    );

    _colorController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _colorController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _colorIndex = (_colorIndex + 1) % _colors.length;
          _currentColor = _colors[_colorIndex];
          _nextColor = _colors[(_colorIndex + 1) % _colors.length];
        });
        _colorController.reset();
        _colorController.forward();
      }
    });
  }

  @override
  void dispose() {
    _colorController.dispose();
    _wingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_wingController, _colorController]),
      builder: (context, child) {
        final color = Color.lerp(
          _currentColor,
          _nextColor,
          _colorController.value,
        )!;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: ButterflyPainter(
              wingAngle: _wingAnimation.value,
              color: color,
            ),
          ),
        );
      },
    );
  }
}

// ─── Butterfly Painter ────────────────────────────────
class ButterflyPainter extends CustomPainter {
  final double wingAngle;
  final Color color;

  ButterflyPainter({required this.wingAngle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);

    // Left wings
    canvas.save();
    canvas.scale(wingAngle.abs() + 0.7, 1.0);

    final leftUpper = Path()
      ..moveTo(0, 0)
      ..cubicTo(-30, -25, -35, -5, -20, 5)
      ..close();

    final leftLower = Path()
      ..moveTo(0, 0)
      ..cubicTo(-25, 10, -28, 25, -12, 18)
      ..close();

    canvas.drawPath(leftUpper, glowPaint);
    canvas.drawPath(leftLower, glowPaint);
    canvas.drawPath(leftUpper, paint);
    canvas.drawPath(leftLower, paint);
    canvas.restore();

    // Right wings
    canvas.save();
    canvas.scale(-(wingAngle.abs() + 0.7), 1.0);

    final rightUpper = Path()
      ..moveTo(0, 0)
      ..cubicTo(-30, -25, -35, -5, -20, 5)
      ..close();

    final rightLower = Path()
      ..moveTo(0, 0)
      ..cubicTo(-25, 10, -28, 25, -12, 18)
      ..close();

    canvas.drawPath(rightUpper, glowPaint);
    canvas.drawPath(rightLower, glowPaint);
    canvas.drawPath(rightUpper, paint);
    canvas.drawPath(rightLower, paint);
    canvas.restore();

    // Body
    final bodyPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 5,
        height: 20,
      ),
      bodyPaint,
    );

    // Antennae
    final antennaPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
        const Offset(0, -10), const Offset(-8, -22), antennaPaint);
    canvas.drawLine(
        const Offset(0, -10), const Offset(8, -22), antennaPaint);
    canvas.drawCircle(const Offset(-8, -22), 2, paint);
    canvas.drawCircle(const Offset(8, -22), 2, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(ButterflyPainter oldDelegate) => true;
}

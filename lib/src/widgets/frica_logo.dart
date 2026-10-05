import 'package:flutter/material.dart';

/// Renders the official Frica ID vector logo without requiring external SVG asset bundling.
class FricaLogo extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color markColor;

  const FricaLogo({
    super.key,
    this.size = 24.0,
    this.backgroundColor = Colors.black,
    this.markColor = const Color(0xFFFFCC00),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.6, size * 0.6),
          painter: _FricaMarkPainter(color: markColor),
        ),
      ),
    );
  }
}

class _FricaMarkPainter extends CustomPainter {
  final Color color;

  _FricaMarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Proportional Frica 'F' glyph
    final w = size.width;
    final h = size.height;

    // Top horizontal bar
    path.moveTo(0, 0);
    path.lineTo(w, 0);
    path.lineTo(w, h * 0.28);
    path.lineTo(w * 0.38, h * 0.28);
    // Center horizontal bar
    path.lineTo(w * 0.38, h * 0.44);
    path.lineTo(w * 0.85, h * 0.44);
    path.lineTo(w * 0.85, h * 0.72);
    path.lineTo(w * 0.38, h * 0.72);
    // Bottom vertical stem
    path.lineTo(w * 0.38, h);
    path.lineTo(0, h);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FricaMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

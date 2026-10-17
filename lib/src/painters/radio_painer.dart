import 'package:flutter/material.dart' show CustomPainter, Color, Canvas, Size, Paint, Offset;

class RadioPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color borderColor;
  final Color backgroundColor;

  RadioPainter({
    required this.progress,
    required this.color,
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width * 0.4;

    // Fondo
    canvas.drawCircle(
      center,
      radius,
      Paint() ..color = backgroundColor
    );

    // Borde
    canvas.drawCircle(
      center,
      radius,
      Paint()
      ..color       = borderColor
      ..style       = .stroke
      ..strokeWidth = size.width * 0.1
    );

    // Animación de selección (círculo que se rellena)
    if (progress > 0) {
      final animatedRadius = (radius - (radius * 0.3)) * progress;
      canvas.drawCircle(
        center,
        animatedRadius,
        Paint() ..color = color ..style = .fill
      );
    }
  }

  @override
  bool shouldRepaint(covariant RadioPainter oldDelegate) =>
    oldDelegate.progress != progress ||
    oldDelegate.color != color ||
    oldDelegate.backgroundColor != backgroundColor;
}
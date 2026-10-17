import 'package:flutter/material.dart' show Canvas, Color, CustomPainter, Offset, Paint, Size;

class StripesPainter extends CustomPainter {
  final bool reverse;
  final Color color;
  final double spacing;
  final double width;

  StripesPainter({
    required this.color,
    this.reverse = true,
    this.spacing = 6,
    this.width = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
    ..color       = color
    ..strokeWidth = width
    ..style       = .stroke;

    for (double i = -size.height; i < size.width; i += spacing) {
      if (reverse) {
        canvas.drawLine(
          Offset(size.width - i, 0),
          Offset(size.width - (i + size.height), size.height),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(i, 0),
          Offset(i + size.height, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
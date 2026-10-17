import 'package:flutter/material.dart';

class ArrowPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  ArrowPainter({required this.color, this.strokeWidth = 2});

  @override
  void paint(Canvas canvas, Size size) {

    // Puntos para una V centrada
    final Offset left   = .new(size.width * 0.25, size.height * 0.35);
    final Offset bottom = .new(size.width * 0.5, size.height * 0.65);
    final Offset right  = .new(size.width * 0.75, size.height * 0.35);

    final Path path = Path();

    path.moveTo(left.dx, left.dy);
    path.lineTo(bottom.dx, bottom.dy - 1);
    path.lineTo(right.dx, right.dy);

    canvas.drawPath(
      path,
      Paint()
      ..color       = color
      ..strokeWidth = strokeWidth
      ..style       = .stroke
      ..strokeCap   = .round
    );
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) =>
    oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
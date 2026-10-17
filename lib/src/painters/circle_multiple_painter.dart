import 'dart:math' show pi;
import 'package:flutter/material.dart' show Canvas, Color, CustomPainter, Offset, Paint, Size;

class MultiCircleProgressPainter extends CustomPainter {
  final List<double> progress;
  final List<Color> colors;
  final double width;

  MultiCircleProgressPainter({
    required this.progress,
    required this.colors,
    this.width = 20
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress.reduce((a, b) => a + b) > 1) throw const FormatException("Values dont must be > 1!");
    if (progress.length > 3) throw const FormatException("There is only 3 spaces");

    final double radius = (size.width - width) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double circle = pi * 2;

    List<double> angles = .generate(progress.length, (i) => 0);
    List<double> starts = .generate(progress.length, (i) => 0);

    for (int i = 0; i < progress.length; i++) {
      angles[i] = (progress[i] * circle) - (circle * 0.03);
      starts[i] = i == 0
      ? (pi / 2) + (circle * 0.01)
      : starts[i - 1] + angles[i - 1] + (circle * 0.03);

      canvas.drawArc(
        .fromCircle(center: center, radius: radius),
        starts[i], // Inicia en la parte izquierda
        angles[i], // Avance del progreso
        false,
        Paint()
          ..color       = colors[i]
          ..style       = .stroke
          ..strokeWidth = width
          ..strokeCap   = .round,
      );
    }
  }

  @override
  bool shouldRepaint(MultiCircleProgressPainter oldDelegate) {
    if (oldDelegate.progress.length != progress.length) return true;

    bool difference = false;
    for (int i = 0; i < oldDelegate.progress.length; i++) {
      if (oldDelegate.progress[i] != progress[i]) difference = true;
    }
    return difference;
  }
}
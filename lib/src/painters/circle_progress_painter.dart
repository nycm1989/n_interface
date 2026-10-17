import 'dart:math' show cos, pi, sin;
import 'package:flutter/material.dart' show Canvas, Color, CustomPainter, Offset, Paint, Size;

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final double width;
  final Color  backgroundColor;
  final Color  progressColor;
  final Color  pointerColor;

  CircleProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.pointerColor,
    this.width = 20
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = (size.width - width) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawArc(
      .fromCircle(center: center, radius: radius),
      pi - (pi * 0.2), // Empieza desde la parte izquierda
      pi + (pi * 0.4), // Dibuja solo la mitad superior del círculo
      false,
      Paint()
      ..color       = backgroundColor
      ..strokeWidth = width
      ..style       = .stroke
      ..strokeCap   = .round,
    );

    // 🔹 Dibujar el progreso (también solo la parte superior)
    final double sweepAngle = progress * (pi + (pi * 0.4)); // Hasta 180°

    canvas.drawArc(
      .fromCircle(center: center, radius: radius),
      pi - (pi * 0.2), // Inicia en la parte izquierda
      sweepAngle, // Avance del progreso
      false,
      Paint()
      ..color       = progressColor
      ..strokeWidth = width
      ..style       = .stroke
      ..strokeCap   = .round,
    );

    // 🔹 Dibujar el puntero (círculo al final de la barra de progreso)
    final double pointerX = center.dx + radius * cos(pi + sweepAngle - (pi * 0.2));
    final double pointerY = center.dy + radius * sin(pi + sweepAngle - (pi * 0.2));

    canvas.drawCircle(
      Offset(pointerX, pointerY),
      width + (width * 0.4),
      Paint() ..color = pointerColor,
    );

    canvas.drawCircle(
      Offset(pointerX, pointerY),
      width / 1.5,
      Paint() ..color = pointerColor,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) => oldDelegate.progress != progress;
}
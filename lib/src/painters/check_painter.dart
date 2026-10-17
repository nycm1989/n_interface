import 'package:flutter/material.dart';

class CheckPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color borderColor;
  final Color backgroundColor;

  CheckPainter({
    required this.progress,
    required this.color,
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {

    canvas.drawRRect(
      .fromRectAndRadius(
        .fromLTWH(0, 0, size.width, size.height),
        .circular(size.width * 0.075),
      ),
      Paint()..color = backgroundColor
    );

    canvas.drawRRect(
      .fromRectAndRadius(
        .fromLTWH(0, 0, size.width, size.height),
        .circular(size.width * 0.2),
      ),
      Paint()
      ..color       = borderColor
      ..strokeWidth = 1
      ..style       = .stroke
    );

    final Path path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.52)
      ..lineTo(size.width * 0.45, size.height * 0.7)
      ..lineTo(size.width * 0.75, size.height * 0.35);

    canvas.drawPath(
      _createAnimatedPath( path, _computePathLength(path) * progress ),
      Paint()
      ..color       = color
      ..strokeWidth = size.width * 0.15
      ..style       = .stroke
      ..strokeCap   = .round
    );
  }

  Path _createAnimatedPath(Path originalPath, double length) {
    final Path path = Path();

    double drawn = 0;

    for (var metric in originalPath.computeMetrics()) {
      final double remaining = length - drawn;
      if (remaining <= 0) break;

      final double segmentLength = remaining.clamp(0.0, metric.length);
      path.addPath(metric.extractPath(0, segmentLength), .zero);
      drawn += segmentLength;
    }

    return path;
  }

  double _computePathLength(Path path) =>
    path.computeMetrics().fold(0.0, (sum, m) => sum + m.length);

  @override
  bool shouldRepaint(covariant CheckPainter oldDelegate) =>
    oldDelegate.progress != progress || oldDelegate.color != color;
}

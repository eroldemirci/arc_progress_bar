import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'dart:math' as math;

class ArcPaint extends CustomPainter {
  double arc;
  double strokeWidth;
  Color curveColor;
  double padding;
  StrokeCap strokeCap;

  ArcPaint(
    this.arc,
    this.curveColor,
    this.strokeWidth,
    this.strokeCap, {
    this.padding = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(
        padding, padding, size.width - padding, size.width - padding);
    final startAngle = -math.pi + vector.radians(0);

    final sweepAngle = arc;
    const useCenter = false;
    final paint = Paint()
      ..strokeCap = strokeCap
      ..color = curveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

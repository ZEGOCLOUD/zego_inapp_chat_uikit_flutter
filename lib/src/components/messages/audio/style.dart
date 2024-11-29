import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SoundWavePainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isAnimating;

  SoundWavePainter({
    required this.progress,
    required this.color,
    required this.isAnimating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isAnimating) {
      return;
    }

    final rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    for (var wave = 0; wave <= progress; wave++) {
      circle(canvas, rect, 5, wave, progress.toInt());
    }
  }

  // animating the opacity according to min radius and waves count.
  void circle(
      Canvas canvas, Rect rect, double minRadius, int wave, int length) {
    Color paintColor;
    double radius;
    if (wave != 0) {
      final opacity = (1 - ((wave - 1) / length)).clamp(0.0, 1.0);
      paintColor = color.withOpacity(opacity);

      radius = minRadius * (1 + 0.5 * wave);
      final paint = Paint()
        ..color = paintColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(rect.center, radius, paint);
    }
  }

  //
  // @override
  // bool shouldRepaint(RipplePainter oldDelegate) => true;

  @override
  bool shouldRepaint(SoundWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

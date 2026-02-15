import 'package:flutter/material.dart';

class TargetingReticlePainter extends CustomPainter {
  final Color color;

  TargetingReticlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final sideLength = size.width * 0.7; // 70% of screen width
    final rect = Rect.fromCenter(
      center: center,
      width: sideLength,
      height: sideLength * 0.6, // Aspect ratio to frame a gun
    );

    // Draw the corners (Tactical style)
    final cornerLength = sideLength * 0.1;

    // Top Left
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(cornerLength, 0), paint);
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(0, cornerLength), paint);

    // Top Right
    canvas.drawLine(rect.topRight, rect.topRight + Offset(-cornerLength, 0), paint);
    canvas.drawLine(rect.topRight, rect.topRight + Offset(0, cornerLength), paint);

    // Bottom Left
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(cornerLength, 0), paint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(0, -cornerLength), paint);

    // Bottom Right
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(-cornerLength, 0), paint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(0, -cornerLength), paint);

    // Draw Center Crosshair
    const crosshairSize = 10.0;
    canvas.drawLine(center + const Offset(-crosshairSize, 0), center + const Offset(crosshairSize, 0), paint);
    canvas.drawLine(center + const Offset(0, -crosshairSize), center + const Offset(0, crosshairSize), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

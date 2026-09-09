import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';

/// Figma dashed connector between stepper circles (84 wide, 2-2 dash).
class DashedConnector extends StatelessWidget {
  const DashedConnector({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScreenUtils.w(84),
      height: 1,
      child: CustomPaint(
        painter: DashedLinePainter(
          color: AppColors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// Draws a horizontal dashed stroke. Reuse anywhere a hairline dash is needed.
class DashedLinePainter extends CustomPainter {
  const DashedLinePainter({
    required this.color,
    this.strokeWidth = 1,
    this.dashWidth = 2,
    this.dashGap = 2,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    final double y = size.height / 2;
    double x = 0;
    while (x < size.width) {
      final double end = (x + dashWidth).clamp(0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}

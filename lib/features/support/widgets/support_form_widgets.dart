import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';

class SupportFieldLabel extends StatelessWidget {
  const SupportFieldLabel(this.text, {super.key, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        style: AppTypography.medium(fontSize: 12),
        children: <InlineSpan>[
          if (required)
            TextSpan(
              text: ' *',
              style: AppTypography.medium(
                fontSize: 12,
                color: const Color(0xFFFF383C),
              ),
            ),
        ],
      ),
    );
  }
}

class SupportTextArea extends StatelessWidget {
  const SupportTextArea({
    required this.controller,
    required this.hintText,
    required this.maxLength,
    super.key,
    this.minHeight = 120,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, _) {
        return Container(
          height: ScreenUtils.h(minHeight),
          padding: EdgeInsets.fromLTRB(
            ScreenUtils.w(12),
            ScreenUtils.h(10),
            ScreenUtils.w(12),
            ScreenUtils.h(8),
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLength: maxLength,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  cursorColor: AppColors.primaryButtonBg,
                  style: AppTypography.regular(fontSize: 13, height: 1.4),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: AppTypography.regular(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.white.withValues(alpha: 0.4),
                    ),
                    counterText: '',
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${value.text.length}/$maxLength',
                  style: AppTypography.regular(
                    fontSize: 10,
                    color: AppColors.mutedGrey,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SupportDropdownField extends StatelessWidget {
  const SupportDropdownField({
    required this.value,
    required this.onTap,
    super.key,
    this.leading,
  });

  final String value;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        child: Container(
          height: ScreenUtils.h(46),
          padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(12)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: <Widget>[
              if (leading != null) ...<Widget>[
                leading!,
                SizedBox(width: ScreenUtils.w(8)),
              ],
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.regular(fontSize: 13),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primaryButtonBg,
                size: ScreenUtils.sp(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> showSupportOptionsSheet({
  required BuildContext context,
  required String title,
  required List<String> options,
  required String selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.cardSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ScreenUtils.r(16)),
      ),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                ScreenUtils.w(16),
                ScreenUtils.h(16),
                ScreenUtils.w(16),
                ScreenUtils.h(8),
              ),
              child: Text(title, style: AppTypography.semiBold(fontSize: 14)),
            ),
            ...options.map(
              (String option) => ListTile(
                title: Text(option, style: AppTypography.medium(fontSize: 14)),
                trailing: selected == option
                    ? const Icon(
                        Icons.check,
                        color: AppColors.primaryButtonBg,
                      )
                    : null,
                onTap: () => Navigator.pop(context, option),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class DashedUploadBox extends StatelessWidget {
  const DashedUploadBox({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRectPainter(
          color: AppColors.white.withValues(alpha: 0.22),
          radius: ScreenUtils.r(8),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: ScreenUtils.h(22)),
          child: Column(
            children: <Widget>[
              Icon(
                Icons.cloud_upload_outlined,
                color: AppColors.primaryButtonBg,
                size: ScreenUtils.sp(28),
              ),
              SizedBox(height: ScreenUtils.h(8)),
              Text(
                'Tap to add photos or files',
                style: AppTypography.semiBold(fontSize: 12),
              ),
              SizedBox(height: ScreenUtils.h(4)),
              Text(
                'JPG, PNG, PDF up to 10MB',
                style: AppTypography.regular(
                  fontSize: 10,
                  color: AppColors.mutedGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final Path path = Path()..addRRect(rrect);
    const double dash = 6;
    const double gap = 4;
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = (distance + dash).clamp(0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

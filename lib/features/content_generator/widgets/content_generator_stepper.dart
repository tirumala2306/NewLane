import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';

class ContentGeneratorStepper extends StatelessWidget {
  const ContentGeneratorStepper({
    required this.currentStep,
    super.key,
  });

  /// 1-based step: Type, Details, Generate, Review.
  final int currentStep;

  static const List<String> labels = <String>[
    'Type',
    'Details',
    'Generate',
    'Review',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(12)),
      child: Row(
        children: List<Widget>.generate(labels.length * 2 - 1, (int index) {
          if (index.isOdd) {
            final int before = index ~/ 2 + 1;
            final bool filled = currentStep > before;
            return Expanded(
              child: Container(
                height: 1,
                margin: EdgeInsets.only(bottom: ScreenUtils.h(16)),
                color: filled
                    ? AppColors.primaryButtonBg
                    : AppColors.white.withValues(alpha: 0.18),
              ),
            );
          }

          final int step = index ~/ 2 + 1;
          final bool active = currentStep >= step;
          return Column(
            children: <Widget>[
              Container(
                width: ScreenUtils.w(22),
                height: ScreenUtils.w(22),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? AppColors.primaryButtonBg
                      : AppColors.white.withValues(alpha: 0.12),
                ),
                child: Text(
                  '$step',
                  style: AppTypography.semiBold(
                    fontSize: 10,
                    color: active
                        ? AppColors.black
                        : AppColors.white.withValues(alpha: 0.55),
                  ),
                ),
              ),
              SizedBox(height: ScreenUtils.h(6)),
              Text(
                labels[step - 1],
                style: AppTypography.medium(
                  fontSize: 9,
                  color: active
                      ? AppColors.primaryButtonBg
                      : AppColors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

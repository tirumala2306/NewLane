import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';

class MarketingStepper extends StatelessWidget {
  const MarketingStepper({
    required this.currentStep,
    super.key,
  });

  final int currentStep;

  static const List<String> labels = <String>[
    'Request Type',
    'Listing / Project',
    'Details',
    'Review',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(8)),
      child: Row(
        children: List<Widget>.generate(labels.length * 2 - 1, (int index) {
          if (index.isOdd) {
            final int before = index ~/ 2;
            final bool filled = currentStep > before;
            return Expanded(
              child: Container(
                height: 1.5,
                color: filled
                    ? AppColors.primaryButtonBg
                    : AppColors.white.withValues(alpha: 0.2),
              ),
            );
          }
          final int step = index ~/ 2;
          final bool active = currentStep >= step;
          return Column(
            children: <Widget>[
              Container(
                width: ScreenUtils.w(10),
                height: ScreenUtils.w(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? AppColors.primaryButtonBg
                      : AppColors.white.withValues(alpha: 0.2),
                ),
              ),
              SizedBox(height: ScreenUtils.h(6)),
              SizedBox(
                width: ScreenUtils.w(70),
                child: Text(
                  labels[step],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: AppTypography.medium(
                    fontSize: 8,
                    height: 1.2,
                    color: active
                        ? AppColors.primaryButtonBg
                        : AppColors.white.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

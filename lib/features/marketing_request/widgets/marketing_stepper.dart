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
    final double circleSize = ScreenUtils.w(28);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.generate(labels.length * 2 - 1, (int index) {
          if (index.isOdd) {
            final int before = index ~/ 2;
            // Gold from the current step onward to the next circle.
            final bool filled = currentStep >= before;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: circleSize / 2 - 1),
                child: Container(
                  height: 2,
                  color: filled
                      ? AppColors.primaryButtonBg
                      : AppColors.white.withValues(alpha: 0.22),
                ),
              ),
            );
          }

          final int step = index ~/ 2;
          final bool isCurrent = currentStep == step;
          final bool isDone = currentStep > step;
          final bool isActive = isCurrent || isDone;

          return SizedBox(
            width: ScreenUtils.w(72),
            child: Column(
              children: <Widget>[
                Container(
                  width: circleSize,
                  height: circleSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone || isCurrent
                        ? AppColors.primaryButtonBg
                        : Colors.transparent,
                    border: Border.all(
                      color: AppColors.primaryButtonBg.withValues(
                        alpha: isActive ? 1 : 0.55,
                      ),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '${step + 1}',
                    style: AppTypography.semiBold(
                      fontSize: 12,
                      color: isDone || isCurrent
                          ? AppColors.black
                          : AppColors.primaryButtonBg.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtils.h(8)),
                Text(
                  labels[step],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.medium(
                    fontSize: 9,
                    height: 1.2,
                    color: isActive
                        ? AppColors.primaryButtonBg
                        : AppColors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

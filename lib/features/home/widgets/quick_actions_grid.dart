import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/data/mock/home_mock_data.dart';
import 'package:newlane/shared/widgets/app_svg.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({
    required this.actions,
    super.key,
    this.onActionTap,
  });

  final List<HomeQuickAction> actions;
  final ValueChanged<HomeQuickAction>? onActionTap;

  static const Color _tileBg = Color(0x0DFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(actions.length, (int index) {
        final bool isFirst = index == 0;
        final bool isLast = index == actions.length - 1;
        final double halfGap = ScreenUtils.w(4) / 2;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: isFirst ? 0 : halfGap,
              right: isLast ? 0 : halfGap,
            ),
            child: _QuickActionTile(
              action: actions[index],
              onTap: () => onActionTap?.call(actions[index]),
            ),
          ),
        );
      }),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.action,
    required this.onTap,
  });

  final HomeQuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(ScreenUtils.r(6));

    return Material(
      color: QuickActionsGrid._tileBg,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: AppColors.primaryButtonBg.withValues(alpha: 0.2),
        highlightColor: AppColors.primaryButtonBg.withValues(alpha: 0.08),
        child: SizedBox(
          height: ScreenUtils.h(104),
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtils.w(6),
              vertical: ScreenUtils.h(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _icon(),
                SizedBox(height: ScreenUtils.h(4)),
                Text(
                  action.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.semiBold(fontSize: 10, height: 1.2),
                ),
                SizedBox(height: ScreenUtils.h(4)),
                Text(
                  action.subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.regular(fontSize: 8, height: 1.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _icon() {
    if (action.assetIcon != null) {
      return AppSvg(
        action.assetIcon!,
        width: ScreenUtils.w(24),
        height: ScreenUtils.w(24),
        color: AppColors.primaryButtonBg,
      );
    }

    return Icon(
      action.icon,
      size: ScreenUtils.sp(24),
      color: AppColors.primaryButtonBg,
    );
  }
}

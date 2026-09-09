import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/widgets/auth_header.dart';

/// Four benefit columns under the request-access form.
class WhyRequestAccessSection extends StatelessWidget {
  const WhyRequestAccessSection({super.key});

  static const List<WhyAccessItem> items = <WhyAccessItem>[
    WhyAccessItem(icon: Icons.groups_outlined, label: 'Collaborate with your team'),
    WhyAccessItem(icon: Icons.chat_bubble_outline, label: 'Stay updated in real time'),
    WhyAccessItem(icon: Icons.campaign_outlined, label: 'Access exclusive resources'),
    WhyAccessItem(icon: Icons.verified_user_outlined, label: 'Secure & private platform'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const AuthDividerLabel(
          label: 'Why request access?',
          color: AppColors.primaryButtonBg,
          fontSize: 10,
        ),
        SizedBox(height: ScreenUtils.h(22)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int i = 0; i < items.length; i++)
              Expanded(
                child: WhyAccessColumn(item: items[i], showDivider: i > 0),
              ),
          ],
        ),
      ],
    );
  }
}

/// Data for one "why request access" column.
class WhyAccessItem {
  const WhyAccessItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Icon + short label, with an optional gold hairline on the left.
class WhyAccessColumn extends StatelessWidget {
  const WhyAccessColumn({
    required this.item,
    super.key,
    this.showDivider = false,
  });

  final WhyAccessItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showDivider)
          Container(
            width: 1,
            height: ScreenUtils.h(56),
            margin: EdgeInsets.only(right: ScreenUtils.w(6)),
            color: AppColors.primaryButtonBg.withValues(alpha: 0.2),
          ),
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                width: ScreenUtils.w(30),
                height: ScreenUtils.w(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryButtonBg.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  item.icon,
                  size: ScreenUtils.sp(16),
                  color: AppColors.primaryButtonBg,
                ),
              ),
              SizedBox(height: ScreenUtils.h(8)),
              SizedBox(
                width: ScreenUtils.w(62),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: AppTypography.medium(fontSize: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

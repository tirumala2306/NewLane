import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/widgets/home_card.dart';
import 'package:newlane/features/profile/data/mock/profile_mock_data.dart';
import 'package:newlane/shared/widgets/app_svg.dart';

class ProfileContactCard extends StatelessWidget {
  const ProfileContactCard({
    required this.contacts,
    super.key,
  });

  final List<ProfileContactItem> contacts;

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Contact Information',
            style: AppTypography.semiBold(fontSize: 16),
          ),
          SizedBox(height: ScreenUtils.h(8)),
          ...List<Widget>.generate(contacts.length, (int index) {
            final ProfileContactItem item = contacts[index];
            return Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtils.h(12)),
                  child: Row(
                    children: <Widget>[
                      _ContactLeading(item: item),
                      SizedBox(width: ScreenUtils.w(12)),
                      Expanded(
                        child: Text(
                          item.value,
                          style: AppTypography.medium(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < contacts.length - 1)
                  Divider(height: 1, color: AppColors.divider),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ContactLeading extends StatelessWidget {
  const _ContactLeading({required this.item});

  final ProfileContactItem item;

  @override
  Widget build(BuildContext context) {
    final double size = ScreenUtils.sp(18);
    if (item.iconAsset != null) {
      return AppSvg(
        item.iconAsset!,
        width: size,
        height: size,
        color: AppColors.primaryButtonBg,
      );
    }
    return Icon(
      item.icon,
      size: size,
      color: AppColors.primaryButtonBg,
    );
  }
}

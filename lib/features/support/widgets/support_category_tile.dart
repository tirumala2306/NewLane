import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/widgets/home_card.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';

class SupportCategoryTile extends StatelessWidget {
  const SupportCategoryTile({required this.category, super.key, this.onTap});

  final SupportCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      padding: EdgeInsets.all(ScreenUtils.w(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: HomeCard.radius,
        child: Row(
          children: <Widget>[
            _IconBox(icon: category.icon),
            SizedBox(width: ScreenUtils.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    category.title,
                    style: AppTypography.semiBold(fontSize: 12),
                  ),
                  SizedBox(height: ScreenUtils.h(6)),
                  Text(
                    category.description,
                    style: AppTypography.medium(
                      fontSize: 10,
                      height: 1.5,
                      color: AppColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: ScreenUtils.w(50)),
            Icon(
              Icons.chevron_right,
              size: ScreenUtils.sp(24),
              color: AppColors.primaryButtonBg,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtils.w(40),
      height: ScreenUtils.w(40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        color: AppColors.primaryButtonBg.withValues(alpha: 0.1),
      ),
      child: Icon(
        icon,
        size: ScreenUtils.sp(24),
        color: AppColors.primaryButtonBg,
      ),
    );
  }
}

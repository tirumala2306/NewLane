import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/widgets/home_card.dart';

class OfficeCard extends StatelessWidget {
  const OfficeCard({
    required this.officeName,
    super.key,
    this.onViewOffice,
  });

  final String officeName;
  final VoidCallback? onViewOffice;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardSurface,
      borderRadius: HomeCard.radius,
      child: InkWell(
        onTap: onViewOffice,
        borderRadius: HomeCard.radius,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(ScreenUtils.w(16)),
          decoration: BoxDecoration(
            borderRadius: HomeCard.radius,
            border: Border.all(color: HomeCard.borderColor),
          ),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'YOUR OFFICE',
                    style: AppTypography.medium(fontSize: 10),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: ScreenUtils.sp(20),
                    color: AppColors.white,
                  ),
                ],
              ),
              SizedBox(height: ScreenUtils.h(4)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      officeName,
                      style: AppTypography.medium(fontSize: 16),
                    ),
                  ),
                  Text(
                    'View Office',
                    style: AppTypography.medium(
                      fontSize: 10,
                      color: AppColors.primaryButtonBg,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

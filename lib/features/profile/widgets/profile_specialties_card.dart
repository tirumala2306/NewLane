import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/widgets/home_card.dart';

class ProfileSpecialtiesCard extends StatelessWidget {
  const ProfileSpecialtiesCard({
    required this.specialties,
    super.key,
  });

  final List<String> specialties;

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Specialties', style: AppTypography.semiBold(fontSize: 16)),
          SizedBox(height: ScreenUtils.h(12)),
          Wrap(
            spacing: ScreenUtils.w(8),
            runSpacing: ScreenUtils.h(8),
            children: specialties
                .map(
                  (String label) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtils.w(12),
                      vertical: ScreenUtils.h(8),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ScreenUtils.r(20)),
                      border: Border.all(
                        color: AppColors.primaryButtonBg.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      label,
                      style: AppTypography.medium(
                        fontSize: 10,
                        color: AppColors.primaryButtonBg,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

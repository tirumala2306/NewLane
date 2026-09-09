import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';

class MoreSectionTitle extends StatelessWidget {
  const MoreSectionTitle(
    this.title, {
    super.key,
    this.gold = false,
  });

  final String title;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.semiBold(
        fontSize: gold ? 11 : 14,
        color: gold ? AppColors.primaryButtonBg : AppColors.white,
      ),
    );
  }
}

class MoreLabeledValue extends StatelessWidget {
  const MoreLabeledValue({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AppTypography.medium(
            fontSize: 11,
            color: AppColors.primaryButtonBg,
          ),
        ),
        SizedBox(height: ScreenUtils.h(6)),
        Text(
          value.trim().isEmpty ? '—' : value,
          style: AppTypography.regular(fontSize: 14, height: 1.3),
        ),
      ],
    );
  }
}

class MoreToggleRow extends StatelessWidget {
  const MoreToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: AppTypography.semiBold(fontSize: 13)),
              if (subtitle != null) ...<Widget>[
                SizedBox(height: ScreenUtils.h(4)),
                Text(
                  subtitle!,
                  style: AppTypography.regular(
                    fontSize: 11,
                    height: 1.35,
                    color: AppColors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: ScreenUtils.w(12)),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primaryButtonBg,
          activeTrackColor: AppColors.primaryButtonBg.withValues(alpha: 0.35),
        ),
      ],
    );
  }
}

class MoreNavRow extends StatelessWidget {
  const MoreNavRow({
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: ScreenUtils.h(4)),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: AppTypography.semiBold(fontSize: 13)),
                  if (subtitle != null) ...<Widget>[
                    SizedBox(height: ScreenUtils.h(4)),
                    Text(
                      subtitle!,
                      style: AppTypography.regular(
                        fontSize: 11,
                        color: AppColors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              trailing!,
              SizedBox(width: ScreenUtils.w(8)),
            ],
            Icon(
              Icons.chevron_right,
              color: AppColors.primaryButtonBg,
              size: ScreenUtils.sp(20),
            ),
          ],
        ),
      ),
    );
  }
}

Widget moreDivider() {
  return Divider(
    height: ScreenUtils.h(24),
    thickness: 1,
    color: AppColors.white.withValues(alpha: 0.08),
  );
}

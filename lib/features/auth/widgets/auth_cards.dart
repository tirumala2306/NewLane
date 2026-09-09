import 'package:flutter/material.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/widgets/dashed_lines.dart';
import 'package:newlane/shared/widgets/app_svg.dart';
import 'package:newlane/shared/widgets/glass_container.dart';

/// Frosted card on the login background. One place for blur / asset defaults.
class AuthGlassCard extends StatelessWidget {
  const AuthGlassCard({
    required this.child,
    super.key,
    this.padding,
    this.borderRadius,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      backgroundAsset: AssetConstants.loginBg,
      blurSigma: 30,
      padding: padding ?? EdgeInsets.all(ScreenUtils.h(16)),
      borderRadius: borderRadius,
      borderColor: borderColor,
      child: child,
    );
  }
}

/// Icon + title + message row (email reminder, "didn't receive", etc.).
class AuthInfoBanner extends StatelessWidget {
  const AuthInfoBanner({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
    this.titleSize = 18,
    this.messageSize = 16,
  });

  final Widget icon;
  final String title;
  final String message;
  final double titleSize;
  final double messageSize;

  @override
  Widget build(BuildContext context) {
    return AuthGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          icon,
          SizedBox(width: ScreenUtils.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: AppTypography.semiBold(fontSize: titleSize)),
                SizedBox(height: ScreenUtils.h(8)),
                Text(
                  message,
                  style: AppTypography.regular(
                    fontSize: messageSize,
                    height: 1.4,
                    color: AppColors.white.withValues(alpha: 0.80),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Live checklist for create-password rules.
class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({required this.password, super.key});

  final String password;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenUtils.h(16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtils.r(12)),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Password must contain:',
            style: AppTypography.medium(fontSize: 18),
          ),
          SizedBox(height: ScreenUtils.h(16)),
          PasswordRuleRow(
            label: 'At least 8 characters',
            met: password.length >= 8,
          ),
          SizedBox(height: ScreenUtils.h(18)),
          PasswordRuleRow(
            label: 'One uppercase letter (A-Z)',
            met: RegExp(r'[A-Z]').hasMatch(password),
          ),
          SizedBox(height: ScreenUtils.h(18)),
          PasswordRuleRow(
            label: 'One number (0-9)',
            met: RegExp(r'[0-9]').hasMatch(password),
          ),
          SizedBox(height: ScreenUtils.h(18)),
          PasswordRuleRow(
            label: 'One special character (!@#\$%)',
            met: RegExp(r'[!@#$%]').hasMatch(password),
          ),
        ],
      ),
    );
  }
}

/// Single check-row inside [PasswordRequirements].
class PasswordRuleRow extends StatelessWidget {
  const PasswordRuleRow({required this.label, required this.met, super.key});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        AppSvg(
          AssetConstants.circleCheckIcon,
          width: ScreenUtils.w(24),
          height: ScreenUtils.w(24),
          color: met
              ? AppColors.primaryButtonBg
              : AppColors.white.withValues(alpha: 0.35),
        ),
        SizedBox(width: ScreenUtils.w(10)),
        Expanded(
          child: Text(
            label,
            style: AppTypography.medium(
              fontSize: 16,
              color: AppColors.white.withValues(alpha: met ? 0.85 : 0.55),
            ),
          ),
        ),
      ],
    );
  }
}

/// Horizontal 3-step progress (submitted → review → email).
class AuthStepper extends StatelessWidget {
  const AuthStepper({required this.steps, super.key});

  final List<AuthStepItem> steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < steps.length; i++) ...<Widget>[
          Expanded(child: steps[i]),
          if (i < steps.length - 1)
            Padding(
              padding: EdgeInsets.only(top: ScreenUtils.h(18)),
              child: const DashedConnector(),
            ),
        ],
      ],
    );
  }
}

/// One circle + label in [AuthStepper].
class AuthStepItem extends StatelessWidget {
  const AuthStepItem({
    required this.icon,
    required this.label,
    super.key,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive
        ? AppColors.primaryButtonBg
        : AppColors.white.withValues(alpha: 0.35);

    return Column(
      children: <Widget>[
        Container(
          width: ScreenUtils.w(40),
          height: ScreenUtils.w(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.primaryButtonBg.withValues(alpha: 0.15)
                : Colors.transparent,
            border: Border.all(color: color),
          ),
          child: Icon(icon, size: ScreenUtils.sp(18), color: color),
        ),
        SizedBox(height: ScreenUtils.h(8)),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.medium(
            fontSize: 8,
            height: 1.5,
            color: isActive
                ? AppColors.white
                : AppColors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

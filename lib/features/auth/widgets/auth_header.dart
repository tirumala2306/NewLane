import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';

/// Title + gold bar + optional subtitle. Used at the top of every auth screen.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    required this.title,
    super.key,
    this.accentTitle,
    this.subtitles = const <String>[],
    this.subtitleWidth,
    this.titleFontSize = 32,
    this.subtitleFontSize = 14,
    this.center = false,
  });

  /// Main heading (white).
  final String title;

  /// Optional second line in gold (e.g. ACCESS / PENDING).
  final String? accentTitle;

  /// One or more body lines under the gold bar.
  final List<String> subtitles;

  /// Caps subtitle width (Figma uses a narrow column on some screens).
  final double? subtitleWidth;

  final double titleFontSize;
  final double subtitleFontSize;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final CrossAxisAlignment align =
        center ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final TextAlign textAlign = center ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: align,
      children: <Widget>[
        Text(
          title,
          textAlign: textAlign,
          style: AppTypography.medium(fontSize: titleFontSize),
        ),
        if (accentTitle != null) ...<Widget>[
          SizedBox(height: ScreenUtils.h(10)),
          Text(
            accentTitle!,
            textAlign: textAlign,
            style: AppTypography.medium(
              fontSize: titleFontSize,
              color: AppColors.primaryButtonBg,
            ),
          ),
        ],
        SizedBox(height: ScreenUtils.h(12)),
        const AuthGoldBar(),
        if (subtitles.isNotEmpty) ...<Widget>[
          SizedBox(height: ScreenUtils.h(12)),
          SizedBox(
            width: subtitleWidth,
            child: Column(
              crossAxisAlignment: align,
              children: <Widget>[
                for (int i = 0; i < subtitles.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(height: ScreenUtils.h(4)),
                  Text(
                    subtitles[i],
                    textAlign: textAlign,
                    style: AppTypography.medium(
                      fontSize: subtitleFontSize,
                      height: 1.5,
                      color: AppColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Short gold line under auth titles.
class AuthGoldBar extends StatelessWidget {
  const AuthGoldBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtils.w(42),
      height: ScreenUtils.h(2),
      color: AppColors.primaryButtonBg,
    );
  }
}

/// Label with gold (or custom) rules on both sides. e.g. "Need Help".
class AuthDividerLabel extends StatelessWidget {
  const AuthDividerLabel({
    required this.label,
    super.key,
    this.color,
    this.lineColor,
    this.fontSize = 14,
  });

  final String label;
  final Color? color;
  final Color? lineColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final Color line =
        lineColor ?? color ?? AppColors.white.withValues(alpha: 0.35);

    return Row(
      children: <Widget>[
        Expanded(child: Divider(color: line, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(12)),
          child: Text(
            label,
            style: AppTypography.medium(
              fontSize: fontSize,
              color: color ?? AppColors.white,
            ),
          ),
        ),
        Expanded(child: Divider(color: line, thickness: 1)),
      ],
    );
  }
}

/// "Already have an account? Sign In" style prompt.
class AuthInlineLink extends StatelessWidget {
  const AuthInlineLink({
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
    super.key,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(prompt, style: AppTypography.medium(fontSize: 12)),
          GestureDetector(
            onTap: onTap,
            child: Text(
              actionLabel,
              style: AppTypography.medium(
                fontSize: 12,
                color: AppColors.primaryButtonBg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


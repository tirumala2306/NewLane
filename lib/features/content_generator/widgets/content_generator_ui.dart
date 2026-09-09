import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/shared/widgets/app_svg.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

PreferredSizeWidget contentGeneratorAppBar(
  BuildContext context, {
  required String title,
  String? description,
}) {
  return NewLaneAppBar(
    prefixIcon: Icons.arrow_back_ios_new,
    prefixIconColor: AppColors.white,
    onPrefixPressed: () => context.pop(),
    title: title,
    titleFontSize: 16,
    description: description,
    descriptionFontSize: 10,
    height: ScreenUtils.h(56),
  );
}

class ContentTypeCard extends StatelessWidget {
  const ContentTypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final ContentGeneratorType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(ScreenUtils.r(10));

    return Material(
      color: const Color(0xFF111111),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtils.w(12),
            vertical: ScreenUtils.h(16),
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: selected
                  ? AppColors.primaryButtonBg
                  : AppColors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (type.assetIcon != null)
                AppSvg(
                  type.assetIcon!,
                  width: ScreenUtils.w(28),
                  height: ScreenUtils.w(28),
                  color: AppColors.primaryButtonBg,
                )
              else
                Icon(
                  type.icon,
                  size: ScreenUtils.sp(28),
                  color: AppColors.primaryButtonBg,
                ),
              SizedBox(height: ScreenUtils.h(10)),
              Text(
                type.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.semiBold(fontSize: 12, height: 1.2),
              ),
              SizedBox(height: ScreenUtils.h(6)),
              Text(
                type.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.regular(
                  fontSize: 9,
                  height: 1.3,
                  color: AppColors.mutedGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContentFieldLabel extends StatelessWidget {
  const ContentFieldLabel(this.text, {super.key, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        style: AppTypography.medium(fontSize: 12),
        children: <InlineSpan>[
          if (required)
            TextSpan(
              text: ' *',
              style: AppTypography.medium(
                fontSize: 12,
                color: AppColors.primaryButtonBg,
              ),
            ),
        ],
      ),
    );
  }
}

class ContentTextArea extends StatelessWidget {
  const ContentTextArea({
    required this.controller,
    required this.hintText,
    required this.maxLength,
    super.key,
    this.minHeight = 96,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, _) {
        return Container(
          height: ScreenUtils.h(minHeight),
          padding: EdgeInsets.fromLTRB(
            ScreenUtils.w(12),
            ScreenUtils.h(10),
            ScreenUtils.w(12),
            ScreenUtils.h(8),
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLength: maxLength,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  cursorColor: AppColors.primaryButtonBg,
                  style: AppTypography.regular(fontSize: 13, height: 1.4),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: AppTypography.regular(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.white.withValues(alpha: 0.4),
                    ),
                    counterText: '',
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${value.text.length}/$maxLength',
                  style: AppTypography.regular(
                    fontSize: 10,
                    color: AppColors.mutedGrey,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ContentDropdownField extends StatelessWidget {
  const ContentDropdownField({
    required this.value,
    required this.onTap,
    super.key,
    this.leading,
    this.borderColor,
  });

  final String value;
  final VoidCallback onTap;
  final Widget? leading;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        child: Container(
          height: ScreenUtils.h(46),
          padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(12)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
            border: Border.all(
              color: borderColor ?? AppColors.glassBorder,
            ),
          ),
          child: Row(
            children: <Widget>[
              if (leading != null) ...<Widget>[
                leading!,
                SizedBox(width: ScreenUtils.w(8)),
              ],
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.regular(fontSize: 13),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.white.withValues(alpha: 0.7),
                size: ScreenUtils.sp(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> showContentOptionsSheet({
  required BuildContext context,
  required String title,
  required List<String> options,
  required String selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.cardSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ScreenUtils.r(16)),
      ),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                ScreenUtils.w(16),
                ScreenUtils.h(16),
                ScreenUtils.w(16),
                ScreenUtils.h(8),
              ),
              child: Text(title, style: AppTypography.semiBold(fontSize: 14)),
            ),
            ...options.map(
              (String option) => ListTile(
                title: Text(
                  option,
                  style: AppTypography.medium(fontSize: 14),
                ),
                trailing: selected == option
                    ? const Icon(
                        Icons.check,
                        color: AppColors.primaryButtonBg,
                      )
                    : null,
                onTap: () => Navigator.pop(context, option),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class ContentSegmentedTabs extends StatelessWidget {
  const ContentSegmentedTabs({
    required this.left,
    required this.right,
    required this.leftSelected,
    required this.onLeft,
    required this.onRight,
    super.key,
  });

  final String left;
  final String right;
  final bool leftSelected;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _TabChip(
            label: left,
            selected: leftSelected,
            onTap: onLeft,
          ),
        ),
        SizedBox(width: ScreenUtils.w(10)),
        Expanded(
          child: _TabChip(
            label: right,
            selected: !leftSelected,
            onTap: onRight,
          ),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        child: Container(
          height: ScreenUtils.h(40),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
            border: Border.all(
              color: selected
                  ? AppColors.primaryButtonBg
                  : AppColors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Text(
            label,
            style: AppTypography.semiBold(
              fontSize: 12,
              color: selected ? AppColors.primaryButtonBg : AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class ContentBottomBar extends StatelessWidget {
  const ContentBottomBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(16),
          ScreenUtils.h(8),
          ScreenUtils.w(16),
          ScreenUtils.h(12),
        ),
        child: child,
      ),
    );
  }
}

class ContentPairButtons extends StatelessWidget {
  const ContentPairButtons({
    required this.leftLabel,
    required this.rightLabel,
    required this.onLeft,
    required this.onRight,
    super.key,
    this.rightFilled = true,
  });

  final String leftLabel;
  final String rightLabel;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final bool rightFilled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: UnifiedButton.outline(
            label: leftLabel,
            onPressed: onLeft,
            isExpanded: true,
          ),
        ),
        SizedBox(width: ScreenUtils.w(10)),
        Expanded(
          child: rightFilled
              ? UnifiedButton(
                  label: rightLabel,
                  onPressed: onRight,
                  isExpanded: true,
                )
              : UnifiedButton.outline(
                  label: rightLabel,
                  onPressed: onRight,
                  isExpanded: true,
                ),
        ),
      ],
    );
  }
}

class ContentTypeHeader extends StatelessWidget {
  const ContentTypeHeader({required this.type, super.key});

  final ContentGeneratorType type;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (type.assetIcon != null)
          AppSvg(
            type.assetIcon!,
            width: ScreenUtils.w(22),
            height: ScreenUtils.w(22),
          )
        else
          Icon(
            type.icon,
            size: ScreenUtils.sp(22),
            color: AppColors.primaryButtonBg,
          ),
        SizedBox(width: ScreenUtils.w(8)),
        Expanded(
          child: Text(
            type.title,
            style: AppTypography.semiBold(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

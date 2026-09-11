import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

PreferredSizeWidget contentGeneratorAppBar(
  BuildContext context, {
  required String title,
  String? description,
  Widget? suffix,
  VoidCallback? onBack,
}) {
  return NewLaneAppBar(
    prefixIcon: Icons.arrow_back_ios_new,
    onPrefixPressed: onBack ?? () => context.pop(),
    title: title,
    titleFontSize: 16,
    description: description,
    descriptionFontSize: 10,
    height: ScreenUtils.h(56),
    suffix: suffix,
  );
}

class ContentPhaseTabs extends StatelessWidget {
  const ContentPhaseTabs({
    required this.activeIndex,
    super.key,
  });

  final int activeIndex;

  static const List<String> _labels = <String>[
    'Details',
    'Templates',
    'Preview',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(_labels.length, (int index) {
        final bool active = index == activeIndex;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index == _labels.length - 1 ? 0 : ScreenUtils.w(8),
            ),
            padding: EdgeInsets.symmetric(vertical: ScreenUtils.h(10)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
              border: Border.all(
                color: active
                    ? AppColors.primaryButtonBg
                    : AppColors.white.withValues(alpha: 0.12),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _labels[index],
              style: AppTypography.semiBold(
                fontSize: 12,
                color: active ? AppColors.primaryButtonBg : AppColors.mutedGrey,
              ),
            ),
          ),
        );
      }),
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
  });

  final String value;
  final VoidCallback onTap;
  final Widget? leading;

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
            border: Border.all(color: AppColors.glassBorder),
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

class ContentBottomBar extends StatelessWidget {
  const ContentBottomBar({required this.child, super.key});

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
    this.leftIcon,
    this.rightIcon,
  });

  final String leftLabel;
  final String rightLabel;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final Widget? leftIcon;
  final Widget? rightIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: UnifiedButton.outline(
            label: leftLabel,
            onPressed: onLeft,
            isExpanded: true,
            icon: leftIcon,
          ),
        ),
        SizedBox(width: ScreenUtils.w(10)),
        Expanded(
          child: UnifiedButton(
            label: rightLabel,
            onPressed: onRight,
            isExpanded: true,
            icon: rightIcon,
          ),
        ),
      ],
    );
  }
}

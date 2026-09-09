import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';

/// App-wide text field (glass-style by default).
///
/// Design defaults: 302×46, radius 8, border `#EFEFEF33`,
/// padding 10/16/10/16, icon–text gap 10.
///
/// ```dart
/// CustomTextField(
///   hintText: 'Full Name',
///   prefixIcon: Icon(Icons.person_outline),
///   controller: nameController,
/// )
/// ```
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.width,
    this.height,
    this.isExpanded = false,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.focusedBorderColor,
    this.fillColor,
    this.contentPadding,
    this.iconGap,
    this.style,
    this.hintStyle,
    this.cursorColor,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextAlign textAlign;

  /// Design width 302. Ignored when [isExpanded] is true.
  final double? width;

  /// Design height 46.
  final double? height;

  /// Stretch to parent width (ignores [width]).
  final bool isExpanded;

  final double? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? fillColor;

  /// Default: top 10, right 16, bottom 10, left 16.
  final EdgeInsetsGeometry? contentPadding;

  /// Gap between prefix/suffix icon and text. Default 10.
  final double? iconGap;

  final TextStyle? style;
  final TextStyle? hintStyle;
  final Color? cursorColor;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = width ?? ScreenUtils.w(302);
    final double fieldHeight = height ?? ScreenUtils.h(46);
    final double radius = borderRadius ?? ScreenUtils.r(8);
    final double stroke = borderWidth ?? 1;
    final Color strokeColor = borderColor ?? AppColors.glassBorder;
    final Color focusStroke =
        focusedBorderColor ?? AppColors.primaryButtonBg;
    final Color background =
        fillColor ?? AppColors.white.withValues(alpha: 0.05);
    final double gap = iconGap ?? ScreenUtils.w(10);
    final EdgeInsetsGeometry padding =
        contentPadding ??
        EdgeInsets.fromLTRB(
          ScreenUtils.w(16),
          ScreenUtils.h(10),
          ScreenUtils.w(16),
          ScreenUtils.h(10),
        );

    final TextStyle resolvedStyle =
        style ?? AppTypography.regular(fontSize: 14);
    final TextStyle resolvedHint =
        hintStyle ??
        AppTypography.regular(
          fontSize: 14,
          color: AppColors.white.withValues(alpha: 0.45),
        );

    return SizedBox(
      width: isExpanded ? double.infinity : fieldWidth,
      height: fieldHeight,
      child: _FocusBorder(
        borderRadius: radius,
        borderWidth: stroke,
        idleColor: strokeColor,
        focusedColor: focusStroke,
        fillColor: background,
        focusNode: focusNode,
        builder: (BuildContext context, FocusNode node) {
          return Padding(
            padding: padding,
            child: Row(
              children: <Widget>[
                if (prefixIcon != null) ...<Widget>[
                  IconTheme(
                    data: IconThemeData(
                      color: AppColors.white.withValues(alpha: 0.5),
                      size: ScreenUtils.sp(20),
                    ),
                    child: prefixIcon!,
                  ),
                  SizedBox(width: gap),
                ],
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: node,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    onTap: onTap,
                    keyboardType: keyboardType,
                    textInputAction: textInputAction,
                    inputFormatters: inputFormatters,
                    obscureText: obscureText,
                    enabled: enabled,
                    readOnly: readOnly,
                    autofocus: autofocus,
                    maxLines: obscureText ? 1 : maxLines,
                    minLines: minLines,
                    maxLength: maxLength,
                    textAlign: textAlign,
                    style: resolvedStyle,
                    cursorColor: cursorColor ?? AppColors.primaryButtonBg,
                    autocorrect: autocorrect,
                    enableSuggestions: enableSuggestions,
                    textCapitalization: textCapitalization,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: hintText,
                      hintStyle: resolvedHint,
                      counterText: '',
                    ),
                  ),
                ),
                if (suffixIcon != null) ...<Widget>[
                  SizedBox(width: gap),
                  IconTheme(
                    data: IconThemeData(
                      color: AppColors.white.withValues(alpha: 0.5),
                      size: ScreenUtils.sp(20),
                    ),
                    child: suffixIcon!,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Draws idle / focused border around the field.
class _FocusBorder extends StatefulWidget {
  const _FocusBorder({
    required this.builder,
    required this.borderRadius,
    required this.borderWidth,
    required this.idleColor,
    required this.focusedColor,
    required this.fillColor,
    this.focusNode,
  });

  final Widget Function(BuildContext context, FocusNode node) builder;
  final double borderRadius;
  final double borderWidth;
  final Color idleColor;
  final Color focusedColor;
  final Color fillColor;
  final FocusNode? focusNode;

  @override
  State<_FocusBorder> createState() => _FocusBorderState();
}

class _FocusBorderState extends State<_FocusBorder> {
  FocusNode? _ownedNode;
  late FocusNode _node;

  @override
  void initState() {
    super.initState();
    _attachNode(widget.focusNode);
  }

  @override
  void didUpdateWidget(covariant _FocusBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _detachNode();
      _attachNode(widget.focusNode);
    }
  }

  void _attachNode(FocusNode? external) {
    if (external != null) {
      _node = external;
      _ownedNode = null;
    } else {
      _ownedNode = FocusNode();
      _node = _ownedNode!;
    }
    _node.addListener(_onFocusChange);
  }

  void _detachNode() {
    _node.removeListener(_onFocusChange);
    _ownedNode?.dispose();
    _ownedNode = null;
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _detachNode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool focused = _node.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: widget.fillColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: focused ? widget.focusedColor : widget.idleColor,
          width: widget.borderWidth,
        ),
      ),
      child: widget.builder(context, _node),
    );
  }
}

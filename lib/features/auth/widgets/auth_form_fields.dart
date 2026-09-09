import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/shared/widgets/custom_text_field.dart';

/// Auth input defaults: full width, gold focus, light fill, solid border.
class AuthInput extends StatelessWidget {
  const AuthInput({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.height,
    this.contentPadding,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final int? maxLength;
  final double? height;
  final EdgeInsetsGeometry? contentPadding;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      maxLines: maxLines,
      maxLength: maxLength,
      height: height,
      contentPadding: contentPadding,
      textCapitalization: textCapitalization,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      isExpanded: true,
      borderColor: const Color(0xFFEFEFEF),
      focusedBorderColor: AppColors.primaryButtonBg,
      fillColor: AppColors.white.withValues(alpha: 0.05),
    );
  }
}

/// Field label stacked above any child (input, select, bio).
class AuthLabeledField extends StatelessWidget {
  const AuthLabeledField({
    required this.label,
    required this.child,
    super.key,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTypography.medium(fontSize: 16)),
        SizedBox(height: ScreenUtils.h(8)),
        child,
      ],
    );
  }
}

/// Password input that owns its show/hide state.
class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    required this.controller,
    super.key,
    this.label = 'Password',
    this.hintText = '* * * * * * * *',
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.showLockIcon = false,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool showLockIcon;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AuthLabeledField(
      label: widget.label,
      child: AuthInput(
        controller: widget.controller,
        hintText: widget.hintText,
        obscureText: _obscure,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
        autocorrect: false,
        enableSuggestions: false,
        prefixIcon: widget.showLockIcon
            ? Icon(
                Icons.lock_outline,
                color: AppColors.white.withValues(alpha: 0.8),
                size: ScreenUtils.sp(20),
              )
            : null,
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscure = !_obscure),
          child: Icon(
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.primaryButtonBg,
          ),
        ),
      ),
    );
  }
}

/// Read-only row that opens [AuthOptionSheet] (job title, etc.).
class AuthSelectField extends StatelessWidget {
  const AuthSelectField({
    required this.label,
    required this.hint,
    required this.options,
    required this.onSelected,
    super.key,
    this.value,
  });

  final String label;
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onSelected;

  Future<void> _open(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final String? selected = await AuthOptionSheet.show(
      context,
      title: label,
      options: options,
      selected: value,
    );
    if (selected != null) onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return AuthLabeledField(
      label: label,
      child: GestureDetector(
        onTap: () => _open(context),
        child: Container(
          width: double.infinity,
          height: ScreenUtils.h(46),
          padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
            border: Border.all(color: const Color(0xFFEFEFEF)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  value ?? hint,
                  style: AppTypography.regular(
                    fontSize: 14,
                    color: value == null
                        ? AppColors.white.withValues(alpha: 0.45)
                        : AppColors.white,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.white.withValues(alpha: 0.8),
                size: ScreenUtils.sp(22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet list used by [AuthSelectField].
class AuthOptionSheet extends StatelessWidget {
  const AuthOptionSheet({
    required this.title,
    required this.options,
    super.key,
    this.selected,
  });

  final String title;
  final List<String> options;
  final String? selected;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required List<String> options,
    String? selected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtils.r(16)),
        ),
      ),
      builder: (_) => AuthOptionSheet(
        title: title,
        options: options,
        selected: selected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: ScreenUtils.h(12)),
          Container(
            width: ScreenUtils.w(40),
            height: ScreenUtils.h(4),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(ScreenUtils.r(2)),
            ),
          ),
          SizedBox(height: ScreenUtils.h(16)),
          Text(title, style: AppTypography.semiBold(fontSize: 16)),
          SizedBox(height: ScreenUtils.h(8)),
          for (final String option in options)
            ListTile(
              title: Text(
                option,
                style: AppTypography.regular(
                  fontSize: 15,
                  color: option == selected
                      ? AppColors.primaryButtonBg
                      : AppColors.white,
                ),
              ),
              trailing: option == selected
                  ? Icon(
                      Icons.check,
                      color: AppColors.primaryButtonBg,
                      size: ScreenUtils.sp(20),
                    )
                  : null,
              onTap: () => Navigator.of(context).pop(option),
            ),
          SizedBox(height: ScreenUtils.h(8)),
        ],
      ),
    );
  }
}

/// Multi-select specialties: chips + free-text add.
class AuthSpecialtiesField extends StatefulWidget {
  const AuthSpecialtiesField({
    required this.selected,
    required this.onChanged,
    super.key,
    this.suggestions = const <String>[
      'Luxury Homes',
      'Investments',
      'Relocation',
      'Waterfront',
      'First-Time Buyers',
      'Commercial',
    ],
  });

  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  final List<String> suggestions;

  @override
  State<AuthSpecialtiesField> createState() => _AuthSpecialtiesFieldState();
}

class _AuthSpecialtiesFieldState extends State<AuthSpecialtiesField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) return;
    final bool exists = widget.selected.any(
      (String s) => s.toLowerCase() == value.toLowerCase(),
    );
    if (exists) {
      _controller.clear();
      return;
    }
    widget.onChanged(<String>[...widget.selected, value]);
    _controller.clear();
  }

  void _remove(String value) {
    widget.onChanged(
      widget.selected.where((String s) => s != value).toList(),
    );
  }

  void _toggleSuggestion(String value) {
    final bool selected = widget.selected.any(
      (String s) => s.toLowerCase() == value.toLowerCase(),
    );
    if (selected) {
      _remove(
        widget.selected.firstWhere(
          (String s) => s.toLowerCase() == value.toLowerCase(),
        ),
      );
    } else {
      _add(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> chipOptions = <String>[
      ...widget.suggestions,
      ...widget.selected.where(
        (String s) => !widget.suggestions.any(
          (String g) => g.toLowerCase() == s.toLowerCase(),
        ),
      ),
    ];

    return AuthLabeledField(
      label: 'Specialties',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Select at least one',
            style: AppTypography.regular(
              fontSize: 12,
              color: AppColors.white.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: ScreenUtils.h(8)),
          AuthInput(
            controller: _controller,
            hintText: 'Add a specialty and press enter',
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            onSubmitted: _add,
            suffixIcon: GestureDetector(
              onTap: () => _add(_controller.text),
              child: Icon(
                Icons.add_circle_outline,
                color: AppColors.primaryButtonBg,
                size: ScreenUtils.sp(22),
              ),
            ),
          ),
          SizedBox(height: ScreenUtils.h(12)),
          Wrap(
            spacing: ScreenUtils.w(8),
            runSpacing: ScreenUtils.h(8),
            children: chipOptions.map((String option) {
              final bool isSelected = widget.selected.any(
                (String s) => s.toLowerCase() == option.toLowerCase(),
              );
              return FilterChip(
                label: Text(
                  option,
                  style: AppTypography.medium(
                    fontSize: 11,
                    color: isSelected
                        ? AppColors.black
                        : AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => _toggleSuggestion(option),
                selectedColor: AppColors.primaryButtonBg,
                backgroundColor: AppColors.white.withValues(alpha: 0.05),
                checkmarkColor: AppColors.black,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryButtonBg
                      : const Color(0xFFEFEFEF).withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ScreenUtils.r(20)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Multi-line bio with a live 0/max counter.
class AuthBioField extends StatelessWidget {
  const AuthBioField({
    required this.controller,
    super.key,
    this.maxLength = 120,
  });

  final TextEditingController controller;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return AuthLabeledField(
      label: 'Bio',
      child: Stack(
        children: <Widget>[
          AuthInput(
            controller: controller,
            hintText: 'Tell us about yourself...',
            height: ScreenUtils.h(110),
            maxLines: 5,
            maxLength: maxLength,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            contentPadding: EdgeInsets.fromLTRB(
              ScreenUtils.w(16),
              ScreenUtils.h(12),
              ScreenUtils.w(16),
              ScreenUtils.h(28),
            ),
          ),
          Positioned(
            right: ScreenUtils.w(14),
            bottom: ScreenUtils.h(10),
            child: ListenableBuilder(
              listenable: controller,
              builder: (BuildContext context, Widget? child) {
                return Text(
                  '${controller.text.length}/$maxLength',
                  style: AppTypography.regular(
                    fontSize: 11,
                    color: AppColors.white.withValues(alpha: 0.45),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/more/widgets/more_card.dart';
import 'package:newlane/features/more/widgets/more_settings_widgets.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/custom_text_field.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _next = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNext = true;
  bool _obscureConfirm = true;
  bool _twoFactor = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _next.text.length >= 8;
  bool get _hasCase =>
      RegExp(r'[A-Z]').hasMatch(_next.text) &&
      RegExp(r'[a-z]').hasMatch(_next.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_next.text);
  bool get _hasSpecial => RegExp(r'[^A-Za-z0-9]').hasMatch(_next.text);

  void _updatePassword() {
    if (_current.text.isEmpty ||
        !_hasMinLength ||
        !_hasCase ||
        !_hasNumber ||
        !_hasSpecial ||
        _next.text != _confirm.text) {
      AppSnackBar.showError(
        context,
        title: 'Security',
        message: 'Please meet all password requirements.',
      );
      return;
    }
    AppSnackBar.showSuccess(
      context,
      title: 'Security',
      message: 'Password updated successfully.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        onPrefixPressed: () => context.pop(),
        title: 'SECURITY',
        titleFontSize: 16,
        height: ScreenUtils.h(56),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(16),
          ScreenUtils.h(12),
          ScreenUtils.w(16),
          ScreenUtils.h(32),
        ),
        children: <Widget>[
          const MoreSectionTitle('Change Password'),
          SizedBox(height: ScreenUtils.h(10)),
          MoreCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _passwordField(
                  label: 'Current Password',
                  controller: _current,
                  obscure: _obscureCurrent,
                  onToggle: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                SizedBox(height: ScreenUtils.h(12)),
                _passwordField(
                  label: 'New Password',
                  controller: _next,
                  obscure: _obscureNext,
                  onToggle: () => setState(() => _obscureNext = !_obscureNext),
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: ScreenUtils.h(12)),
                _passwordField(
                  label: 'Confirm New Password',
                  controller: _confirm,
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                SizedBox(height: ScreenUtils.h(16)),
                _requirement('At least 8 characters', _hasMinLength),
                _requirement(
                  'Include uppercase and lowercase letters',
                  _hasCase,
                ),
                _requirement('Include numbers', _hasNumber),
                _requirement('Include special characters', _hasSpecial),
                SizedBox(height: ScreenUtils.h(16)),
                UnifiedButton(
                  label: 'Update Password',
                  onPressed: _updatePassword,
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenUtils.h(12)),
          MoreCard(
            child: Column(
              children: <Widget>[
                MoreToggleRow(
                  title: 'Two-Factor Authentication',
                  subtitle: 'Add an extra layer of security to your account',
                  value: _twoFactor,
                  onChanged: (bool v) => setState(() => _twoFactor = v),
                ),
                moreDivider(),
                MoreNavRow(
                  title: 'Active Sessions',
                  subtitle: 'Manage your active sessions',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    ValueChanged<String>? onChanged,
  }) {
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
        SizedBox(height: ScreenUtils.h(8)),
        CustomTextField(
          controller: controller,
          isExpanded: true,
          obscureText: obscure,
          onChanged: onChanged,
          hintText: '••••••••',
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.primaryButtonBg,
            ),
          ),
        ),
      ],
    );
  }

  Widget _requirement(String label, bool met) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtils.h(8)),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.check_circle,
            size: ScreenUtils.sp(16),
            color: met
                ? AppColors.primaryButtonBg
                : AppColors.white.withValues(alpha: 0.25),
          ),
          SizedBox(width: ScreenUtils.w(8)),
          Expanded(
            child: Text(
              label,
              style: AppTypography.regular(
                fontSize: 12,
                color: met
                    ? AppColors.white
                    : AppColors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

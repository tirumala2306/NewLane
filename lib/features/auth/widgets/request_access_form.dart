import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/widgets/auth_cards.dart';
import 'package:newlane/features/auth/widgets/why_request_session.dart';
import 'package:newlane/shared/widgets/custom_text_field.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

/// Glass form on Request Access: identity fields + submit + "why" row.
class RequestAccessFormCard extends StatelessWidget {
  const RequestAccessFormCard({
    required this.nameController,
    required this.emailController,
    required this.officeController,
    required this.phoneController,
    required this.onRequestAccess,
    this.acceptedTerms = false,
    this.onAcceptedTermsChanged,
    this.onTermsTap,
    this.onPrivacyTap,
    this.isLoading = false,
    super.key,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController officeController;
  final TextEditingController phoneController;
  final VoidCallback onRequestAccess;
  final bool acceptedTerms;
  final ValueChanged<bool>? onAcceptedTermsChanged;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AuthGlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.w(15),
        vertical: ScreenUtils.h(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const RequestAccessFormHeader(),
          SizedBox(height: ScreenUtils.h(16)),
          RequestAccessField(
            controller: nameController,
            hintText: 'Full Name',
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: ScreenUtils.h(12)),
          RequestAccessField(
            controller: emailController,
            hintText: 'Work Email',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: ScreenUtils.h(12)),
          RequestAccessField(
            controller: officeController,
            hintText: 'Office / Brokerage Name',
            icon: Icons.apartment_outlined,
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: ScreenUtils.h(12)),
          RequestAccessField(
            controller: phoneController,
            hintText: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: ScreenUtils.h(16)),
          AuthTermsCheckbox(
            value: acceptedTerms,
            onChanged: onAcceptedTermsChanged,
            onTermsTap: onTermsTap,
            onPrivacyTap: onPrivacyTap,
          ),
          SizedBox(height: ScreenUtils.h(20)),
          UnifiedButton(
            label: 'Request Access',
            isLoading: isLoading,
            onPressed: onRequestAccess,
          ),
          SizedBox(height: ScreenUtils.h(22)),
          const WhyRequestAccessSection(),
        ],
      ),
    );
  }
}

/// Person icon + "Tell us about yourself" heading.
class RequestAccessFormHeader extends StatelessWidget {
  const RequestAccessFormHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: ScreenUtils.w(36),
          height: ScreenUtils.w(36),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryButtonBg.withValues(alpha: 0.6),
            ),
          ),
          child: Icon(
            Icons.person,
            color: AppColors.primaryButtonBg,
            size: ScreenUtils.sp(28),
          ),
        ),
        SizedBox(width: ScreenUtils.w(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Tell us about yourself',
                style: AppTypography.semiBold(fontSize: 14),
              ),
              SizedBox(height: ScreenUtils.h(4)),
              Text(
                'Submit your details to request access.',
                style: AppTypography.regular(
                  fontSize: 12,
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Glass-style field used only on the request-access card (prefix icon + hint).
class RequestAccessField extends StatelessWidget {
  const RequestAccessField({
    required this.controller,
    required this.hintText,
    required this.icon,
    super.key,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: hintText,
      isExpanded: true,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      prefixIcon: Icon(
        icon,
        color: AppColors.white.withValues(alpha: 0.5),
      ),
    );
  }
}

/// "I agree to the Terms & Conditions and Privacy Policy."
class AuthTermsCheckbox extends StatelessWidget {
  const AuthTermsCheckbox({
    required this.value,
    super.key,
    this.onChanged,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: ScreenUtils.w(22),
          height: ScreenUtils.w(22),
          child: Checkbox(
            value: value,
            onChanged: (bool? next) => onChanged?.call(next ?? false),
            side: BorderSide(color: AppColors.white.withValues(alpha: 0.8)),
            activeColor: AppColors.primaryButtonBg,
            checkColor: AppColors.black,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        SizedBox(width: ScreenUtils.w(10)),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: AppTypography.medium(fontSize: 11, height: 1.4),
              children: <InlineSpan>[
                const TextSpan(text: 'I agree to the '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: onTermsTap,
                    child: Text(
                      'Terms & Conditions',
                      style: AppTypography.medium(
                        fontSize: 11,
                        color: AppColors.primaryButtonBg,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: ' and '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: onPrivacyTap,
                    child: Text(
                      'Privacy Policy',
                      style: AppTypography.medium(
                        fontSize: 11,
                        color: AppColors.primaryButtonBg,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

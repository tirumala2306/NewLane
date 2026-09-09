import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/mail_app_launcher.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/widgets/auth_cards.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

/// Glass invite preview shown on Check Your Email.
class CheckEmailInviteCard extends StatelessWidget {
  const CheckEmailInviteCard({
    required this.fullName,
    required this.brokerageName,
    this.workEmail = '',
    super.key,
  });

  final String fullName;
  final String brokerageName;
  final String workEmail;

  Future<void> _openMail(BuildContext context) async {
    final bool opened = await openMailApp();
    if (!context.mounted) return;

    if (!opened) {
      AppSnackBar.showError(
        context,
        title: 'Mail App',
        message:
            'Could not open your mail app. Please check your inbox manually.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGlassCard(
      borderRadius: BorderRadius.circular(ScreenUtils.r(16)),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.mail_outline_rounded,
            size: ScreenUtils.sp(80),
            color: AppColors.primaryButtonBg,
          ),
          SizedBox(height: ScreenUtils.h(12)),
          Text(
            'Welcome to',
            style: AppTypography.regular(
              fontSize: 20,
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: ScreenUtils.h(12)),
          Text(
            'NEWLANE',
            style: AppTypography.regular(
              fontSize: 32,
              color: AppColors.primaryButtonBg,
            ),
          ),
          SizedBox(height: ScreenUtils.h(24)),
          InviteBody(
            fullName: fullName,
            brokerageName: brokerageName,
            workEmail: workEmail,
          ),
          SizedBox(height: ScreenUtils.h(24)),
          UnifiedButton(
            label: 'Activate Account',
            onPressed: () => _openMail(context),
          ),
        ],
      ),
    );
  }
}

/// Inner bordered copy of the invitation email.
class InviteBody extends StatelessWidget {
  const InviteBody({
    required this.fullName,
    required this.brokerageName,
    this.workEmail = '',
    super.key,
  });

  final String fullName;
  final String brokerageName;
  final String workEmail;

  @override
  Widget build(BuildContext context) {
    final TextStyle muted = AppTypography.medium(
      fontSize: 14,
      color: AppColors.white.withValues(alpha: 0.5),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenUtils.w(16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        border: Border.all(color: const Color(0x33EFEFEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: ScreenUtils.h(16),
        children: <Widget>[
          Text('Hi $fullName,', style: muted),
          Text('Your access has been approved.', style: muted),
          Text('Workspace', style: muted),
          Text('NEWLANE', style: AppTypography.medium(fontSize: 26)),
          Row(
            children: <Widget>[
              Icon(
                Icons.location_on_sharp,
                size: ScreenUtils.sp(20),
                color: AppColors.white.withValues(alpha: 0.5),
              ),
              SizedBox(width: ScreenUtils.w(6)),
              Expanded(
                child: Text(
                  brokerageName,
                  style: AppTypography.medium(
                    fontSize: 12,
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          if (workEmail.isNotEmpty)
            Text(
              workEmail,
              style: AppTypography.medium(
                fontSize: 12,
                color: AppColors.white.withValues(alpha: 0.5),
              ),
            ),
          Text(
            'Open your email and tap Activate Account to set your password.',
            style: muted.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

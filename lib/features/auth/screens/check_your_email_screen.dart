import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/constants/app_constants.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/widgets/auth_cards.dart';
import 'package:newlane/features/auth/widgets/auth_header.dart';
import 'package:newlane/features/auth/widgets/auth_scaffold.dart';
import 'package:newlane/features/auth/widgets/check_email_invite_card.dart';

/// Invitation — shown only after status is approved.
class CheckYourEmailScreen extends StatelessWidget {
  const CheckYourEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = InjectionContainer.instance.appStorage;
    final String fullName =
        storage.readString(AppConstants.accessRequestFullNameKey)?.trim() ?? '';
    final String workEmail =
        storage.readString(AppConstants.accessRequestWorkEmailKey)?.trim() ?? '';
    final String brokerage =
        storage.readString(AppConstants.accessRequestBrokerageKey)?.trim() ?? '';

    final String subtitle = workEmail.isEmpty
        ? "We've sent an invitation to your registered email address."
        : "We've sent an invitation to $workEmail.";

    return AuthScaffold(
      showBackground: true,
      onBack: () => context.go(AppRoutes.signIn),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AuthHeader(
            title: 'Check Your Email',
            subtitles: <String>[subtitle],
          ),
          SizedBox(height: ScreenUtils.h(30)),
          CheckEmailInviteCard(
            fullName: fullName.isEmpty ? 'there' : fullName,
            brokerageName: brokerage.isEmpty ? 'NEWLANE' : brokerage,
            workEmail: workEmail,
          ),
          SizedBox(height: ScreenUtils.h(30)),
          AuthInfoBanner(
            icon: Icon(
              Icons.mail_outline,
              color: AppColors.primaryButtonBg,
              size: ScreenUtils.sp(36),
            ),
            title: "Didn't receive the email?",
            message: 'Check your spam folder or contact your Office Manager.',
          ),
        ],
      ),
    );
  }
}

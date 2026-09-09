import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/bloc/request_status/request_status_bloc.dart';
import 'package:newlane/features/auth/domain/entities/access_request_status.dart';
import 'package:newlane/features/auth/widgets/auth_cards.dart';
import 'package:newlane/features/auth/widgets/auth_header.dart';
import 'package:newlane/features/auth/widgets/auth_scaffold.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

/// After submit: always this screen.
/// Invitation opens only when GET status == approved.
class RequestPendingScreen extends StatelessWidget {
  const RequestPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestStatusBloc, RequestStatusState>(
      listener: (BuildContext context, RequestStatusState state) {
        if (state is RequestStatusLoaded && state.status.isApproved) {
          context.go(AppRoutes.checkYourEmail);
          return;
        }
        if (state is RequestStatusFailure) {
          AppSnackBar.showError(
            context,
            title: 'Unable to Continue',
            message: state.message,
          );
        }
      },
      builder: (BuildContext context, RequestStatusState state) {
        final AccessRequestStatus? status =
            state is RequestStatusLoaded ? state.status : null;
        final bool isRejected = status?.isRejected ?? false;

        return AuthScaffold(
          showBackground: true,
          dimAmount: 0.45,
          onBack: () => context.go(AppRoutes.signIn),
          footer: UnifiedButton(
            label: 'Back to Login',
            onPressed: () => context.go(AppRoutes.signIn),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AuthHeader(
                title: 'REQUEST',
                accentTitle: isRejected ? 'REJECTED' : 'PENDING',
                subtitleFontSize: 12,
                subtitleWidth: ScreenUtils.w(247),
                subtitles: <String>[
                  if (isRejected)
                    status?.rejectionReason ??
                        'Your access request was not approved.'
                  else ...<String>[
                    'Thanks! Your access request has been submitted successfully.',
                    "Our team is reviewing your information. You'll be notified once your access is approved.",
                  ],
                ],
              ),
              SizedBox(height: ScreenUtils.h(24)),
              ReviewStatusCard(status: status),
              SizedBox(height: ScreenUtils.h(16)),
              const AuthInfoBanner(
                icon: EmailReminderIcon(),
                title: 'Check your email',
                message:
                    'Keep an eye on your inbox (and spam folder) for approval updates.',
                titleSize: 12,
                messageSize: 10,
              ),
              SizedBox(height: ScreenUtils.h(28)),
            ],
          ),
        );
      },
    );
  }
}

/// Clock icon + copy + 3-step progress. Null status = still pending.
class ReviewStatusCard extends StatelessWidget {
  const ReviewStatusCard({super.key, this.status});

  final AccessRequestStatus? status;

  @override
  Widget build(BuildContext context) {
    final bool approved = status?.isApproved ?? false;
    final bool rejected = status?.isRejected ?? false;

    return AuthGlassCard(
      child: Column(
        children: <Widget>[
          Icon(
            rejected
                ? Icons.highlight_off
                : Icons.schedule,
            size: ScreenUtils.sp(80),
            color: AppColors.primaryButtonBg,
          ),
          SizedBox(height: ScreenUtils.h(24)),
          Text(
            rejected
                ? 'Your Request Was Not Approved'
                : 'Your Request is Under Review',
            textAlign: TextAlign.center,
            style: AppTypography.semiBold(fontSize: 18),
          ),
          SizedBox(height: ScreenUtils.h(16)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(12)),
            child: Text(
              rejected
                  ? (status?.rejectionReason ??
                        'Please contact your Office Manager for more details.')
                  : "This usually takes 24 - 48 hours. We'll notify you at your registered email once it's approved.",
              textAlign: TextAlign.center,
              style: AppTypography.regular(
                fontSize: 14,
                height: 1.5,
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          SizedBox(height: ScreenUtils.h(24)),
          AuthStepper(
            steps: <AuthStepItem>[
              const AuthStepItem(
                icon: Icons.check_circle_outline,
                label: 'Request Submitted',
                isActive: true,
              ),
              AuthStepItem(
                icon: Icons.search,
                label: rejected ? 'Rejected' : 'Under Review',
                isActive: true,
              ),
              AuthStepItem(
                icon: Icons.mail_outline,
                label: 'Email Notification',
                isActive: approved,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gold bell in a faint circle, used on the email reminder banner.
class EmailReminderIcon extends StatelessWidget {
  const EmailReminderIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtils.w(40),
      height: ScreenUtils.w(40),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryButtonBg.withValues(alpha: 0.2),
        ),
      ),
      child: Icon(
        CupertinoIcons.bell,
        color: AppColors.primaryButtonBg,
        size: ScreenUtils.sp(20),
      ),
    );
  }
}

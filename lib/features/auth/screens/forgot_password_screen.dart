import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:newlane/features/auth/bloc/forgot_password/forgot_password_event.dart';
import 'package:newlane/features/auth/bloc/forgot_password/forgot_password_state.dart';
import 'package:newlane/features/auth/widgets/auth_cards.dart';
import 'package:newlane/features/auth/widgets/auth_form_fields.dart';
import 'package:newlane/features/auth/widgets/auth_header.dart';
import 'package:newlane/features/auth/widgets/auth_scaffold.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/app_svg.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

/// POST /api/auth/forgot-password — request a reset link by email.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _emailController.text.trim().isNotEmpty;

  void _submit(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<ForgotPasswordBloc>().add(
      ForgotPasswordSubmitted(email: _emailController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
      listener: (BuildContext context, ForgotPasswordState state) {
        if (!context.mounted) return;

        if (state is ForgotPasswordSuccess) {
          context.pushReplacement(
            AppRoutes.forgotPasswordSent,
            extra: <String, String>{
              'email': state.email,
              'message': state.result.message,
            },
          );
          return;
        }

        if (state is ForgotPasswordFailure) {
          if (state.isValidation) {
            AppSnackBar.showInfo(
              context,
              title: 'Check Details',
              message: state.message,
            );
          } else {
            AppSnackBar.showError(
              context,
              title: 'Request Failed',
              message: state.message,
            );
          }
        }
      },
      builder: (BuildContext context, ForgotPasswordState state) {
        final bool isLoading = state is ForgotPasswordLoading;

        return AuthScaffold(
          showBackground: true,
          dimAmount: 0.55,
          onBack: () => context.pop(),
          body: Column(
            children: <Widget>[
              AppSvg(AssetConstants.newLaneAppLogo, height: ScreenUtils.h(74)),
              SizedBox(height: ScreenUtils.h(40)),
              const AuthHeader(
                title: 'Forgot Password',
                subtitles: <String>[
                  'Enter your company email and we\'ll send you a reset link.',
                ],
                subtitleFontSize: 16,
                center: true,
              ),
              SizedBox(height: ScreenUtils.h(40)),
              AuthLabeledField(
                label: 'Company Email',
                child: AuthInput(
                  controller: _emailController,
                  hintText: 'john@newlane.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icon(
                    Icons.mail_outline,
                    color: AppColors.white.withValues(alpha: 0.8),
                    size: ScreenUtils.sp(20),
                  ),
                  onSubmitted: (_) {
                    if (!isLoading && _canSubmit) _submit(context);
                  },
                ),
              ),
              SizedBox(height: ScreenUtils.h(28)),
              ListenableBuilder(
                listenable: _emailController,
                builder: (BuildContext context, Widget? child) {
                  final bool enabled = !isLoading && _canSubmit;
                  return UnifiedButton(
                    label: 'Send Reset Link',
                    isLoading: isLoading,
                    onPressed: enabled ? () => _submit(context) : null,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Confirmation after a successful forgot-password request.
class ForgotPasswordSentScreen extends StatelessWidget {
  const ForgotPasswordSentScreen({
    super.key,
    required this.email,
    required this.message,
  });

  final String email;
  final String message;

  @override
  Widget build(BuildContext context) {
    final String subtitle = email.isEmpty
        ? message
        : (message.isNotEmpty
              ? message
              : 'If that email exists, a reset link has been sent to $email.');

    return AuthScaffold(
      showBackground: true,
      dimAmount: 0.55,
      onBack: () => context.go(AppRoutes.signIn),
      footer: UnifiedButton(
        label: 'Back to Sign In',
        onPressed: () => context.go(AppRoutes.signIn),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AuthHeader(
            title: 'Check Your Email',
            subtitles: <String>[subtitle],
          ),
          SizedBox(height: ScreenUtils.h(30)),
          AuthInfoBanner(
            icon: Icon(
              Icons.mail_outline,
              color: AppColors.primaryButtonBg,
              size: ScreenUtils.sp(36),
            ),
            title: email.isEmpty ? 'Reset link sent' : email,
            message:
                "Didn't get it? Check spam, or try again in a few minutes.",
          ),
          SizedBox(height: ScreenUtils.h(20)),
          Center(
            child: TextButton(
              onPressed: () => context.go(AppRoutes.forgotPassword),
              child: Text(
                'Try a different email',
                style: AppTypography.medium(
                  fontSize: 14,
                  color: AppColors.primaryButtonBg,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

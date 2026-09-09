import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/bloc/reset_password/reset_password_bloc.dart';
import 'package:newlane/features/auth/bloc/reset_password/reset_password_event.dart';
import 'package:newlane/features/auth/bloc/reset_password/reset_password_state.dart';
import 'package:newlane/features/auth/widgets/auth_cards.dart';
import 'package:newlane/features/auth/widgets/auth_form_fields.dart';
import 'package:newlane/features/auth/widgets/auth_header.dart';
import 'package:newlane/features/auth/widgets/auth_scaffold.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

/// Set a new password from an email reset-password deep link.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({required this.resetToken, super.key});

  final String resetToken;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  late final Listenable _passwordListenable = Listenable.merge(<Listenable>[
    _passwordController,
    _confirmController,
  ]);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _isPasswordValid {
    final String password = _passwordController.text;
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%]').hasMatch(password) &&
        password == _confirmController.text &&
        _confirmController.text.isNotEmpty;
  }

  void _onContinue(BuildContext context) {
    if (!_isPasswordValid) return;

    context.read<ResetPasswordBloc>().add(
      ResetPasswordSubmitted(
        resetToken: widget.resetToken,
        password: _passwordController.text,
        confirmPassword: _confirmController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
      listener: (BuildContext context, ResetPasswordState state) {
        if (state is ResetPasswordSuccess) {
          AppSnackBar.showSuccess(
            context,
            title: 'Password Updated',
            message: state.result.message.isNotEmpty
                ? state.result.message
                : 'Your password has been reset. Please sign in.',
          );
          context.go(AppRoutes.signIn);
          return;
        }

        if (state is ResetPasswordFailure) {
          if (state.isValidation) {
            AppSnackBar.showInfo(
              context,
              title: 'Check Password',
              message: state.message,
            );
          } else {
            AppSnackBar.showError(
              context,
              title: 'Reset Failed',
              message: state.message,
            );
          }
        }
      },
      builder: (BuildContext context, ResetPasswordState state) {
        final bool isLoading = state is ResetPasswordLoading;

        return AuthScaffold(
          showBackground: true,
          dimAmount: 0.55,
          onBack: () => context.go(AppRoutes.signIn),
          footer: ListenableBuilder(
            listenable: _passwordListenable,
            builder: (BuildContext context, Widget? child) {
              final bool canContinue = !isLoading && _isPasswordValid;
              return UnifiedButton(
                label: 'Reset Password',
                isLoading: isLoading,
                onPressed: canContinue ? () => _onContinue(context) : null,
              );
            },
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const AuthHeader(
                title: 'Reset Password',
                titleFontSize: 30,
                subtitles: <String>[
                  'Choose a new password for your account.',
                ],
              ),
              SizedBox(height: ScreenUtils.h(32)),
              AuthPasswordField(
                controller: _passwordController,
                label: 'New Password',
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: ScreenUtils.h(32)),
              AuthPasswordField(
                controller: _confirmController,
                label: 'Confirm Password',
                onSubmitted: (_) {
                  if (!isLoading && _isPasswordValid) {
                    _onContinue(context);
                  }
                },
              ),
              SizedBox(height: ScreenUtils.h(32)),
              ListenableBuilder(
                listenable: _passwordListenable,
                builder: (BuildContext context, Widget? child) {
                  return PasswordRequirements(
                    password: _passwordController.text,
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

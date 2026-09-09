import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/bloc/sign_in/sign_in_bloc.dart';
import 'package:newlane/features/auth/bloc/sign_in/sign_in_event.dart';
import 'package:newlane/features/auth/bloc/sign_in/sign_in_state.dart';
import 'package:newlane/features/auth/domain/entities/login_result.dart';
import 'package:newlane/features/auth/widgets/auth_form_fields.dart';
import 'package:newlane/features/auth/widgets/auth_header.dart';
import 'package:newlane/features/auth/widgets/auth_scaffold.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/app_svg.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

/// Email + password sign-in via POST /api/auth/login.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  late final Listenable _formListenable = Listenable.merge(<Listenable>[
    _emailController,
    _passwordController,
  ]);

  @override
  void initState() {
    super.initState();
    final storage = InjectionContainer.instance.appStorage;
    final String? savedEmail = storage.rememberedEmail;
    // Apple-friendly: restore email only (password is never stored).
    _rememberMe = storage.rememberMeEnabled || savedEmail != null;
    _emailController = TextEditingController(
      text: _rememberMe && savedEmail != null ? savedEmail : '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  void _onSignIn(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<SignInBloc>().add(
      SignInSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
        rememberMe: _rememberMe,
      ),
    );
  }

  void _onSuccess(BuildContext context, LoginResult result) {
    final String status = result.status.toLowerCase().trim();

    if (result.token.isEmpty) {
      AppSnackBar.showError(
        context,
        title: 'Sign In Failed',
        message: 'No auth token returned. Please try again.',
      );
      return;
    }

    if (status == 'pending_password') {
      AppSnackBar.showInfo(
        context,
        title: 'Activate Account',
        message:
            'Please activate your account using the link sent to your email first.',
      );
      return;
    }

    final String welcome = result.fullName.trim().isNotEmpty
        ? 'Welcome back, ${result.fullName.trim()}!'
        : (result.message.trim().isNotEmpty
              ? result.message.trim()
              : 'Signed in successfully.');

    AppSnackBar.showSuccess(
      context,
      title: 'Signed In',
      message: welcome,
    );

    // Never show onboarding again after a successful sign-in.
    InjectionContainer.instance.appStorage.setOnboardingCompleted();

    if (result.needsProfileCompletion) {
      context.go(AppRoutes.completeProfile);
      return;
    }

    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInBloc, SignInState>(
      listener: (BuildContext context, SignInState state) {
        if (!context.mounted) return;

        if (state is SignInSuccess) {
          _onSuccess(context, state.result);
          return;
        }

        if (state is SignInFailure) {
          if (state.isValidation) {
            AppSnackBar.showInfo(
              context,
              title: 'Check Details',
              message: state.message,
            );
          } else {
            AppSnackBar.showError(
              context,
              title: 'Sign In Failed',
              message: state.message,
            );
          }
        }
      },
      builder: (BuildContext context, SignInState state) {
        final bool isLoading = state is SignInLoading;

        return AuthScaffold(
          showBackground: true,
          dimAmount: 0.55,
          onBack: context.canPop()
              ? () => context.pop()
              : null,
          body: Column(
            children: <Widget>[
              AppSvg(AssetConstants.newLaneAppLogo, height: ScreenUtils.h(74)),
              SizedBox(height: ScreenUtils.h(40)),
              const AuthHeader(
                title: 'Sign In',
                subtitles: <String>[
                  'Welcome back! Sign in to access your workspace.',
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
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icon(
                    Icons.mail_outline,
                    color: AppColors.white.withValues(alpha: 0.8),
                    size: ScreenUtils.sp(20),
                  ),
                ),
              ),
              SizedBox(height: ScreenUtils.h(20)),
              AuthPasswordField(
                controller: _passwordController,
                showLockIcon: true,
                onSubmitted: (_) {
                  if (!isLoading && _canSubmit) _onSignIn(context);
                },
              ),
              SizedBox(height: ScreenUtils.h(20)),
              SignInOptionsRow(
                rememberMe: _rememberMe,
                onRememberChanged: (bool value) {
                  setState(() => _rememberMe = value);
                  // Persist preference immediately. Email only — never password.
                  InjectionContainer.instance.appStorage.saveRememberMe(
                    enabled: value,
                    email: value ? _emailController.text : null,
                  );
                },
                onForgotPassword: () {
                  final String email = _emailController.text.trim();
                  context.push(
                    AppRoutes.forgotPassword,
                    extra: email.isEmpty ? null : email,
                  );
                },
              ),
              SizedBox(height: ScreenUtils.h(28)),
              ListenableBuilder(
                listenable: _formListenable,
                builder: (BuildContext context, Widget? child) {
                  final bool enabled = !isLoading && _canSubmit;
                  return UnifiedButton(
                    label: 'Sign In',
                    isLoading: isLoading,
                    onPressed: enabled ? () => _onSignIn(context) : null,
                  );
                },
              ),
              SizedBox(height: ScreenUtils.h(24)),
              const AuthDividerLabel(label: 'OR'),
              SizedBox(height: ScreenUtils.h(24)),
              UnifiedButton.outline(
                label: 'Request Access',
                icon: const Icon(Icons.person_outline),
                onPressed: isLoading
                    ? null
                    : () => context.go(AppRoutes.requestAccess),
              ),
              SizedBox(height: ScreenUtils.h(28)),
              const AuthDividerLabel(label: 'Need Help'),
              SizedBox(height: ScreenUtils.h(20)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(24)),
                child: Text(
                  'Contact your Office Manager if you need assistance.',
                  textAlign: TextAlign.center,
                  style: AppTypography.regular(
                    fontSize: 16,
                    height: 1.3,
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
              SizedBox(height: ScreenUtils.h(16)),
            ],
          ),
        );
      },
    );
  }
}

/// Remember-me checkbox + Forgot Password link.
class SignInOptionsRow extends StatelessWidget {
  const SignInOptionsRow({
    required this.rememberMe,
    required this.onRememberChanged,
    required this.onForgotPassword,
    super.key,
  });

  final bool rememberMe;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: ScreenUtils.w(20),
          height: ScreenUtils.w(20),
          child: Checkbox(
            value: rememberMe,
            onChanged: (bool? value) => onRememberChanged(value ?? false),
            side: BorderSide(color: AppColors.white.withValues(alpha: 0.8)),
            activeColor: AppColors.primaryButtonBg,
            checkColor: AppColors.black,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        SizedBox(width: ScreenUtils.w(8)),
        Text('Remember Me', style: AppTypography.medium(fontSize: 12)),
        const Spacer(),
        GestureDetector(
          onTap: onForgotPassword,
          child: Text(
            'Forgot Password?',
            style: AppTypography.semiBold(
              fontSize: 12,
              color: AppColors.primaryButtonBg,
            ),
          ),
        ),
      ],
    );
  }
}

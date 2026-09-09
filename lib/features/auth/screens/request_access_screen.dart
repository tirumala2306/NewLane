import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/bloc/request_access/request_access_bloc.dart';
import 'package:newlane/features/auth/bloc/request_access/request_access_event.dart';
import 'package:newlane/features/auth/bloc/request_access/request_access_state.dart';
import 'package:newlane/features/auth/widgets/auth_header.dart';
import 'package:newlane/features/auth/widgets/auth_scaffold.dart';
import 'package:newlane/features/auth/widgets/request_access_form.dart';
import 'package:newlane/features/auth/widgets/request_submitted_dialog.dart';
import 'package:newlane/features/more/data/more_info_content.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';

/// Collects identity details and submits an access request via BLoC.
class RequestAccessScreen extends StatefulWidget {
  const RequestAccessScreen({super.key});

  @override
  State<RequestAccessScreen> createState() => _RequestAccessScreenState();
}

class _RequestAccessScreenState extends State<RequestAccessScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _officeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _officeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onRequestAccess() {
    context.read<RequestAccessBloc>().add(
      RequestAccessSubmitted(
        fullName: _nameController.text,
        workEmail: _emailController.text,
        brokerageName: _officeController.text,
        phone: _phoneController.text,
        acceptedTerms: _acceptedTerms,
      ),
    );
  }

  void _onSuccess() {
    RequestSubmittedDialog.show(
      context,
      onDone: () {
        if (!mounted) return;
        context.go(AppRoutes.requestPending);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestAccessBloc, RequestAccessState>(
      listener: (BuildContext context, RequestAccessState state) {
        if (state is RequestAccessSuccess) {
          _onSuccess();
        } else if (state is RequestAccessFailure) {
          if (state.isValidation) {
            AppSnackBar.showInfo(
              context,
              title: state.title,
              message: state.message,
            );
          } else {
            AppSnackBar.showError(
              context,
              title: state.title,
              message: state.message,
            );
          }
        }
      },
      builder: (BuildContext context, RequestAccessState state) {
        final bool isLoading = state is RequestAccessLoading;

        return AuthScaffold(
          showBackground: true,
          onBack: () => context.pop(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AuthHeader(
                title: 'REQUEST',
                accentTitle: 'ACCESS',
                titleFontSize: 36,
                subtitleFontSize: 12,
                subtitleWidth: ScreenUtils.w(182),
                subtitles: const <String>[
                  'Fill in your details to request access to the NEWLANE workspace.',
                ],
              ),
              SizedBox(height: ScreenUtils.h(50)),
              RequestAccessFormCard(
                nameController: _nameController,
                emailController: _emailController,
                officeController: _officeController,
                phoneController: _phoneController,
                acceptedTerms: _acceptedTerms,
                onAcceptedTermsChanged: (bool value) {
                  setState(() => _acceptedTerms = value);
                },
                onTermsTap: () => context.push(
                  AppRoutes.moreInfo,
                  extra: MoreInfoContent.terms,
                ),
                onPrivacyTap: () => context.push(
                  AppRoutes.moreInfo,
                  extra: MoreInfoContent.privacy,
                ),
                isLoading: isLoading,
                onRequestAccess: _onRequestAccess,
              ),
              SizedBox(height: ScreenUtils.h(20)),
              AuthInlineLink(
                prompt: 'Already have an account? ',
                actionLabel: 'Sign In',
                onTap: isLoading ? () {} : () => context.push(AppRoutes.signIn),
              ),
            ],
          ),
        );
      },
    );
  }
}

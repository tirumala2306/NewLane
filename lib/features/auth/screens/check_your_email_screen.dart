import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/constants/app_constants.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/widgets/auth_cards.dart';
import 'package:newlane/features/auth/widgets/auth_header.dart';
import 'package:newlane/features/auth/widgets/auth_scaffold.dart';
import 'package:newlane/features/auth/widgets/check_email_invite_card.dart';
import 'package:newlane/features/create_post/domain/entities/office.dart';

/// Invitation — shown only after status is approved.
class CheckYourEmailScreen extends StatefulWidget {
  const CheckYourEmailScreen({super.key});

  @override
  State<CheckYourEmailScreen> createState() => _CheckYourEmailScreenState();
}

class _CheckYourEmailScreenState extends State<CheckYourEmailScreen> {
  late final String _fullName;
  late final String _workEmail;
  late final String _workspaceName;
  String _locationLabel = '';

  @override
  void initState() {
    super.initState();
    final storage = InjectionContainer.instance.appStorage;
    _fullName =
        storage.readString(AppConstants.accessRequestFullNameKey)?.trim() ?? '';
    _workEmail =
        storage.readString(AppConstants.accessRequestWorkEmailKey)?.trim() ??
        '';
    _workspaceName =
        storage.readString(AppConstants.accessRequestBrokerageKey)?.trim() ??
        '';
    _resolveOfficeLocation();
  }

  Future<void> _resolveOfficeLocation() async {
    if (_workspaceName.isEmpty) return;

    try {
      final Result<List<Office>> result = await InjectionContainer.instance
          .fetchOffices(search: _workspaceName);
      if (!mounted) return;

      result.when(
        ok: (List<Office> offices) {
          final Office? match = _bestOfficeMatch(offices, _workspaceName);
          if (match == null) return;
          final String location = match.displayAddress.trim().isNotEmpty
              ? match.displayAddress.trim()
              : match.locationLabel.trim();
          if (location.isEmpty) return;
          setState(() => _locationLabel = location);
        },
        err: (_) {},
      );
    } catch (_) {
      // Pre-login office lookup is best-effort.
    }
  }

  Office? _bestOfficeMatch(List<Office> offices, String name) {
    if (offices.isEmpty) return null;
    final String needle = name.toLowerCase();
    for (final Office office in offices) {
      if (office.name.trim().toLowerCase() == needle) return office;
    }
    for (final Office office in offices) {
      if (office.name.toLowerCase().contains(needle) ||
          needle.contains(office.name.toLowerCase())) {
        return office;
      }
    }
    return offices.first;
  }

  @override
  Widget build(BuildContext context) {
    final String subtitle = _workEmail.isEmpty
        ? "We've sent an invitation to your registered email address."
        : "We've sent an invitation to $_workEmail.";

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
            fullName: _fullName.isEmpty ? 'there' : _fullName,
            workspaceName: _workspaceName.isEmpty ? 'NEWLANE' : _workspaceName,
            locationLabel: _locationLabel,
            workEmail: _workEmail,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/domain/entities/agent_profile.dart';
import 'package:newlane/features/more/widgets/more_card.dart';
import 'package:newlane/features/more/widgets/more_logout_dialog.dart';
import 'package:newlane/features/more/widgets/more_settings_widgets.dart';
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final bool confirmed = await MoreLogoutDialog.confirm(context);
    if (!confirmed || !context.mounted) return;
    await InjectionContainer.instance.logout();
    if (!context.mounted) return;
    AppSnackBar.showSuccess(
      context,
      title: 'Logged Out',
      message: 'You have been signed out successfully.',
    );
    context.go(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    final ProfileState state = context.watch<ProfileBloc>().state;
    final AgentProfile? profile =
        state is ProfileLoaded ? state.profile : null;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        onPrefixPressed: () => context.pop(),
        title: 'ACCOUNT',
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
          const MoreSectionTitle('Account Information'),
          SizedBox(height: ScreenUtils.h(10)),
          MoreCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MoreLabeledValue(
                  label: 'Full Name',
                  value: profile?.fullName ?? '',
                ),
                moreDivider(),
                MoreLabeledValue(label: 'Email', value: profile?.email ?? ''),
                moreDivider(),
                MoreLabeledValue(label: 'Phone', value: profile?.phone ?? ''),
                moreDivider(),
                MoreLabeledValue(
                  label: 'Role',
                  value: profile?.roleLabel.isNotEmpty == true
                      ? profile!.roleLabel
                      : 'Agent',
                ),
                moreDivider(),
                const MoreLabeledValue(
                  label: 'Member Since',
                  value: 'Jan 15, 2025',
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenUtils.h(20)),
          const MoreSectionTitle('Settings'),
          SizedBox(height: ScreenUtils.h(10)),
          MoreCard(
            child: Column(
              children: <Widget>[
                MoreNavRow(
                  title: 'Language',
                  trailing: Text(
                    'English',
                    style: AppTypography.regular(
                      fontSize: 12,
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  onTap: () {},
                ),
                moreDivider(),
                MoreNavRow(
                  title: 'Time Zone',
                  trailing: Text(
                    '(GMT-05:00) Eastern Time',
                    style: AppTypography.regular(
                      fontSize: 11,
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenUtils.h(24)),
          MoreCard(
            onTap: () => _logout(context),
            borderColor: const Color(0xFFFF383C).withValues(alpha: 0.45),
            child: Center(
              child: Text(
                'Log Out',
                style: AppTypography.semiBold(
                  fontSize: 14,
                  color: const Color(0xFFFF383C),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

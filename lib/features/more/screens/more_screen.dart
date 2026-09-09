import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/config/app_environment.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/domain/entities/agent_profile.dart';
import 'package:newlane/features/more/data/mock/more_mock_data.dart';
import 'package:newlane/features/more/widgets/more_logout_dialog.dart';
import 'package:newlane/features/more/widgets/more_menu_tile.dart';
import 'package:newlane/features/more/widgets/more_profile_header.dart';
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_event.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late final ProfileBloc _profileBloc;
  StreamSubscription<ProfileState>? _subscription;
  AgentProfile? _profile;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _profileBloc = InjectionContainer.instance.createProfileBloc();
    _applyState(_profileBloc.state);
    _subscription = _profileBloc.stream.listen(_applyState);
    _profileBloc.add(const ProfileLoadRequested());
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  void _applyState(ProfileState state) {
    if (!mounted) return;
    setState(() {
      if (state is ProfileLoaded) {
        _profile = state.profile;
        _loadingProfile = false;
      } else if (state is ProfileLoading) {
        _loadingProfile = _profile == null;
      } else if (state is ProfileFailure) {
        _loadingProfile = false;
      }
    });
  }

  String? _resolveAvatarUrl(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final String base = AppEnvironment.baseUrl.replaceAll(RegExp(r'/$'), '');
    final String path = value.startsWith('/') ? value : '/$value';
    return '$base$path';
  }

  Future<void> _openEditProfile() async {
    final Object? updated = await context.push<Object?>(AppRoutes.editProfile);
    if (!mounted) return;
    if (updated == true) {
      InjectionContainer.instance.refreshProfile();
    }
  }

  Future<void> _confirmLogout() async {
    final bool confirmed = await MoreLogoutDialog.confirm(context);
    if (!confirmed || !mounted) return;
    await InjectionContainer.instance.logout();
    if (!mounted) return;
    AppSnackBar.showSuccess(
      context,
      title: 'Logged Out',
      message: 'You have been signed out successfully.',
    );
    context.go(AppRoutes.splash);
  }

  void _onItemTap(MoreMenuItem item) {
    switch (item.id) {
      case MoreMenuId.profile:
        _openEditProfile();
      case MoreMenuId.office:
        context.push(AppRoutes.moreOffice);
      case MoreMenuId.notifications:
        context.push(AppRoutes.moreNotifications);
      case MoreMenuId.account:
        context.push(AppRoutes.moreAccount);
      case MoreMenuId.privacy:
        context.push(AppRoutes.morePrivacy);
      case MoreMenuId.security:
        context.push(AppRoutes.moreSecurity);
      case MoreMenuId.pushNotifications:
        context.push(AppRoutes.morePushNotifications);
      case MoreMenuId.helpSupport:
        context.push(AppRoutes.moreHelpSupport);
      case MoreMenuId.terms:
        context.push(AppRoutes.moreTerms);
      case MoreMenuId.about:
        context.push(AppRoutes.moreAbout);
      case MoreMenuId.logout:
        _confirmLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String officeName = (_profile?.officeName.trim().isNotEmpty ?? false)
        ? _profile!.officeName.trim().toUpperCase()
        : MoreMockData.officeName.toUpperCase();

    final List<MoreMenuItem> items = MoreMockData.items.map((MoreMenuItem item) {
      if (item.id != MoreMenuId.office) return item;
      return MoreMenuItem(
        id: item.id,
        title: item.title,
        icon: item.icon,
        subtitle: (_profile?.officeName.trim().isNotEmpty ?? false)
            ? _profile!.officeName.trim()
            : MoreMockData.officeName,
      );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        prefixIconColor: AppColors.white,
        onPrefixPressed: () => context.pop(),
        title: 'MORE',
        titleFontSize: 16,
        description: officeName,
        descriptionFontSize: 10,
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
          MoreProfileHeader(
            name: _profile?.fullName ?? '',
            avatarUrl: _profile != null
                ? _resolveAvatarUrl(_profile!.avatar)
                : null,
            isLoading: _loadingProfile,
            onViewProfile: () => context.go(AppRoutes.profile),
          ),
          SizedBox(height: ScreenUtils.h(12)),
          ...items.map(
            (MoreMenuItem item) => Padding(
              padding: EdgeInsets.only(bottom: ScreenUtils.h(10)),
              child: MoreMenuTile(
                item: item,
                onTap: () => _onItemTap(item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

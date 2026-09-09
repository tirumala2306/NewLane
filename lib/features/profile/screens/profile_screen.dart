import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/config/app_environment.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/phone_launcher.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/domain/entities/agent_profile.dart';
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';
import 'package:newlane/features/profile/data/mock/profile_mock_data.dart';
import 'package:newlane/features/profile/widgets/profile_about_card.dart';
import 'package:newlane/features/profile/widgets/profile_contact_card.dart';
import 'package:newlane/features/profile/widgets/profile_hero_header.dart';
import 'package:newlane/features/profile/widgets/profile_listings_section.dart';
import 'package:newlane/features/profile/widgets/profile_specialties_card.dart';
import 'package:newlane/features/profile/widgets/profile_stats_row.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

  List<ProfileContactItem> _contactsFrom(AgentProfile profile) {
    final List<ProfileContactItem> items = <ProfileContactItem>[];
    if (profile.email.trim().isNotEmpty) {
      items.add(
        ProfileContactItem(
          icon: Icons.email_outlined,
          value: profile.email.trim(),
        ),
      );
    }
    if (profile.phone.trim().isNotEmpty) {
      items.add(
        ProfileContactItem(
          icon: Icons.phone_outlined,
          value: profile.phone.trim(),
        ),
      );
    }
    if (profile.website.trim().isNotEmpty) {
      items.add(
        ProfileContactItem(
          icon: Icons.language,
          value: profile.website.trim(),
        ),
      );
    }
    if (profile.instagram.trim().isNotEmpty) {
      items.add(
        ProfileContactItem(
          iconAsset: AssetConstants.instagramIcon,
          value: profile.instagram.trim(),
        ),
      );
    }
    return items;
  }

  Future<void> _onCall(BuildContext context, String? phone) async {
    final bool opened = await openPhoneDialer(phone);
    if (!context.mounted) return;
    if (!opened) {
      AppSnackBar.showInfo(
        context,
        title: 'Call',
        message: (phone == null || phone.trim().isEmpty)
            ? 'No phone number on this profile.'
            : 'Could not open the phone dialer.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double gap = ScreenUtils.h(16);

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (BuildContext context, ProfileState state) {
        if (state is ProfileFailure) {
          AppSnackBar.showError(
            context,
            title: 'Profile',
            message: state.message,
          );
        }
      },
      builder: (BuildContext context, ProfileState state) {
        final AgentProfile? profile =
            state is ProfileLoaded ? state.profile : null;
        final bool isLoading = state is ProfileLoading;
        final List<String> specialties =
            profile?.specialties ?? const <String>[];
        final List<ProfileContactItem> contacts = profile != null
            ? _contactsFrom(profile)
            : const <ProfileContactItem>[];

        return SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.black,
            body: Stack(
              children: <Widget>[
                ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    ProfileHeroHeader(
                      name: profile?.fullName ?? '',
                      title: profile?.jobTitle ?? '',
                      role: profile?.roleLabel ?? '',
                      office: profile?.officeName ?? '',
                      avatarUrl: profile != null
                          ? _resolveAvatarUrl(profile.avatar)
                          : null,
                      isVerified:
                          profile?.status.toLowerCase().trim() == 'active',
                      isOnline: profile != null,
                      onBack: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          StatefulNavigationShell.of(context).goBranch(0);
                        }
                      },
                      onMore: () => context.push(AppRoutes.more),
                      onMessage: () {},
                      onCall: () => _onCall(context, profile?.phone),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        ScreenUtils.w(16),
                        ScreenUtils.h(8),
                        ScreenUtils.w(16),
                        ScreenUtils.h(32),
                      ),
                      child: Column(
                        children: <Widget>[
                          const ProfileStatsRow(stats: ProfileMockData.stats),
                          SizedBox(height: gap),
                          if ((profile?.bio ?? '').trim().isNotEmpty) ...<Widget>[
                            ProfileAboutCard(about: profile!.bio.trim()),
                            SizedBox(height: gap),
                          ],
                          if (specialties.isNotEmpty) ...<Widget>[
                            ProfileSpecialtiesCard(specialties: specialties),
                            SizedBox(height: gap),
                          ],
                          if (contacts.isNotEmpty) ...<Widget>[
                            ProfileContactCard(contacts: contacts),
                            SizedBox(height: gap),
                          ],
                          ProfileListingsSection(
                            listings: ProfileMockData.listings,
                            onViewAll: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      color: AppColors.primaryButtonBg,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

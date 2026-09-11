import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/config/app_environment.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/phone_launcher.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/domain/entities/agent_profile.dart';
import 'package:newlane/features/listings/domain/entities/active_listing.dart';
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';
import 'package:newlane/features/profile/data/mock/profile_mock_data.dart';
import 'package:newlane/features/profile/widgets/profile_about_card.dart';
import 'package:newlane/features/profile/widgets/profile_contact_card.dart';
import 'package:newlane/features/profile/widgets/profile_hero_header.dart';
import 'package:newlane/features/profile/widgets/profile_listings_section.dart';
import 'package:newlane/features/profile/widgets/profile_specialties_card.dart';
import 'package:newlane/features/profile/widgets/profile_stats_row.dart';
import 'package:newlane/shared/widgets/app_skeleton.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<ActiveListing> _listings = <ActiveListing>[];
  bool _loadingListings = false;
  int? _loadedForUserId;
  bool _listingsInFlight = false;

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

  Future<void> _loadListings(AgentProfile profile) async {
    if (profile.id <= 0) return;
    // Already finished for this user.
    if (_loadedForUserId == profile.id && !_loadingListings && !_listingsInFlight) {
      return;
    }
    // Same user already fetching.
    if (_listingsInFlight && _loadedForUserId == profile.id) return;

    _listingsInFlight = true;
    _loadedForUserId = profile.id;
    if (mounted) setState(() => _loadingListings = true);

    try {
      final Result<List<ActiveListing>> result =
          await InjectionContainer.instance.fetchMyActiveListings(
        currentUserId: profile.id,
        currentUserName: profile.fullName,
      );
      if (!mounted) return;
      result.when(
        ok: (List<ActiveListing> items) {
          setState(() {
            _listings = items;
            _loadingListings = false;
          });
        },
        err: (_) {
          setState(() {
            _listings = <ActiveListing>[];
            _loadingListings = false;
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _listings = <ActiveListing>[];
        _loadingListings = false;
      });
    } finally {
      _listingsInFlight = false;
    }
  }

  List<ProfileStat> _statsFor(int listingCount) {
    return <ProfileStat>[
      ProfileStat(
        icon: Icons.home_outlined,
        value: '$listingCount',
        label: 'Active Listings',
      ),
      ...ProfileMockData.stats,
    ];
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
        if (state is ProfileLoaded) {
          _loadListings(state.profile);
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

        if (profile != null &&
            _loadedForUserId != profile.id &&
            !_listingsInFlight) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _loadListings(profile);
          });
        }

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
                      onCall: profile?.phone.trim().isNotEmpty == true
                          ? () => _onCall(context, profile?.phone)
                          : null,
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
                          ProfileStatsRow(
                            stats: _statsFor(_listings.length),
                          ),
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
                          if (profile != null && _loadingListings)
                            const ProfileListingsSkeleton()
                          else if (_listings.isNotEmpty)
                            ProfileListingsSection(
                              listings: _listings
                                  .map((ActiveListing e) => e.toProfileListing())
                                  .toList(),
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

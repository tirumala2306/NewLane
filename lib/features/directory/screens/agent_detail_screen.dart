import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/config/app_environment.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/mail_app_launcher.dart';
import 'package:newlane/core/utils/phone_launcher.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/directory/bloc/agent_detail/agent_detail_bloc.dart';
import 'package:newlane/features/directory/bloc/agent_detail/agent_detail_event.dart';
import 'package:newlane/features/directory/bloc/agent_detail/agent_detail_state.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/listings/domain/entities/active_listing.dart';
import 'package:newlane/features/profile/data/mock/profile_mock_data.dart';
import 'package:newlane/features/profile/widgets/profile_about_card.dart';
import 'package:newlane/features/profile/widgets/profile_contact_card.dart';
import 'package:newlane/features/profile/widgets/profile_hero_header.dart';
import 'package:newlane/features/profile/widgets/profile_listings_section.dart';
import 'package:newlane/features/profile/widgets/profile_specialties_card.dart';
import 'package:newlane/features/profile/widgets/profile_stats_row.dart';
import 'package:newlane/shared/widgets/app_skeleton.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';

class AgentDetailScreen extends StatefulWidget {
  const AgentDetailScreen({
    required this.agentId,
    this.initial,
    super.key,
  });

  final int agentId;
  final DirectoryAgent? initial;

  @override
  State<AgentDetailScreen> createState() => _AgentDetailScreenState();
}

class _AgentDetailScreenState extends State<AgentDetailScreen> {
  List<ActiveListing> _listings = <ActiveListing>[];
  bool _loadingListings = false;
  int? _loadedForAgentId;
  bool _listingsInFlight = false;

  String? _avatarUrl(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final String base = AppEnvironment.baseUrl.replaceAll(RegExp(r'/$'), '');
    final String path = value.startsWith('/') ? value : '/$value';
    return '$base$path';
  }

  List<ProfileContactItem> _contacts(DirectoryAgent agent) {
    final List<ProfileContactItem> items = <ProfileContactItem>[];
    if (agent.email.trim().isNotEmpty) {
      items.add(
        ProfileContactItem(
          icon: Icons.email_outlined,
          value: agent.email.trim(),
        ),
      );
    }
    if (agent.phone.trim().isNotEmpty) {
      items.add(
        ProfileContactItem(
          icon: Icons.phone_outlined,
          value: agent.phone.trim(),
        ),
      );
    }
    if (agent.website.trim().isNotEmpty) {
      items.add(
        ProfileContactItem(
          icon: Icons.language,
          value: agent.website.trim(),
        ),
      );
    }
    if (agent.instagram.trim().isNotEmpty) {
      items.add(
        ProfileContactItem(
          iconAsset: AssetConstants.instagramIcon,
          value: agent.instagram.trim(),
        ),
      );
    }
    return items;
  }

  List<ProfileStat> _stats(DirectoryAgent agent, int listingCount) {
    final int active = listingCount > 0
        ? listingCount
        : agent.stats.activeListings;
    return <ProfileStat>[
      ProfileStat(
        icon: Icons.home_outlined,
        value: '$active',
        label: 'Active Listings',
      ),
      ProfileStat(
        icon: Icons.handshake_outlined,
        value: '${agent.stats.dealsClosed}',
        label: 'Deals Closed',
      ),
      ProfileStat(
        icon: Icons.star_outline,
        value: '${agent.stats.rating}',
        label: 'Rating',
      ),
      ProfileStat(
        icon: Icons.calendar_today_outlined,
        value: '${agent.stats.yearsExperience}+',
        label: 'Years Experience',
      ),
    ];
  }

  Future<void> _loadListings(DirectoryAgent agent) async {
    if (agent.id <= 0) return;
    if (_loadedForAgentId == agent.id &&
        !_loadingListings &&
        !_listingsInFlight) {
      return;
    }
    if (_listingsInFlight && _loadedForAgentId == agent.id) return;

    _listingsInFlight = true;
    _loadedForAgentId = agent.id;
    if (mounted) setState(() => _loadingListings = true);

    try {
      final Result<List<ActiveListing>> result =
          await InjectionContainer.instance.fetchActiveListingsForAgent(
        agentId: agent.id,
        agentName: agent.fullName,
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

  Future<void> _onCall(BuildContext context, String phone) async {
    final bool opened = await openPhoneDialer(phone);
    if (!context.mounted) return;
    if (!opened) {
      AppSnackBar.showInfo(
        context,
        title: 'Call',
        message: phone.trim().isEmpty
            ? 'No phone number on this profile.'
            : 'Could not open the phone dialer.',
      );
    }
  }

  Future<void> _onEmail(BuildContext context, String email) async {
    final bool opened = await openEmailComposer(email);
    if (!context.mounted) return;
    if (!opened) {
      AppSnackBar.showInfo(
        context,
        title: 'Email',
        message: email.trim().isEmpty
            ? 'No email on this profile.'
            : 'Could not open the mail app.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double gap = ScreenUtils.h(16);

    return BlocConsumer<AgentDetailBloc, AgentDetailState>(
      listener: (BuildContext context, AgentDetailState state) {
        if (state is AgentDetailFailure && state.agent == null) {
          AppSnackBar.showError(
            context,
            title: 'Agent',
            message: state.message,
          );
        }
        if (state is AgentDetailFailure && state.agent != null) {
          AppSnackBar.showError(
            context,
            title: 'Message',
            message: state.message,
          );
        }
        if (state is AgentDetailChatReady) {
          context.push(
            AppRoutes.conversationWithId(state.chatId),
            extra: <String, dynamic>{
              'title': state.agent.fullName,
              'avatarUrl': _avatarUrl(state.agent.avatar) ?? '',
              'isAnnouncement': false,
            },
          );
        }
        if (state is AgentDetailLoaded) {
          _loadListings(state.agent);
        }
      },
      builder: (BuildContext context, AgentDetailState state) {
        final DirectoryAgent? agent = switch (state) {
          AgentDetailLoading(:final DirectoryAgent? agent) => agent,
          AgentDetailLoaded(:final DirectoryAgent agent) => agent,
          AgentDetailFailure(:final DirectoryAgent? agent) => agent,
          AgentDetailChatReady(:final DirectoryAgent agent) => agent,
          _ => widget.initial,
        };
        final bool loading = state is AgentDetailLoading && agent == null;
        final bool startingChat =
            state is AgentDetailLoaded && state.isStartingChat;
        final List<ProfileContactItem> contacts =
            agent == null ? const <ProfileContactItem>[] : _contacts(agent);

        if (agent != null &&
            _loadedForAgentId != agent.id &&
            !_listingsInFlight) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _loadListings(agent);
          });
        }

        return SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.black,
            body: loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryButtonBg,
                    ),
                  )
                : agent == null
                ? Center(
                    child: Text(
                      'Agent not found',
                      style: AppTypography.medium(color: AppColors.mutedGrey),
                    ),
                  )
                : Stack(
                    children: <Widget>[
                      ListView(
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                          ProfileHeroHeader(
                            name: agent.fullName,
                            title: agent.jobTitle,
                            role: agent.roleBadge,
                            office: agent.officeName,
                            avatarUrl: _avatarUrl(agent.avatar),
                            isVerified: true,
                            isOnline: true,
                            onBack: () {
                              if (context.canPop()) {
                                context.pop();
                              }
                            },
                            onMessage: () {
                              if (startingChat) return;
                              context.read<AgentDetailBloc>().add(
                                const AgentDetailMessagePressed(),
                              );
                            },
                            onCall: agent.phone.trim().isEmpty
                                ? null
                                : () => _onCall(context, agent.phone),
                            onEmail: agent.email.trim().isEmpty
                                ? null
                                : () => _onEmail(context, agent.email),
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
                                  stats: _stats(agent, _listings.length),
                                ),
                                SizedBox(height: gap),
                                if (agent.bio.trim().isNotEmpty) ...<Widget>[
                                  ProfileAboutCard(about: agent.bio.trim()),
                                  SizedBox(height: gap),
                                ],
                                if (agent.specialties.isNotEmpty) ...<Widget>[
                                  ProfileSpecialtiesCard(
                                    specialties: agent.specialties,
                                  ),
                                  SizedBox(height: gap),
                                ],
                                if (contacts.isNotEmpty) ...<Widget>[
                                  ProfileContactCard(contacts: contacts),
                                  SizedBox(height: gap),
                                ],
                                if (_loadingListings)
                                  const ProfileListingsSkeleton()
                                else if (_listings.isNotEmpty)
                                  ProfileListingsSection(
                                    listings: _listings
                                        .map(
                                          (ActiveListing e) =>
                                              e.toProfileListing(),
                                        )
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (startingChat)
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

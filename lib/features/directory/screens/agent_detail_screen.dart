import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/config/app_environment.dart';
import 'package:newlane/core/constants/asset_constants.dart';
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
import 'package:newlane/features/profile/data/mock/profile_mock_data.dart';
import 'package:newlane/features/profile/widgets/profile_about_card.dart';
import 'package:newlane/features/profile/widgets/profile_avatar.dart';
import 'package:newlane/features/profile/widgets/profile_contact_card.dart';
import 'package:newlane/features/profile/widgets/profile_specialties_card.dart';
import 'package:newlane/features/profile/widgets/profile_stats_row.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

class AgentDetailScreen extends StatelessWidget {
  const AgentDetailScreen({
    required this.agentId,
    this.initial,
    super.key,
  });

  final int agentId;
  final DirectoryAgent? initial;

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

  List<ProfileStat> _stats(DirectoryAgent agent) {
    return <ProfileStat>[
      ProfileStat(
        icon: Icons.home_outlined,
        value: '${agent.stats.activeListings}',
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

  @override
  Widget build(BuildContext context) {
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
      },
      builder: (BuildContext context, AgentDetailState state) {
        final DirectoryAgent? agent = switch (state) {
          AgentDetailLoading(:final DirectoryAgent? agent) => agent,
          AgentDetailLoaded(:final DirectoryAgent agent) => agent,
          AgentDetailFailure(:final DirectoryAgent? agent) => agent,
          AgentDetailChatReady(:final DirectoryAgent agent) => agent,
          _ => initial,
        };
        final bool loading = state is AgentDetailLoading && agent == null;
        final bool startingChat =
            state is AgentDetailLoaded && state.isStartingChat;
        final List<ProfileContactItem> contacts =
            agent == null ? const <ProfileContactItem>[] : _contacts(agent);

        return Scaffold(
          backgroundColor: AppColors.black,
          appBar: NewLaneAppBar(
            prefixIcon: Icons.arrow_back_ios_new,
            onPrefixPressed: () => context.pop(),
            title: 'AGENT PROFILE',
            titleFontSize: 16,
            description: agent?.officeName.isNotEmpty == true
                ? agent!.officeName.toUpperCase()
                : 'NEWLANE',
            descriptionFontSize: 10,
            height: ScreenUtils.h(56),
          ),
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
              : ListView(
                  padding: EdgeInsets.fromLTRB(
                    ScreenUtils.w(16),
                    ScreenUtils.h(12),
                    ScreenUtils.w(16),
                    ScreenUtils.h(32),
                  ),
                  children: <Widget>[
                    _Header(agent: agent, avatarUrl: _avatarUrl(agent.avatar)),
                    SizedBox(height: ScreenUtils.h(16)),
                    ProfileStatsRow(stats: _stats(agent)),
                    if (agent.bio.trim().isNotEmpty) ...<Widget>[
                      SizedBox(height: ScreenUtils.h(16)),
                      ProfileAboutCard(about: agent.bio),
                    ],
                    if (agent.specialties.isNotEmpty) ...<Widget>[
                      SizedBox(height: ScreenUtils.h(16)),
                      ProfileSpecialtiesCard(specialties: agent.specialties),
                    ],
                    if (contacts.isNotEmpty) ...<Widget>[
                      SizedBox(height: ScreenUtils.h(16)),
                      ProfileContactCard(contacts: contacts),
                    ],
                    SizedBox(height: ScreenUtils.h(24)),
                    UnifiedButton(
                      label: 'Message',
                      isLoading: startingChat,
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        size: ScreenUtils.sp(18),
                        color: AppColors.black,
                      ),
                      onPressed: startingChat
                          ? null
                          : () => context.read<AgentDetailBloc>().add(
                              const AgentDetailMessagePressed(),
                            ),
                    ),
                    if (agent.phone.trim().isNotEmpty) ...<Widget>[
                      SizedBox(height: ScreenUtils.h(10)),
                      UnifiedButton.outline(
                        label: 'Call',
                        icon: Icon(
                          Icons.phone_outlined,
                          size: ScreenUtils.sp(18),
                          color: AppColors.primaryButtonBg,
                        ),
                        onPressed: () => openPhoneDialer(agent.phone),
                      ),
                    ],
                    if (agent.email.trim().isNotEmpty) ...<Widget>[
                      SizedBox(height: ScreenUtils.h(10)),
                      UnifiedButton.outline(
                        label: 'Email',
                        icon: Icon(
                          Icons.email_outlined,
                          size: ScreenUtils.sp(18),
                          color: AppColors.primaryButtonBg,
                        ),
                        onPressed: () => openEmailComposer(agent.email),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.agent, required this.avatarUrl});

  final DirectoryAgent agent;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenUtils.w(16)),
      decoration: BoxDecoration(
        color: const Color(0xFF090909),
        borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
        border: Border.all(
          color: AppColors.primaryButtonBg.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: <Widget>[
          ProfileAvatar(url: avatarUrl, size: ScreenUtils.w(88)),
          SizedBox(height: ScreenUtils.h(12)),
          Text(
            agent.fullName.isEmpty ? 'Agent' : agent.fullName,
            textAlign: TextAlign.center,
            style: AppTypography.semiBold(fontSize: 18),
          ),
          if (agent.jobTitle.isNotEmpty) ...<Widget>[
            SizedBox(height: ScreenUtils.h(6)),
            Text(
              agent.jobTitle,
              textAlign: TextAlign.center,
              style: AppTypography.regular(
                fontSize: 13,
                color: AppColors.primaryButtonBg,
              ),
            ),
          ],
          if (agent.roleBadge.isNotEmpty) ...<Widget>[
            SizedBox(height: ScreenUtils.h(10)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtils.w(10),
                vertical: ScreenUtils.h(4),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtils.r(4)),
                border: Border.all(
                  color: AppColors.primaryButtonBg.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                agent.roleBadge,
                style: AppTypography.medium(
                  fontSize: 11,
                  color: AppColors.primaryButtonBg,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:newlane/core/config/app_environment.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/profile/widgets/profile_avatar.dart';

class DirectoryAgentCard extends StatelessWidget {
  const DirectoryAgentCard({
    required this.agent,
    super.key,
    this.onTap,
  });

  final DirectoryAgent agent;
  final VoidCallback? onTap;

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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(ScreenUtils.w(14)),
          decoration: BoxDecoration(
            color: const Color(0xFF090909),
            borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
            border: Border.all(
              color: AppColors.primaryButtonBg.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ProfileAvatar(
                url: _avatarUrl(agent.avatar),
                size: ScreenUtils.w(56),
              ),
              SizedBox(width: ScreenUtils.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      agent.fullName.isEmpty ? 'Agent' : agent.fullName,
                      style: AppTypography.semiBold(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (agent.jobTitle.isNotEmpty) ...<Widget>[
                      SizedBox(height: ScreenUtils.h(4)),
                      Text(
                        agent.jobTitle,
                        style: AppTypography.regular(
                          fontSize: 12,
                          color: AppColors.primaryButtonBg,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (agent.officeName.isNotEmpty) ...<Widget>[
                      SizedBox(height: ScreenUtils.h(4)),
                      Text(
                        agent.officeName,
                        style: AppTypography.regular(
                          fontSize: 11,
                          color: AppColors.white.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (agent.bio.isNotEmpty) ...<Widget>[
                      SizedBox(height: ScreenUtils.h(8)),
                      Text(
                        agent.bio,
                        style: AppTypography.regular(
                          fontSize: 11,
                          height: 1.4,
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (agent.specialties.isNotEmpty) ...<Widget>[
                      SizedBox(height: ScreenUtils.h(10)),
                      Wrap(
                        spacing: ScreenUtils.w(6),
                        runSpacing: ScreenUtils.h(6),
                        children: agent.specialties
                            .take(4)
                            .map(
                              (String specialty) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtils.w(8),
                                  vertical: ScreenUtils.h(4),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    ScreenUtils.r(4),
                                  ),
                                  border: Border.all(
                                    color: AppColors.primaryButtonBg
                                        .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  specialty,
                                  style: AppTypography.medium(
                                    fontSize: 10,
                                    color: AppColors.primaryButtonBg,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    SizedBox(height: ScreenUtils.h(10)),
                    Row(
                      children: <Widget>[
                        _StatChip(
                          icon: Icons.star_outline,
                          label: '${agent.stats.rating}',
                        ),
                        SizedBox(width: ScreenUtils.w(10)),
                        _StatChip(
                          icon: Icons.handshake_outlined,
                          label: '${agent.stats.dealsClosed}',
                        ),
                        SizedBox(width: ScreenUtils.w(10)),
                        _StatChip(
                          icon: Icons.home_outlined,
                          label: '${agent.stats.activeListings}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon,
          size: ScreenUtils.sp(12),
          color: AppColors.white.withValues(alpha: 0.55),
        ),
        SizedBox(width: ScreenUtils.w(4)),
        Text(
          label,
          style: AppTypography.medium(
            fontSize: 10,
            color: AppColors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

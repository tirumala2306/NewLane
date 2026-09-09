import 'package:flutter/material.dart';
import 'package:newlane/core/config/app_environment.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/mail_app_launcher.dart';
import 'package:newlane/core/utils/phone_launcher.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/profile/widgets/profile_avatar.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';

class OfficeTeamMemberCard extends StatelessWidget {
  const OfficeTeamMemberCard({
    required this.member,
    super.key,
    this.onTap,
  });

  final DirectoryAgent member;
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

  Future<void> _onEmail(BuildContext context) async {
    final bool opened = await openEmailComposer(member.email);
    if (!context.mounted) return;
    if (!opened) {
      AppSnackBar.showInfo(
        context,
        title: 'Email',
        message: member.email.trim().isEmpty
            ? 'No email on file for this teammate.'
            : 'Could not open your mail app.',
      );
    }
  }

  Future<void> _onCall(BuildContext context) async {
    final bool opened = await openPhoneDialer(member.phone);
    if (!context.mounted) return;
    if (!opened) {
      AppSnackBar.showInfo(
        context,
        title: 'Call',
        message: member.phone.trim().isEmpty
            ? 'No phone number on file for this teammate.'
            : 'Could not open the phone app.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String badge = member.roleBadge;
    final String name = member.fullName.isEmpty ? 'Teammate' : member.fullName;

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
            url: _avatarUrl(member.avatar),
            size: ScreenUtils.w(56),
          ),
          SizedBox(width: ScreenUtils.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      name,
                      style: AppTypography.semiBold(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (badge.isNotEmpty) ...<Widget>[
                      SizedBox(width: ScreenUtils.w(6)),
                      _RoleBadge(label: badge),
                    ],
                  ],
                ),
                if (member.jobTitle.isNotEmpty) ...<Widget>[
                  SizedBox(height: ScreenUtils.h(4)),
                  Text(
                    member.jobTitle,
                    style: AppTypography.regular(
                      fontSize: 12,
                      color: AppColors.white.withValues(alpha: 0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (member.email.trim().isNotEmpty) ...<Widget>[
                  SizedBox(height: ScreenUtils.h(6)),
                  Text(
                    member.email.trim(),
                    style: AppTypography.regular(
                      fontSize: 10,
                      color: AppColors.primaryButtonBg,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (member.phone.trim().isNotEmpty) ...<Widget>[
                  SizedBox(height: ScreenUtils.h(4)),
                  Text(
                    member.phone.trim(),
                    style: AppTypography.regular(
                      fontSize: 10,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: ScreenUtils.w(8)),
          Column(
            children: <Widget>[
              _ActionButton(
                icon: Icons.email_outlined,
                onTap: () => _onEmail(context),
              ),
              SizedBox(height: ScreenUtils.h(8)),
              _ActionButton(
                icon: Icons.phone_outlined,
                onTap: () => _onCall(context),
              ),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.w(6),
        vertical: ScreenUtils.h(3),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtils.r(4)),
        border: Border.all(color: AppColors.primaryButtonBg.withValues(alpha: 0.25)),
        color: AppColors.primaryButtonBg.withValues(alpha: 0.05),
      ),
      child: Text(
        label,
        style: AppTypography.regular(
          fontSize: 10,
          color: AppColors.primaryButtonBg,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtils.r(6)),
        child: Container(
          width: ScreenUtils.w(32),
          height: ScreenUtils.w(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtils.r(6)),
            color: AppColors.primaryButtonBg.withValues(alpha: 0.1),
          ),
          child: Icon(
            icon,
            size: ScreenUtils.sp(16),
            color: AppColors.primaryButtonBg,
          ),
        ),
      ),
    );
  }
}

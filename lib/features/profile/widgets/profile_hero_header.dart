import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/profile/widgets/profile_avatar.dart';
import 'package:newlane/shared/widgets/app_svg.dart';

class ProfileHeroHeader extends StatelessWidget {
  const ProfileHeroHeader({
    required this.name,
    required this.title,
    super.key,
    this.role = '',
    this.office = '',
    this.location = '',
    this.avatarUrl,
    this.isVerified = false,
    this.isOnline = false,
    this.onBack,
    this.onMore,
    this.onMessage,
    this.onCall,
    this.onEmail,
  });

  final String name;
  /// Admin / profile job title (e.g. Real Estate Agent).
  final String title;
  /// Admin-assigned role (e.g. Agent, Manager).
  final String role;
  final String office;
  final String location;
  final String? avatarUrl;
  final bool isVerified;
  final bool isOnline;
  final VoidCallback? onBack;
  final VoidCallback? onMore;
  final VoidCallback? onMessage;
  final VoidCallback? onCall;
  final VoidCallback? onEmail;

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;
    final double coverHeight = ScreenUtils.h(344);
    final int actionCount = <bool>[
      onMessage != null,
      onCall != null,
      onEmail != null,
    ].where((bool v) => v).length;
    final double infoBarHeight =
        ScreenUtils.h(actionCount >= 3 ? 150 : 138);
    // Extra height so layer-blur softens upward (not a hard edge).
    final double blurBleed = ScreenUtils.h(40);
    // Push blur + content lower so more of the cover image stays visible.
    final double contentDrop = ScreenUtils.h(56);

    return SizedBox(
      width: double.infinity,
      height: coverHeight + contentDrop,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: coverHeight,
            child: AppSvg(
              AssetConstants.profileBg,
              width: ScreenUtils.w(390),
              height: coverHeight,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: topInset,
            left: 0,
            right: 0,
            child: SizedBox(
              height: ScreenUtils.h(56),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: onBack,
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: ScreenUtils.sp(20),
                      color: AppColors.white,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      role.isNotEmpty
                          ? '${role.toUpperCase()} PROFILE'
                          : 'PROFILE',
                      textAlign: TextAlign.center,
                      style: AppTypography.semiBold(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    onPressed: onMore,
                    icon: Icon(
                      Icons.more_horiz,
                      size: ScreenUtils.sp(28),
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Figma "Rectangle 2": black + layer blur 40 — soft blend from top.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: infoBarHeight + blurBleed,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                IgnorePointer(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: 40,
                      sigmaY: 40,
                      tileMode: TileMode.decal,
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        height: infoBarHeight,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: infoBarHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          AppColors.black.withValues(alpha: 0),
                          AppColors.black.withValues(alpha: 0.7),
                          AppColors.black,
                        ],
                        stops: const <double>[0, 0.4, 1],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: infoBarHeight,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtils.w(16),
                        vertical: ScreenUtils.h(16),
                      ),
                      child: Row(
                        children: <Widget>[
                          ProfileAvatar(
                            url: avatarUrl,
                            size: ScreenUtils.w(90),
                            showOnline: true,
                            isOnline: isOnline,
                          ),
                          SizedBox(width: ScreenUtils.w(6)),
                          Expanded(child: _identity()),
                          if (onMessage != null ||
                              onCall != null ||
                              onEmail != null) ...<Widget>[
                            SizedBox(width: ScreenUtils.w(8)),
                            _actions(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _identity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                name.isEmpty ? 'Agent' : name,
                style: AppTypography.semiBold(fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isVerified) ...<Widget>[
              SizedBox(width: ScreenUtils.w(6)),
              Icon(
                Icons.verified,
                size: ScreenUtils.sp(16),
                color: AppColors.primaryButtonBg,
              ),
            ],
          ],
        ),
        if (title.isNotEmpty) ...<Widget>[
          SizedBox(height: ScreenUtils.h(4)),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.regular(fontSize: 10),
          ),
        ],
        if (role.isNotEmpty) ...<Widget>[
          SizedBox(height: ScreenUtils.h(3)),
          Text(
            role,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.medium(
              fontSize: 10,
              color: AppColors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
        if (office.isNotEmpty) ...<Widget>[
          SizedBox(height: ScreenUtils.h(3)),
          Text(
            office,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.medium(
              fontSize: 10,
              color: AppColors.primaryButtonBg,
            ),
          ),
        ],
        if (location.isNotEmpty) ...<Widget>[
          SizedBox(height: ScreenUtils.h(4)),
          Row(
            children: <Widget>[
              Icon(
                Icons.location_on_outlined,
                size: ScreenUtils.sp(12),
                color: AppColors.white,
              ),
              SizedBox(width: ScreenUtils.w(6)),
              Text(
                location,
                style: AppTypography.regular(fontSize: 10),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _actions() {
    final int chipCount = <bool>[
      onMessage != null,
      onCall != null,
      onEmail != null,
    ].where((bool v) => v).length;
    final double gap = chipCount >= 3 ? ScreenUtils.h(4) : ScreenUtils.h(6);
    final double vPad = chipCount >= 3 ? ScreenUtils.h(5) : ScreenUtils.h(8);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (onMessage != null) ...<Widget>[
          _ActionChip(
            icon: Icons.chat_bubble_outline,
            label: 'Message',
            onTap: onMessage,
            verticalPadding: vPad,
          ),
          if (onCall != null || onEmail != null) SizedBox(height: gap),
        ],
        if (onCall != null) ...<Widget>[
          _ActionChip(
            icon: Icons.phone_outlined,
            label: 'Call',
            onTap: onCall,
            verticalPadding: vPad,
          ),
          if (onEmail != null) SizedBox(height: gap),
        ],
        if (onEmail != null)
          _ActionChip(
            icon: Icons.mail_outline,
            label: 'Email',
            onTap: onEmail,
            verticalPadding: vPad,
          ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    this.onTap,
    this.verticalPadding,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final double? verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtils.w(10),
            vertical: verticalPadding ?? ScreenUtils.h(8),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
            border: Border.all(
              color: AppColors.primaryButtonBg.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: ScreenUtils.sp(14),
                color: AppColors.primaryButtonBg,
              ),
              SizedBox(width: ScreenUtils.w(4)),
              Text(
                label,
                style: AppTypography.medium(
                  fontSize: 8,
                  color: AppColors.primaryButtonBg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/shared/widgets/app_svg.dart';

/// Bottom tabs: Home · Chat · [+] · Feed · Profile.
///
/// [currentIndex] is the shell branch index: 0 home, 1 chat, 2 feed, 3 profile.
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    required this.currentIndex,
    required this.onItemSelected,
    super.key,
    this.onCenterTap,
    this.chatUnreadCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback? onCenterTap;

  /// Total unread chat messages across threads (shown on Chat tab).
  final int chatUnreadCount;

  static const Color _inactive = AppColors.white;

  String get _chatBadgeLabel {
    if (chatUnreadCount <= 0) return '';
    if (chatUnreadCount > 9) return '9+';
    return '$chatUnreadCount';
  }

  @override
  Widget build(BuildContext context) {
    final double barHeight = ScreenUtils.h(64);
    final double centerSize = ScreenUtils.w(47);
    final String badge = _chatBadgeLabel;

    return Material(
      color: AppColors.black,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: barHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: _NavItem(
                    label: 'Home',
                    isSelected: currentIndex == 0,
                    onTap: () => onItemSelected(0),
                    icon: Icon(
                      currentIndex == 0 ? Icons.home : Icons.home_outlined,
                      size: ScreenUtils.sp(24),
                      color: currentIndex == 0
                          ? AppColors.primaryButtonBg
                          : _inactive,
                    ),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    label: 'Chat',
                    isSelected: currentIndex == 1,
                    onTap: () => onItemSelected(1),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Icon(
                          currentIndex == 1
                              ? CupertinoIcons.chat_bubble_text_fill
                              : CupertinoIcons.chat_bubble_text,
                          size: ScreenUtils.sp(24),
                          color: currentIndex == 1
                              ? AppColors.primaryButtonBg
                              : _inactive,
                        ),
                        if (badge.isNotEmpty)
                          Positioned(
                            right: -ScreenUtils.w(10),
                            top: -ScreenUtils.h(6),
                            child: _UnreadBadge(label: badge),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: onCenterTap,
                      child: Container(
                        width: centerSize,
                        height: centerSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryButtonBg,
                        ),
                        child: Icon(
                          Icons.add,
                          size: ScreenUtils.sp(32),
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    label: 'Feed',
                    isSelected: currentIndex == 2,
                    onTap: () => onItemSelected(2),
                    icon: Icon(
                      currentIndex == 2
                          ? Icons.description
                          : Icons.description_outlined,
                      size: ScreenUtils.sp(24),
                      color: currentIndex == 2
                          ? AppColors.primaryButtonBg
                          : _inactive,
                    ),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    label: 'Profile',
                    isSelected: currentIndex == 3,
                    onTap: () => onItemSelected(3),
                    icon: AppSvg(
                      AssetConstants.personalIcon,
                      width: ScreenUtils.w(22),
                      height: ScreenUtils.w(22),
                      color: currentIndex == 3
                          ? AppColors.primaryButtonBg
                          : _inactive,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: ScreenUtils.w(16)),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.w(4),
        vertical: ScreenUtils.h(1),
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryButtonBg,
        borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
        border: Border.all(color: AppColors.black, width: 1),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.semiBold(
          fontSize: 9,
          color: AppColors.black,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected
        ? AppColors.primaryButtonBg
        : CustomBottomNavBar._inactive;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          icon,
          SizedBox(height: ScreenUtils.h(8)),
          Text(
            label,
            style: AppTypography.medium(
              fontSize: ScreenUtils.sp(12),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

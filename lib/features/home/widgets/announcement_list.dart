import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/data/mock/home_mock_data.dart';

class AnnouncementList extends StatelessWidget {
  const AnnouncementList({
    required this.items,
    super.key,
    this.onItemTap,
  });

  final List<HomeAnnouncement> items;
  final ValueChanged<HomeAnnouncement>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(items.length, (int index) {
        final HomeAnnouncement item = items[index];
        return _AnnouncementTile(
          item: item,
          showDivider: index < items.length - 1,
          onTap: onItemTap == null ? null : () => onItemTap!(item),
        );
      }),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({
    required this.item,
    required this.showDivider,
    this.onTap,
  });

  final HomeAnnouncement item;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(top: ScreenUtils.h(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _LeadingIcon(icon: item.icon),
            SizedBox(width: ScreenUtils.w(10)),
            Expanded(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: ScreenUtils.h(14)),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: _Content(item: item)),
                        SizedBox(width: ScreenUtils.w(10)),
                        _Trailing(item: item),
                      ],
                    ),
                  ),
                  if (showDivider)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.divider,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtils.w(32),
      height: ScreenUtils.w(32),
      decoration: BoxDecoration(
        color: AppColors.primaryButtonBg.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: ScreenUtils.sp(16),
        color: AppColors.primaryButtonBg,
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.item});

  final HomeAnnouncement item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          item.title,
          style: AppTypography.medium(fontSize: 12, height: 1.2),
        ),
        SizedBox(height: ScreenUtils.h(6)),
        Text(
          item.subtitle,
          style: AppTypography.medium(
            fontSize: 10,
            color: AppColors.white.withValues(alpha: 0.6),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({required this.item});

  final HomeAnnouncement item;

  @override
  Widget build(BuildContext context) {
    if (item.thumbnailUrl != null) {
      final double width = ScreenUtils.w(70);
      final double height = ScreenUtils.h(44);

      return ClipRRect(
        borderRadius: BorderRadius.circular(ScreenUtils.r(6)),
        child: Image.network(
          item.thumbnailUrl!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => ColoredBox(
            color: AppColors.divider,
            child: SizedBox(width: width, height: height),
          ),
        ),
      );
    }

    if (item.timeLabel == null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          item.timeLabel!,
          style: AppTypography.medium(fontSize: 10),
        ),
        if (item.showUnreadDot) ...<Widget>[
          SizedBox(width: ScreenUtils.w(6)),
          Container(
            width: ScreenUtils.w(8),
            height: ScreenUtils.w(8),
            decoration: const BoxDecoration(
              color: AppColors.primaryButtonBg,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/data/mock/home_mock_data.dart';

class SocialFeedCard extends StatelessWidget {
  const SocialFeedCard({
    required this.post,
    super.key,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onBookmark,
  });

  final HomeFeedPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _header(),
            SizedBox(height: ScreenUtils.h(12)),
            Text(
              post.caption,
              style: AppTypography.regular(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: ScreenUtils.h(12)),
            _image(),
            SizedBox(height: ScreenUtils.h(12)),
            _engagement(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: ScreenUtils.r(20),
          backgroundColor: AppColors.divider,
          backgroundImage: NetworkImage(post.avatarUrl),
          onBackgroundImageError: (exception, stackTrace) {},
        ),
        SizedBox(width: ScreenUtils.w(10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                post.authorName,
                style: AppTypography.semiBold(fontSize: 14),
              ),
              SizedBox(height: ScreenUtils.h(2)),
              Text(
                '${post.officeLabel} · ${post.timeAgo}',
                style: AppTypography.regular(
                  fontSize: 11,
                  color: AppColors.mutedGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _image() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          post.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => ColoredBox(
            color: AppColors.cardSurface,
            child: Icon(
              Icons.image_outlined,
              color: AppColors.mutedGrey,
              size: ScreenUtils.sp(32),
            ),
          ),
        ),
      ),
    );
  }

  Widget _engagement() {
    return Row(
      children: <Widget>[
        _EngagementButton(
          icon: Icons.favorite,
          label: '${post.likes}',
          color: const Color(0xFFE53935),
          onTap: onLike,
        ),
        SizedBox(width: ScreenUtils.w(18)),
        _EngagementButton(
          icon: Icons.chat_bubble_outline,
          label: '${post.comments}',
          onTap: onComment,
        ),
        const Spacer(),
        GestureDetector(
          onTap: onBookmark,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.all(ScreenUtils.w(4)),
            child: Icon(
              Icons.bookmark_border,
              size: ScreenUtils.sp(20),
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _EngagementButton extends StatelessWidget {
  const _EngagementButton({
    required this.icon,
    required this.label,
    this.color = AppColors.white,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: <Widget>[
          Icon(icon, size: ScreenUtils.sp(20), color: color),
          SizedBox(width: ScreenUtils.w(6)),
          Text(label, style: AppTypography.medium(fontSize: 13)),
        ],
      ),
    );
  }
}

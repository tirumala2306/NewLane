import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/feed/domain/entities/feed_post.dart';
import 'package:newlane/features/profile/widgets/profile_avatar.dart';

class FeedPostCard extends StatelessWidget {
  const FeedPostCard({
    required this.post,
    super.key,
    this.onLike,
    this.onComment,
  });

  final FeedPost post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = post.imageUrl.isNotEmpty
        ? post.imageUrl
        : (post.mediaUrls.isNotEmpty ? post.mediaUrls.first : '');

    return Container(
      padding: EdgeInsets.all(ScreenUtils.w(14)),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(ScreenUtils.r(12)),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ProfileAvatar(
                url: post.authorAvatar.isEmpty ? null : post.authorAvatar,
                size: ScreenUtils.w(42),
              ),
              SizedBox(width: ScreenUtils.w(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      post.authorName.isEmpty ? 'Agent' : post.authorName,
                      style: AppTypography.semiBold(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (post.officeLabel.trim().isNotEmpty) ...<Widget>[
                      SizedBox(height: ScreenUtils.h(2)),
                      Text(
                        post.officeLabel.trim(),
                        style: AppTypography.regular(
                          fontSize: 11,
                          color: AppColors.white.withValues(alpha: 0.75),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (post.timeAgo.isNotEmpty) ...<Widget>[
                      SizedBox(height: ScreenUtils.h(2)),
                      Text(
                        post.timeAgo,
                        style: AppTypography.regular(
                          fontSize: 11,
                          color: AppColors.mutedGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.more_horiz,
                color: AppColors.white.withValues(alpha: 0.7),
                size: ScreenUtils.sp(22),
              ),
            ],
          ),
          if (post.caption.trim().isNotEmpty) ...<Widget>[
            SizedBox(height: ScreenUtils.h(12)),
            Text(
              post.caption,
              style: AppTypography.regular(fontSize: 13, height: 1.45),
            ),
          ],
          if (imageUrl.isNotEmpty) ...<Widget>[
            SizedBox(height: ScreenUtils.h(12)),
            ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: AppColors.cardSurface,
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.mutedGrey,
                      size: ScreenUtils.sp(32),
                    ),
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: ScreenUtils.h(12)),
          Row(
            children: <Widget>[
              _Action(
                icon: post.likedByMe ? Icons.favorite : Icons.favorite_border,
                label: '${post.likesCount}',
                color: post.likedByMe
                    ? const Color(0xFFE53935)
                    : AppColors.white,
                onTap: onLike,
              ),
              SizedBox(width: ScreenUtils.w(18)),
              _Action(
                icon: Icons.chat_bubble_outline,
                label: '${post.commentsCount}',
                onTap: onComment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
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

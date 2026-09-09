import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/feed/domain/entities/feed_post.dart';
import 'package:newlane/features/profile/widgets/profile_avatar.dart';

class SocialFeedCard extends StatelessWidget {
  const SocialFeedCard({
    required this.post,
    super.key,
    this.onTap,
    this.onLike,
    this.onComment,
  });

  final FeedPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = post.imageUrl.isNotEmpty
        ? post.imageUrl
        : (post.mediaUrls.isNotEmpty ? post.mediaUrls.first : '');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                ProfileAvatar(
                  url: post.authorAvatar.isEmpty ? null : post.authorAvatar,
                  size: ScreenUtils.w(40),
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
                        <String>[
                          if (post.officeLabel.trim().isNotEmpty)
                            post.officeLabel,
                          if (post.timeAgo.isNotEmpty) post.timeAgo,
                        ].join(' · '),
                        style: AppTypography.regular(
                          fontSize: 11,
                          color: AppColors.mutedGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (post.caption.trim().isNotEmpty) ...<Widget>[
              SizedBox(height: ScreenUtils.h(12)),
              Text(
                post.caption,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.regular(fontSize: 13, height: 1.4),
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
                Icon(
                  post.likedByMe ? Icons.favorite : Icons.favorite_border,
                  size: ScreenUtils.sp(18),
                  color: post.likedByMe
                      ? const Color(0xFFE53935)
                      : AppColors.white,
                ),
                SizedBox(width: ScreenUtils.w(6)),
                Text(
                  '${post.likesCount}',
                  style: AppTypography.medium(fontSize: 13),
                ),
                SizedBox(width: ScreenUtils.w(18)),
                Icon(
                  Icons.chat_bubble_outline,
                  size: ScreenUtils.sp(18),
                  color: AppColors.white,
                ),
                SizedBox(width: ScreenUtils.w(6)),
                Text(
                  '${post.commentsCount}',
                  style: AppTypography.medium(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

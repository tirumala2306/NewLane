import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/media_url.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/widgets/home_card.dart';
import 'package:newlane/features/profile/data/mock/profile_mock_data.dart';

class ProfileListingsSection extends StatelessWidget {
  const ProfileListingsSection({
    required this.listings,
    super.key,
    this.onViewAll,
  });

  final List<ProfileListing> listings;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      padding: EdgeInsets.fromLTRB(
        ScreenUtils.w(14),
        ScreenUtils.h(14),
        ScreenUtils.w(14),
        ScreenUtils.h(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Active Listings',
                  style: AppTypography.semiBold(fontSize: 14),
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtils.h(4),
                    horizontal: ScreenUtils.w(2),
                  ),
                  child: Text(
                    'View all',
                    style: AppTypography.medium(
                      fontSize: 12,
                      color: AppColors.primaryButtonBg,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtils.h(12)),
          SizedBox(
            height: ScreenUtils.h(196),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: listings.length,
              separatorBuilder: (_, _) => SizedBox(width: ScreenUtils.w(10)),
              itemBuilder: (BuildContext context, int index) {
                return _ListingCard(listing: listings[index]);
              },
            ),
          ),
          SizedBox(height: ScreenUtils.h(12)),
          Center(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: 'Powered by ',
                    style: AppTypography.medium(
                      fontSize: 10,
                      color: AppColors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  TextSpan(
                    text: 'NEWLANE',
                    style: AppTypography.semiBold(
                      fontSize: 10,
                      color: AppColors.primaryButtonBg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});

  final ProfileListing listing;

  @override
  Widget build(BuildContext context) {
    final double width = ScreenUtils.w(148);
    final String? imageUrl = resolveMediaUrl(listing.imageUrl);
    final BorderRadius radius = BorderRadius.circular(ScreenUtils.r(10));

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ClipRRect(
              borderRadius: radius,
              child: ColoredBox(
                color: const Color(0xFF111111),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          if (imageUrl != null && imageUrl.isNotEmpty)
                            Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => ColoredBox(
                                color: AppColors.cardSurface,
                                child: Icon(
                                  Icons.home_outlined,
                                  color: AppColors.mutedGrey,
                                  size: ScreenUtils.sp(28),
                                ),
                              ),
                            )
                          else
                            ColoredBox(
                              color: AppColors.cardSurface,
                              child: Icon(
                                Icons.home_outlined,
                                color: AppColors.mutedGrey,
                                size: ScreenUtils.sp(28),
                              ),
                            ),
                          Positioned(
                            top: ScreenUtils.h(8),
                            right: ScreenUtils.w(8),
                            child: Container(
                              padding: EdgeInsets.all(ScreenUtils.w(4)),
                              decoration: BoxDecoration(
                                color: AppColors.black.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.favorite_border,
                                size: ScreenUtils.sp(14),
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          ScreenUtils.w(8),
                          ScreenUtils.h(8),
                          ScreenUtils.w(8),
                          ScreenUtils.h(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              listing.address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.semiBold(fontSize: 11),
                            ),
                            if (listing.city.trim().isNotEmpty) ...<Widget>[
                              SizedBox(height: ScreenUtils.h(2)),
                              Text(
                                listing.city,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.regular(
                                  fontSize: 9,
                                  color: AppColors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              listing.price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.semiBold(
                                fontSize: 11,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

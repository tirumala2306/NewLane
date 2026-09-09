import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/widgets/home_section_header.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        HomeSectionHeader(
          title: 'Active Listings',
          onViewAll: onViewAll,
        ),
        SizedBox(height: ScreenUtils.h(12)),
        SizedBox(
          height: ScreenUtils.h(180),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: listings.length,
            separatorBuilder: (context, index) =>
                SizedBox(width: ScreenUtils.w(12)),
            itemBuilder: (BuildContext context, int index) {
              return _ListingCard(listing: listings[index]);
            },
          ),
        ),
        SizedBox(height: ScreenUtils.h(12)),
        Center(
          child: Text(
            'Powered by NEWLANE',
            style: AppTypography.medium(
              fontSize: 10,
              color: AppColors.mutedGrey,
            ),
          ),
        ),
      ],
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});

  final ProfileListing listing;

  @override
  Widget build(BuildContext context) {
    final double width = ScreenUtils.w(160);

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                child: Image.network(
                  listing.imageUrl,
                  width: width,
                  height: ScreenUtils.h(110),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: width,
                    height: ScreenUtils.h(110),
                    color: AppColors.cardSurface,
                  ),
                ),
              ),
              Positioned(
                top: ScreenUtils.h(8),
                right: ScreenUtils.w(8),
                child: Icon(
                  Icons.favorite_border,
                  size: ScreenUtils.sp(18),
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtils.h(8)),
          Text(
            listing.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.semiBold(fontSize: 12),
          ),
          SizedBox(height: ScreenUtils.h(2)),
          Text(
            listing.city,
            style: AppTypography.medium(
              fontSize: 10,
              color: AppColors.mutedGrey,
            ),
          ),
          SizedBox(height: ScreenUtils.h(4)),
          Text(
            listing.price,
            style: AppTypography.semiBold(
              fontSize: 12,
              color: AppColors.primaryButtonBg,
            ),
          ),
        ],
      ),
    );
  }
}

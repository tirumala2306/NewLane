import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';

class MyRequestCard extends StatelessWidget {
  const MyRequestCard({
    required this.request,
    super.key,
    this.onTap,
  });

  final MarketingRequest request;
  final VoidCallback? onTap;

  IconData get _typeIcon {
    return switch (request.requestType) {
      MarketingRequestType.justListed => Icons.home_outlined,
      MarketingRequestType.openHouse => Icons.meeting_room_outlined,
      MarketingRequestType.socialMediaPost => Icons.campaign_outlined,
      MarketingRequestType.flyer => Icons.description_outlined,
      MarketingRequestType.other => Icons.more_horiz,
    };
  }

  Color get _statusColor {
    return switch (request.status) {
      MarketingRequestStatus.submitted => AppColors.snackInfo,
      MarketingRequestStatus.inProgress => const Color(0xFFE6C35C),
      MarketingRequestStatus.completed => const Color(0xFF22AF4D),
    };
  }

  IconData get _statusIcon {
    return switch (request.status) {
      MarketingRequestStatus.submitted => Icons.schedule,
      MarketingRequestStatus.inProgress => Icons.autorenew,
      MarketingRequestStatus.completed => Icons.check_circle_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        child: Container(
          padding: EdgeInsets.all(ScreenUtils.w(12)),
          decoration: BoxDecoration(
            color: const Color(0xFF090909),
            borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
            border: Border.all(
              color: AppColors.primaryButtonBg.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                child: _thumb(),
              ),
              SizedBox(width: ScreenUtils.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          _typeIcon,
                          size: ScreenUtils.sp(14),
                          color: AppColors.primaryButtonBg,
                        ),
                        SizedBox(width: ScreenUtils.w(6)),
                        Expanded(
                          child: Text(
                            request.requestType.label,
                            style: AppTypography.semiBold(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ScreenUtils.h(4)),
                    Text(
                      request.listingAddress.isEmpty
                          ? 'No address'
                          : request.listingAddress,
                      style: AppTypography.regular(
                        fontSize: 11,
                        height: 1.3,
                        color: AppColors.white.withValues(alpha: 0.75),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (request.requestedOnLabel.isNotEmpty) ...<Widget>[
                      SizedBox(height: ScreenUtils.h(4)),
                      Text(
                        request.requestedOnLabel,
                        style: AppTypography.regular(
                          fontSize: 10,
                          color: AppColors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                    SizedBox(height: ScreenUtils.h(8)),
                    Row(
                      children: <Widget>[
                        Icon(
                          _statusIcon,
                          size: ScreenUtils.sp(14),
                          color: _statusColor,
                        ),
                        SizedBox(width: ScreenUtils.w(4)),
                        Text(
                          request.status.label,
                          style: AppTypography.medium(
                            fontSize: 11,
                            color: _statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.white.withValues(alpha: 0.5),
                size: ScreenUtils.sp(20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumb() {
    final double size = ScreenUtils.w(64);
    final String url = request.thumbnailUrl.trim();
    if (url.isNotEmpty) {
      return Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
          return _placeholder(size);
        },
      );
    }
    return _placeholder(size);
  }

  Widget _placeholder(double size) {
    return Container(
      width: size,
      height: size,
      color: AppColors.cardSurface,
      child: Icon(
        Icons.home_work_outlined,
        color: AppColors.primaryButtonBg,
        size: ScreenUtils.sp(22),
      ),
    );
  }
}

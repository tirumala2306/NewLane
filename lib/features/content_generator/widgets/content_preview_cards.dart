import 'package:flutter/material.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/content_generator/data/content_generator_mock.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/shared/widgets/app_svg.dart';

class ContentPostPreviewCard extends StatelessWidget {
  const ContentPostPreviewCard({
    required this.draft,
    super.key,
    this.onTap,
  });

  final ContentGeneratorDraft draft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(ScreenUtils.r(12));
    final String headline = ContentGeneratorMock.headlineFor(draft);

    return Material(
      color: AppColors.white,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                ScreenUtils.w(12),
                ScreenUtils.h(10),
                ScreenUtils.w(8),
                ScreenUtils.h(10),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: ScreenUtils.w(32),
                    height: ScreenUtils.w(32),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.black,
                      shape: BoxShape.circle,
                    ),
                    child: AppSvg(
                      AssetConstants.newLaneAppLogo,
                      width: ScreenUtils.w(22),
                      height: ScreenUtils.h(10),
                    ),
                  ),
                  SizedBox(width: ScreenUtils.w(8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'NEW LANE',
                          style: AppTypography.semiBold(
                            fontSize: 11,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          '@newlane',
                          style: AppTypography.regular(
                            fontSize: 9,
                            color: const Color(0xFF6B6B6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.more_horiz,
                    color: AppColors.black,
                    size: ScreenUtils.sp(20),
                  ),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.network(
                    ContentGeneratorMock.previewImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Color(0x33000000),
                          Color(0xCC000000),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(ScreenUtils.w(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtils.w(8),
                            vertical: ScreenUtils.h(4),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryButtonBg,
                            borderRadius: BorderRadius.circular(
                              ScreenUtils.r(4),
                            ),
                          ),
                          child: Text(
                            'JUST LISTED',
                            style: AppTypography.semiBold(
                              fontSize: 8,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          headline,
                          style: AppTypography.semiBold(
                            fontSize: 18,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: ScreenUtils.h(8)),
                        Wrap(
                          spacing: ScreenUtils.w(12),
                          children: const <Widget>[
                            _StatChip(
                              icon: Icons.bed_outlined,
                              label: '${ContentGeneratorMock.beds} Beds',
                            ),
                            _StatChip(
                              icon: Icons.bathtub_outlined,
                              label: '${ContentGeneratorMock.baths} Baths',
                            ),
                            _StatChip(
                              icon: Icons.square_foot,
                              label: '${ContentGeneratorMock.sqft} Sq Ft',
                            ),
                          ],
                        ),
                        SizedBox(height: ScreenUtils.h(8)),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on_outlined,
                              size: ScreenUtils.sp(14),
                              color: AppColors.white,
                            ),
                            SizedBox(width: ScreenUtils.w(4)),
                            Expanded(
                              child: Text(
                                ContentGeneratorMock.defaultLocation,
                                style: AppTypography.regular(fontSize: 11),
                              ),
                            ),
                            AppSvg(
                              AssetConstants.newLaneAppLogo,
                              width: ScreenUtils.w(52),
                              height: ScreenUtils.h(14),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: ScreenUtils.sp(13), color: AppColors.white),
        SizedBox(width: ScreenUtils.w(4)),
        Text(label, style: AppTypography.regular(fontSize: 10)),
      ],
    );
  }
}

class ContentFlyerCard extends StatelessWidget {
  const ContentFlyerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(ScreenUtils.r(12));

    return ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: 0.78,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.network(
              ContentGeneratorMock.flyerImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Color(0xFF1A1A1A),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0x99000000),
                    Color(0x22000000),
                    Color(0xE6000000),
                  ],
                  stops: <double>[0, 0.4, 1],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                ScreenUtils.w(16),
                ScreenUtils.h(16),
                ScreenUtils.w(16),
                ScreenUtils.h(18),
              ),
              child: Column(
                children: <Widget>[
                  AppSvg(
                    AssetConstants.newLaneAppLogo,
                    height: ScreenUtils.h(18),
                  ),
                  SizedBox(height: ScreenUtils.h(18)),
                  Text(
                    'JUST LISTED',
                    style: AppTypography.semiBold(fontSize: 22),
                  ),
                  SizedBox(height: ScreenUtils.h(8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.location_on,
                        size: ScreenUtils.sp(14),
                        color: AppColors.primaryButtonBg,
                      ),
                      SizedBox(width: ScreenUtils.w(4)),
                      Flexible(
                        child: Text(
                          ContentGeneratorMock.flyerAddress,
                          style: AppTypography.semiBold(
                            fontSize: 12,
                            color: AppColors.primaryButtonBg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    ContentGeneratorMock.flyerCity,
                    style: AppTypography.medium(
                      fontSize: 11,
                      color: AppColors.primaryButtonBg,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtils.w(10),
                      vertical: ScreenUtils.h(10),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _FlyerStat(
                          icon: Icons.bed_outlined,
                          label: '${ContentGeneratorMock.flyerBeds} Bedrooms',
                        ),
                        _FlyerStat(
                          icon: Icons.bathtub_outlined,
                          label:
                              '${ContentGeneratorMock.flyerBaths} Bathrooms',
                        ),
                        _FlyerStat(
                          icon: Icons.open_in_full,
                          label: '${ContentGeneratorMock.flyerSqft} Sq. Ft',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ScreenUtils.h(12)),
                  Text(
                    ContentGeneratorMock.flyerPrice,
                    style: AppTypography.semiBold(fontSize: 22),
                  ),
                  SizedBox(height: ScreenUtils.h(4)),
                  Text(
                    ContentGeneratorMock.flyerTagline,
                    style: AppTypography.medium(
                      fontSize: 12,
                      color: AppColors.primaryButtonBg,
                    ),
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

class _FlyerStat extends StatelessWidget {
  const _FlyerStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, size: ScreenUtils.sp(14), color: AppColors.primaryButtonBg),
        SizedBox(height: ScreenUtils.h(4)),
        Text(
          label,
          style: AppTypography.regular(fontSize: 8),
        ),
      ],
    );
  }
}

class ContentTextOnlyCard extends StatelessWidget {
  const ContentTextOnlyCard({
    required this.text,
    super.key,
    this.onCopy,
  });

  final String text;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenUtils.w(14)),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            text,
            style: AppTypography.regular(fontSize: 13, height: 1.5),
          ),
          if (onCopy != null) ...<Widget>[
            SizedBox(height: ScreenUtils.h(16)),
            OutlinedButton.icon(
              onPressed: onCopy,
              icon: Icon(
                Icons.copy_outlined,
                size: ScreenUtils.sp(16),
                color: AppColors.white,
              ),
              label: Text(
                'Copy Text',
                style: AppTypography.semiBold(fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.primaryButtonBg),
                minimumSize: Size.fromHeight(ScreenUtils.h(44)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

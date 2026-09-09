import 'dart:io';

import 'package:flutter/material.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/content_generator/data/content_generator_mock.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/shared/widgets/app_svg.dart';

class TemplateGraphicPreview extends StatelessWidget {
  const TemplateGraphicPreview({
    required this.draft,
    super.key,
  });

  final ContentGeneratorDraft draft;

  @override
  Widget build(BuildContext context) {
    final ContentGraphicSpec spec =
        draft.graphicSpec ??
        ContentGraphicSpec(
          template: draft.templateName,
          format: draft.format,
          fields: ContentGraphicFields(
            address: draft.propertyAddress,
            price: draft.price.trim().isEmpty
                ? ''
                : '\$${draft.priceValue}',
            bedrooms: draft.bedroomsValue,
            bathrooms: draft.bathroomsValue,
            sqft: draft.sqftValue,
          ),
        );
    final ContentGraphicFields fields = spec.fields;
    final ContentFormat format = draft.format;
    final String? localPhoto =
        draft.photoPaths.isNotEmpty ? draft.photoPaths.first : null;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: ScreenUtils.w(320)),
        child: AspectRatio(
          aspectRatio: format.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ScreenUtils.r(12)),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (localPhoto != null)
                  Image.file(
                    File(localPhoto),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _networkFallback(),
                  )
                else
                  _networkFallback(),
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
                      stops: <double>[0, 0.42, 1],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    ScreenUtils.w(14),
                    ScreenUtils.h(14),
                    ScreenUtils.w(14),
                    ScreenUtils.h(16),
                  ),
                  child: Column(
                    children: <Widget>[
                      AppSvg(
                        AssetConstants.newLaneAppLogo,
                        height: ScreenUtils.h(16),
                      ),
                      SizedBox(height: ScreenUtils.h(format == ContentFormat.carousel ? 10 : 18)),
                      Text(
                        fields.headline,
                        textAlign: TextAlign.center,
                        style: AppTypography.semiBold(
                          fontSize: format == ContentFormat.carousel ? 18 : 22,
                        ),
                      ),
                      SizedBox(height: ScreenUtils.h(8)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            size: ScreenUtils.sp(13),
                            color: AppColors.primaryButtonBg,
                          ),
                          SizedBox(width: ScreenUtils.w(4)),
                          Flexible(
                            child: Text(
                              fields.address.isEmpty
                                  ? draft.propertyAddress
                                  : fields.address,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.semiBold(
                                fontSize: 11,
                                color: AppColors.primaryButtonBg,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtils.w(10),
                          vertical: ScreenUtils.h(10),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            _Stat(
                              icon: Icons.bed_outlined,
                              label: '${_trimNum(fields.bedrooms)} Bedrooms',
                            ),
                            _Stat(
                              icon: Icons.bathtub_outlined,
                              label: '${_trimNum(fields.bathrooms)} Bathrooms',
                            ),
                            _Stat(
                              icon: Icons.open_in_full,
                              label: '${_formatSqft(fields.sqft)} Sq. Ft',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: ScreenUtils.h(10)),
                      Text(
                        fields.price.isEmpty ? '—' : fields.price,
                        style: AppTypography.semiBold(fontSize: 20),
                      ),
                      SizedBox(height: ScreenUtils.h(4)),
                      Text(
                        fields.tagline,
                        style: AppTypography.medium(
                          fontSize: 11,
                          color: AppColors.primaryButtonBg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _networkFallback() {
    return Image.network(
      ContentGeneratorMock.fallbackImageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF1A1A1A)),
    );
  }

  static String _trimNum(num value) {
    if (value == value.roundToDouble()) return '${value.toInt()}';
    return '$value';
  }

  static String _formatSqft(int value) {
    if (value <= 0) return '—';
    final String digits = '$value';
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final int fromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
    }
    return '$buffer';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        children: <Widget>[
          Icon(icon, size: ScreenUtils.sp(14), color: AppColors.white),
          SizedBox(height: ScreenUtils.h(4)),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.regular(fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class ContentFormatSelector extends StatelessWidget {
  const ContentFormatSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final ContentFormat selected;
  final ValueChanged<ContentFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ContentFormat.values.map((ContentFormat format) {
        final bool isSelected = format == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: format == ContentFormat.carousel ? 0 : ScreenUtils.w(8),
            ),
            child: InkWell(
              onTap: () => onChanged(format),
              borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: ScreenUtils.h(10)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryButtonBg
                        : AppColors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Icon(
                      switch (format) {
                        ContentFormat.story => Icons.smartphone_outlined,
                        ContentFormat.post => Icons.crop_square,
                        ContentFormat.carousel => Icons.crop_landscape,
                      },
                      size: ScreenUtils.sp(20),
                      color: isSelected
                          ? AppColors.primaryButtonBg
                          : AppColors.white,
                    ),
                    SizedBox(height: ScreenUtils.h(6)),
                    Text(
                      format.label,
                      style: AppTypography.semiBold(
                        fontSize: 11,
                        color: isSelected
                            ? AppColors.primaryButtonBg
                            : AppColors.white,
                      ),
                    ),
                    Text(
                      format.ratioLabel,
                      style: AppTypography.regular(
                        fontSize: 9,
                        color: isSelected
                            ? AppColors.primaryButtonBg
                            : AppColors.mutedGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

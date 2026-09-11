import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/content_generator/data/content_generator_mock.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/shared/widgets/app_svg.dart';
import 'package:path_provider/path_provider.dart';

class TemplateGraphicPreview extends StatelessWidget {
  const TemplateGraphicPreview({
    required this.draft,
    super.key,
    this.repaintKey,
  });

  final ContentGeneratorDraft draft;
  final GlobalKey? repaintKey;

  @override
  Widget build(BuildContext context) {
    final ContentGraphicSpec spec =
        draft.graphicSpec ??
        ContentGraphicSpec(
          template: draft.templateName,
          format: draft.format,
          fields: ContentGraphicFields(
            address: draft.propertyAddress,
            price: draft.price.trim().isEmpty ? '' : '\$${draft.priceValue}',
            bedrooms: draft.bedroomsValue,
            bathrooms: draft.bathroomsValue,
            sqft: draft.sqftValue,
          ),
        );
    final ContentGraphicFields fields = spec.fields;
    final ContentFormat format = draft.format;
    final String? localPhoto =
        draft.photoPaths.isNotEmpty ? draft.photoPaths.first : null;
    final (String street, String city) = _splitAddress(
      fields.address.isEmpty ? draft.propertyAddress : fields.address,
    );

    final Widget card = Center(
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
                        Color(0xAA000000),
                        Color(0x22000000),
                        Color(0xF2000000),
                      ],
                      stops: <double>[0, 0.4, 1],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    ScreenUtils.w(14),
                    ScreenUtils.h(format == ContentFormat.carousel ? 8 : 16),
                    ScreenUtils.w(14),
                    ScreenUtils.h(format == ContentFormat.carousel ? 8 : 14),
                  ),
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final bool compact =
                          format == ContentFormat.carousel ||
                          constraints.maxHeight < 260;
                      final double logoH = ScreenUtils.h(compact ? 12 : 18);
                      final double headlineSize = compact ? 15.0 : 24.0;
                      final double streetSize = compact ? 11.0 : 13.0;
                      final double citySize = compact ? 10.0 : 12.0;
                      final double priceSize = compact ? 16.0 : 22.0;
                      final double tagSize = compact ? 9.0 : 11.0;
                      final double gap = ScreenUtils.h(compact ? 6 : 10);

                      final Widget top = Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          AppSvg(
                            AssetConstants.newLaneAppLogo,
                            height: logoH,
                          ),
                          SizedBox(height: gap),
                          Text(
                            fields.headline.toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.semiBold(
                              fontSize: headlineSize,
                            ).copyWith(letterSpacing: 0.6),
                          ),
                          SizedBox(height: ScreenUtils.h(compact ? 6 : 10)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                  top: ScreenUtils.h(1),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  size: ScreenUtils.sp(compact ? 12 : 14),
                                  color: AppColors.primaryButtonBg,
                                ),
                              ),
                              SizedBox(width: ScreenUtils.w(4)),
                              Flexible(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      street.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.semiBold(
                                        fontSize: streetSize,
                                        height: 1.2,
                                      ),
                                    ),
                                    if (city.isNotEmpty) ...<Widget>[
                                      SizedBox(height: ScreenUtils.h(2)),
                                      Text(
                                        city.toUpperCase(),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.semiBold(
                                          fontSize: citySize,
                                          color: AppColors.primaryButtonBg,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );

                      final Widget bottom = Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(
                          ScreenUtils.w(compact ? 8 : 10),
                          ScreenUtils.h(compact ? 8 : 10),
                          ScreenUtils.w(compact ? 8 : 10),
                          ScreenUtils.h(compact ? 8 : 10),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xE6121212),
                          borderRadius: BorderRadius.circular(
                            ScreenUtils.r(10),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                _StatTile(
                                  icon: Icons.bed_outlined,
                                  value: _trimNum(fields.bedrooms),
                                  label: 'Bedrooms',
                                  compact: compact,
                                ),
                                SizedBox(width: ScreenUtils.w(6)),
                                _StatTile(
                                  icon: Icons.bathtub_outlined,
                                  value: _trimNum(fields.bathrooms),
                                  label: 'Bathrooms',
                                  compact: compact,
                                ),
                                SizedBox(width: ScreenUtils.w(6)),
                                _StatTile(
                                  icon: Icons.open_in_full,
                                  value: _formatSqft(fields.sqft),
                                  label: 'Sq. Ft',
                                  compact: compact,
                                ),
                              ],
                            ),
                            SizedBox(height: ScreenUtils.h(compact ? 8 : 12)),
                            Text(
                              fields.price.isEmpty ? '—' : fields.price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.semiBold(
                                fontSize: priceSize,
                              ),
                            ),
                            SizedBox(height: ScreenUtils.h(compact ? 2 : 4)),
                            Text(
                              fields.tagline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.medium(
                                fontSize: tagSize,
                                color: AppColors.primaryButtonBg,
                              ).copyWith(letterSpacing: 0.2),
                            ),
                          ],
                        ),
                      );

                      return SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                top,
                                SizedBox(height: gap * 1.4),
                                bottom,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (repaintKey == null) return card;
    return RepaintBoundary(key: repaintKey, child: card);
  }

  Widget _networkFallback() {
    return Image.network(
      ContentGeneratorMock.fallbackImageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF1A1A1A)),
    );
  }

  static (String, String) _splitAddress(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) return ('', '');
    final List<String> parts = value
        .split(RegExp(r'[\n,]'))
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return (value, '');
    if (parts.length == 1) return (parts.first, '');
    return (parts.first, parts.sublist(1).join(', '));
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.compact,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtils.h(compact ? 6 : 8),
          horizontal: ScreenUtils.w(4),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
          border: Border.all(
            color: AppColors.primaryButtonBg.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: ScreenUtils.sp(compact ? 12 : 14),
              color: AppColors.primaryButtonBg,
            ),
            SizedBox(height: ScreenUtils.h(compact ? 3 : 4)),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.semiBold(fontSize: compact ? 11 : 13),
            ),
            SizedBox(height: ScreenUtils.h(1)),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.regular(
                fontSize: compact ? 7 : 8,
                color: AppColors.primaryButtonBg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Captures [repaintKey] preview to a PNG on device storage.
Future<String?> captureTemplatePng(GlobalKey repaintKey) async {
  final BuildContext? ctx = repaintKey.currentContext;
  if (ctx == null) return null;
  final RenderObject? object = ctx.findRenderObject();
  if (object is! RenderRepaintBoundary) return null;

  final ui.Image image = await object.toImage(pixelRatio: 3);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return null;

  final Directory dir =
      await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  final String path =
      '${dir.path}/newlane_template_${DateTime.now().millisecondsSinceEpoch}.png';
  final File file = File(path);
  await file.writeAsBytes(byteData.buffer.asUint8List());
  return file.path;
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

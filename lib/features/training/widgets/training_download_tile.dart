import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/training/domain/entities/training_resource.dart';
import 'package:newlane/features/training/widgets/training_hub_card.dart';

/// List row for training files.
/// - Eye / title → [onOpen] (view / play)
/// - Download icon only → [onDownload]
class TrainingDownloadTile extends StatefulWidget {
  const TrainingDownloadTile({
    required this.resource,
    super.key,
    this.onOpen,
    this.onDownload,
  });

  final TrainingResource resource;
  final VoidCallback? onOpen;
  final Future<void> Function()? onDownload;

  @override
  State<TrainingDownloadTile> createState() => _TrainingDownloadTileState();
}

class _TrainingDownloadTileState extends State<TrainingDownloadTile> {
  bool _downloading = false;

  Future<void> _handleDownload() async {
    if (_downloading || widget.onDownload == null) return;
    setState(() => _downloading = true);
    try {
      await widget.onDownload!();
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TrainingResource resource = widget.resource;
    final Color iconColor = resource.isPdf
        ? const Color(0xFFE53935)
        : resource.isVideo
            ? AppColors.primaryButtonBg
            : const Color(0xFF3B82F6);
    final IconData leadingIcon = resource.isPdf
        ? Icons.picture_as_pdf
        : resource.isVideo
            ? Icons.play_circle_fill
            : Icons.insert_drive_file;

    return TrainingHubCard(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onOpen,
                borderRadius: BorderRadius.circular(ScreenUtils.r(6)),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: ScreenUtils.w(28),
                      height: ScreenUtils.w(28),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(ScreenUtils.r(6)),
                      ),
                      child: Icon(
                        leadingIcon,
                        color: iconColor,
                        size: ScreenUtils.sp(16),
                      ),
                    ),
                    SizedBox(width: ScreenUtils.w(10)),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            resource.displayName,
                            style: AppTypography.semiBold(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: ScreenUtils.h(2)),
                          Text(
                            resource.displaySize,
                            style: AppTypography.regular(
                              fontSize: 10,
                              color: AppColors.white.withValues(alpha: 0.55),
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
          if (widget.onOpen != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onOpen,
                borderRadius: BorderRadius.circular(ScreenUtils.r(20)),
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtils.w(6)),
                  child: Icon(
                    resource.isVideo
                        ? Icons.play_arrow_rounded
                        : Icons.visibility_outlined,
                    color: AppColors.primaryButtonBg,
                    size: ScreenUtils.sp(20),
                  ),
                ),
              ),
            ),
          if (widget.onDownload != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _downloading ? null : _handleDownload,
                borderRadius: BorderRadius.circular(ScreenUtils.r(20)),
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtils.w(6)),
                  child: _downloading
                      ? SizedBox(
                          width: ScreenUtils.sp(18),
                          height: ScreenUtils.sp(18),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryButtonBg,
                          ),
                        )
                      : Icon(
                          Icons.download_rounded,
                          color: AppColors.primaryButtonBg,
                          size: ScreenUtils.sp(20),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/create_post/data/mock/create_post_mock_data.dart';
import 'package:newlane/features/create_post/domain/entities/office.dart';
import 'package:newlane/features/create_post/domain/entities/post_location.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/feed/domain/entities/feed_post.dart';
import 'package:newlane/features/feed/domain/usecases/feed_usecases.dart';
import 'package:newlane/features/home/widgets/home_card.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _media = <XFile>[];

  Office? _selectedOffice;
  PostLocation? _selectedLocation;
  List<DirectoryAgent> _taggedPeople = <DirectoryAgent>[];
  CreatePostType _postType = CreatePostType.listing;
  CreateShareTo _shareTo = CreateShareTo.all;
  bool _postTypeExpanded = true;
  bool _shareToExpanded = true;
  bool _submitting = false;

  static const Color _dashedBorder = Color(0xFF4A4A4A);
  static const Color _cardBorder = Color(0x1ABD9037);

  @override
  void initState() {
    super.initState();
    _captionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final int remaining =
        CreatePostMockData.maxMediaCount - _media.length;
    if (remaining <= 0) {
      AppSnackBar.showInfo(
        context,
        title: 'Media limit',
        message: 'You can add up to ${CreatePostMockData.maxMediaCount} images.',
      );
      return;
    }

    final List<XFile> picked = await _imagePicker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (picked.isEmpty || !mounted) return;

    setState(() {
      _media.addAll(picked.take(remaining));
    });

    if (picked.length > remaining) {
      AppSnackBar.showInfo(
        context,
        title: 'Media limit',
        message:
            'Only ${CreatePostMockData.maxMediaCount} images are allowed. Extra photos were skipped.',
      );
    }
  }

  Future<void> _openTagOffice() async {
    final Object? result = await context.push<Object?>(
      AppRoutes.tagOffice,
      extra: _selectedOffice?.id,
    );
    if (!mounted || result == null) return;
    if (result is Office) {
      setState(() => _selectedOffice = result);
    }
  }

  Future<void> _openTagPeople() async {
    final Object? result = await context.push<Object?>(
      AppRoutes.tagPeople,
      extra: List<DirectoryAgent>.from(_taggedPeople),
    );
    if (!mounted || result == null) return;
    if (result is List<DirectoryAgent>) {
      setState(() => _taggedPeople = result);
    }
  }

  Future<void> _openAddLocation() async {
    final Object? result = await context.push<Object?>(
      AppRoutes.addLocation,
      extra: _selectedLocation,
    );
    if (!mounted || result == null) return;
    if (result is PostLocation) {
      setState(() => _selectedLocation = result);
    }
  }

  Future<void> _submitPost() async {
    final String caption = _captionController.text.trim();
    if (caption.isEmpty) {
      AppSnackBar.showInfo(
        context,
        title: 'Caption required',
        message: 'Write something before posting.',
      );
      return;
    }

    setState(() => _submitting = true);

    String composedCaption = caption;
    final String location = (_selectedLocation?.address.trim().isNotEmpty == true
            ? _selectedLocation!.address.trim()
            : _selectedLocation?.label.trim()) ??
        '';
    // Ensure Listing posts carry address for Active Listings / marketing picker.
    if (_postType == CreatePostType.listing &&
        location.isNotEmpty &&
        !composedCaption.toLowerCase().contains(location.toLowerCase())) {
      composedCaption = '$composedCaption\n$location';
    }
    if (_taggedPeople.isNotEmpty) {
      final String tags = _taggedPeople
          .map((DirectoryAgent a) {
            final String name = a.fullName.trim();
            return name.isEmpty ? null : '@$name';
          })
          .whereType<String>()
          .join(' ');
      if (tags.isNotEmpty && !composedCaption.contains(tags)) {
        composedCaption = '$composedCaption\n$tags';
      }
    }

    final Result<FeedPost> result =
        await InjectionContainer.instance.createFeedPost(
      CreateFeedPostParams(
        caption: composedCaption,
        postType: _postTypeLabel,
        visibility: _shareToLabel,
        mediaPaths: _media.map((XFile f) => f.path).toList(),
        locationLabel: location,
        taggedUserIds: _taggedPeople.map((DirectoryAgent a) => a.id).toList(),
        officeId: _selectedOffice?.id,
      ),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    result.when(
      ok: (_) {
        AppSnackBar.showSuccess(
          context,
          title: 'Posted',
          message: 'Your post is live on the feed.',
        );
        context.pop(true);
      },
      err: (failure) {
        AppSnackBar.showError(
          context,
          title: 'Post failed',
          message: failure.message,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double gap = ScreenUtils.h(16);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.close, size: ScreenUtils.sp(22)),
        ),
        centerTitle: true,
        title: Text(
          'CREATE POST',
          style: AppTypography.semiBold(
            fontSize: 16,
            color: AppColors.primaryButtonBg,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: _submitting ? null : _submitPost,
            child: _submitting
                ? SizedBox(
                    width: ScreenUtils.w(18),
                    height: ScreenUtils.w(18),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryButtonBg,
                    ),
                  )
                : Text(
                    'Post',
                    style: AppTypography.semiBold(
                      fontSize: 14,
                      color: AppColors.primaryButtonBg,
                    ),
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(16),
          ScreenUtils.h(8),
          ScreenUtils.w(16),
          ScreenUtils.h(32),
        ),
        children: <Widget>[
          if (_media.isEmpty) _mediaUpload() else _mediaThumbnails(),
          SizedBox(height: gap),
          _captionField(),
          SizedBox(height: gap),
          _tagSection(),
          SizedBox(height: gap),
          _postTypeSection(),
          SizedBox(height: gap),
          _shareToSection(),
        ],
      ),
    );
  }

  Widget _mediaUpload() {
    return GestureDetector(
      onTap: _pickMedia,
      child: CustomPaint(
        painter: _DashedRRectPainter(
          color: AppColors.primaryButtonBg.withValues(alpha: 0.55),
          radius: ScreenUtils.r(8),
        ),
        child: Container(
          width: double.infinity,
          height: ScreenUtils.h(140),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.photo_camera_outlined,
                size: ScreenUtils.sp(28),
                color: AppColors.primaryButtonBg,
              ),
              SizedBox(height: ScreenUtils.h(10)),
              Text(
                'Add Photos / Videos',
                style: AppTypography.semiBold(fontSize: 14),
              ),
              SizedBox(height: ScreenUtils.h(4)),
              Text(
                'Tap to upload · up to ${CreatePostMockData.maxMediaCount} images',
                style: AppTypography.medium(
                  fontSize: 11,
                  color: AppColors.mutedGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mediaThumbnails() {
    final bool canAddMore = _media.length < CreatePostMockData.maxMediaCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _mediaUploadCompact(),
        SizedBox(height: ScreenUtils.h(12)),
        SizedBox(
          height: ScreenUtils.w(72),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _media.length + (canAddMore ? 1 : 0),
            separatorBuilder: (context, index) =>
                SizedBox(width: ScreenUtils.w(8)),
            itemBuilder: (BuildContext context, int index) {
              if (canAddMore && index == _media.length) {
                return GestureDetector(
                  onTap: _pickMedia,
                  child: Container(
                    width: ScreenUtils.w(72),
                    height: ScreenUtils.w(72),
                    decoration: BoxDecoration(
                      color: const Color(0xFF090909),
                      borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                      border: Border.all(color: AppColors.primaryButtonBg),
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppColors.primaryButtonBg,
                      size: ScreenUtils.sp(24),
                    ),
                  ),
                );
              }

              final XFile file = _media[index];
              return Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                    child: Image.file(
                      File(file.path),
                      width: ScreenUtils.w(72),
                      height: ScreenUtils.w(72),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: ScreenUtils.w(72),
                        height: ScreenUtils.w(72),
                        color: AppColors.cardSurface,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _media.removeAt(index)),
                      child: Container(
                        width: ScreenUtils.w(18),
                        height: ScreenUtils.w(18),
                        decoration: const BoxDecoration(
                          color: AppColors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: ScreenUtils.sp(12),
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _mediaUploadCompact() {
    return Text(
      '${_media.length}/${CreatePostMockData.maxMediaCount} photos',
      style: AppTypography.medium(
        fontSize: 12,
        color: AppColors.mutedGrey,
      ),
    );
  }

  Widget _captionField() {
    final int count = _captionController.text.length;

    return CustomPaint(
      painter: _DashedRRectPainter(
        color: _dashedBorder,
        radius: ScreenUtils.r(8),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(14),
          ScreenUtils.h(12),
          ScreenUtils.w(14),
          ScreenUtils.h(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              controller: _captionController,
              maxLength: CreatePostMockData.maxCaptionLength,
              maxLines: 4,
              minLines: 3,
              style: AppTypography.medium(fontSize: 14),
              cursorColor: AppColors.primaryButtonBg,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                counterText: '',
                hintText: "What's on your mind?",
                hintStyle: AppTypography.medium(
                  fontSize: 14,
                  color: AppColors.mutedGrey,
                ),
              ),
            ),
            Text(
              '$count/${CreatePostMockData.maxCaptionLength}',
              style: AppTypography.medium(
                fontSize: 11,
                color: AppColors.mutedGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF090909),
        borderRadius: HomeCard.radius,
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: <Widget>[
          _TagRow(
            icon: Icons.sell_outlined,
            title: 'Tag Office',
            subtitle: _selectedOffice?.name ?? 'Select an office',
            onTap: _openTagOffice,
          ),
          Divider(height: 1, color: AppColors.divider),
          _TagRow(
            icon: Icons.people_outline,
            title: 'Tag People',
            subtitle: _taggedPeople.isEmpty
                ? 'Add team members or agents'
                : _taggedPeople
                    .map((DirectoryAgent a) =>
                        a.fullName.trim().isEmpty ? 'Agent' : a.fullName.trim())
                    .join(', '),
            onTap: _openTagPeople,
          ),
          Divider(height: 1, color: AppColors.divider),
          _TagRow(
            icon: Icons.location_on_outlined,
            title: 'Add Location',
            subtitle: _selectedLocation == null
                ? 'Use your current location'
                : (_selectedLocation!.displaySubtitle.isNotEmpty
                      ? _selectedLocation!.displaySubtitle
                      : _selectedLocation!.label),
            onTap: _openAddLocation,
          ),
        ],
      ),
    );
  }

  Widget _postTypeSection() {
    return Container(
      padding: EdgeInsets.all(ScreenUtils.w(14)),
      decoration: BoxDecoration(
        color: const Color(0xFF090909),
        borderRadius: HomeCard.radius,
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => setState(() => _postTypeExpanded = !_postTypeExpanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.layers_outlined,
                  size: ScreenUtils.sp(18),
                  color: AppColors.primaryButtonBg,
                ),
                SizedBox(width: ScreenUtils.w(8)),
                Expanded(
                  child: Text(
                    'Post Type',
                    style: AppTypography.semiBold(fontSize: 14),
                  ),
                ),
                Text(
                  _postTypeLabel,
                  style: AppTypography.medium(
                    fontSize: 12,
                    color: AppColors.primaryButtonBg,
                  ),
                ),
                Icon(
                  _postTypeExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.primaryButtonBg,
                  size: ScreenUtils.sp(20),
                ),
              ],
            ),
          ),
          if (_postTypeExpanded) ...<Widget>[
            SizedBox(height: ScreenUtils.h(14)),
            Row(
              children: CreatePostMockData.postTypes.map((entry) {
                final CreatePostType type = entry.$1;
                final CreatePostOption option = entry.$2;
                final bool selected = type == _postType;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(4)),
                    child: _SelectTile(
                      icon: option.icon,
                      label: option.label,
                      selected: selected,
                      onTap: () => setState(() => _postType = type),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _shareToSection() {
    return Container(
      padding: EdgeInsets.all(ScreenUtils.w(14)),
      decoration: BoxDecoration(
        color: const Color(0xFF090909),
        borderRadius: HomeCard.radius,
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () => setState(() => _shareToExpanded = !_shareToExpanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.share_outlined,
                  size: ScreenUtils.sp(18),
                  color: AppColors.primaryButtonBg,
                ),
                SizedBox(width: ScreenUtils.w(8)),
                Expanded(
                  child: Text(
                    'Share To',
                    style: AppTypography.semiBold(fontSize: 14),
                  ),
                ),
                Text(
                  _shareToLabel,
                  style: AppTypography.medium(
                    fontSize: 12,
                    color: AppColors.primaryButtonBg,
                  ),
                ),
                Icon(
                  _shareToExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.primaryButtonBg,
                  size: ScreenUtils.sp(20),
                ),
              ],
            ),
          ),
          if (_shareToExpanded) ...<Widget>[
            SizedBox(height: ScreenUtils.h(6)),
            Text(
              'Choose where to share this post',
              style: AppTypography.medium(
                fontSize: 11,
                color: AppColors.mutedGrey,
              ),
            ),
            SizedBox(height: ScreenUtils.h(14)),
            Row(
              children: CreatePostMockData.shareToOptions.map((entry) {
                final CreateShareTo value = entry.$1;
                final CreatePostOption option = entry.$2;
                final bool selected = value == _shareTo;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(4)),
                    child: _SelectTile(
                      icon: option.icon,
                      label: option.label,
                      subtitle: option.subtitle,
                      selected: selected,
                      showCheck: selected,
                      onTap: () => setState(() => _shareTo = value),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String get _postTypeLabel {
    return CreatePostMockData.postTypes
        .firstWhere((entry) => entry.$1 == _postType)
        .$2
        .label;
  }

  String get _shareToLabel {
    return CreatePostMockData.shareToOptions
        .firstWhere((entry) => entry.$1 == _shareTo)
        .$2
        .label;
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtils.w(14),
          vertical: ScreenUtils.h(14),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: ScreenUtils.sp(20),
              color: AppColors.primaryButtonBg,
            ),
            SizedBox(width: ScreenUtils.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: AppTypography.semiBold(fontSize: 14)),
                  SizedBox(height: ScreenUtils.h(4)),
                  Text(
                    subtitle,
                    style: AppTypography.medium(
                      fontSize: 11,
                      color: AppColors.mutedGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: ScreenUtils.sp(20),
              color: AppColors.primaryButtonBg,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.showCheck = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool selected;
  final bool showCheck;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: ScreenUtils.h(12),
            horizontal: ScreenUtils.w(4),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
            border: Border.all(
              color: selected ? AppColors.primaryButtonBg : AppColors.divider,
            ),
          ),
          child: Column(
            children: <Widget>[
              if (showCheck)
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.check_circle,
                    size: ScreenUtils.sp(14),
                    color: AppColors.primaryButtonBg,
                  ),
                )
              else
                SizedBox(height: ScreenUtils.h(14)),
              Icon(
                icon,
                size: ScreenUtils.sp(20),
                color: selected
                    ? AppColors.primaryButtonBg
                    : AppColors.mutedGrey,
              ),
              SizedBox(height: ScreenUtils.h(8)),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.semiBold(
                  fontSize: 11,
                  color: selected ? AppColors.white : AppColors.mutedGrey,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                SizedBox(height: ScreenUtils.h(2)),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: AppTypography.medium(
                    fontSize: 9,
                    color: AppColors.mutedGrey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final Path path = Path()..addRRect(rrect);
    final Path dashed = _dashPath(path, dashWidth: 5, dashSpace: 4);
    canvas.drawPath(dashed, paint);
  }

  Path _dashPath(
    Path source, {
    required double dashWidth,
    required double dashSpace,
  }) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dest.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

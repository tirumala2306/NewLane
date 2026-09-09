import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/content_generator/data/content_generator_mock.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/features/content_generator/widgets/content_generator_ui.dart';
import 'package:newlane/features/home/data/mock/home_mock_data.dart';
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/custom_text_field.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

class ContentGeneratorDetailsScreen extends StatefulWidget {
  const ContentGeneratorDetailsScreen({
    super.key,
    this.draft = const ContentGeneratorDraft(),
  });

  final ContentGeneratorDraft draft;

  @override
  State<ContentGeneratorDetailsScreen> createState() =>
      _ContentGeneratorDetailsScreenState();
}

class _ContentGeneratorDetailsScreenState
    extends State<ContentGeneratorDetailsScreen> {
  static const int _maxPhotos = 8;
  static const int _maxNotes = 300;

  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _addressController;
  late final TextEditingController _priceController;
  late final TextEditingController _bedsController;
  late final TextEditingController _bathsController;
  late final TextEditingController _sqftController;
  late final TextEditingController _notesController;
  late final TextEditingController _featureController;

  late List<String> _photos;
  late List<String> _features;
  late String _postType;
  late String _tone;

  @override
  void initState() {
    super.initState();
    final ContentGeneratorDraft draft = widget.draft;
    _photos = List<String>.from(draft.photoPaths);
    _features = List<String>.from(
      draft.keyFeatures.isEmpty
          ? ContentGeneratorMock.suggestedFeatures
          : draft.keyFeatures,
    );
    _postType = draft.postType;
    _tone = draft.tone;
    _addressController = TextEditingController(text: draft.propertyAddress);
    _priceController = TextEditingController(text: draft.price);
    _bedsController = TextEditingController(text: draft.bedrooms);
    _bathsController = TextEditingController(text: draft.bathrooms);
    _sqftController = TextEditingController(text: draft.sqft);
    _notesController = TextEditingController(text: draft.additionalNotes);
    _featureController = TextEditingController();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _priceController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();
    _sqftController.dispose();
    _notesController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  ContentGeneratorDraft get _currentDraft => ContentGeneratorDraft(
    photoPaths: _photos,
    propertyAddress: _addressController.text,
    price: _priceController.text,
    bedrooms: _bedsController.text,
    bathrooms: _bathsController.text,
    sqft: _sqftController.text,
    postType: _postType,
    tone: _tone,
    keyFeatures: _features,
    additionalNotes: _notesController.text,
  );

  Future<void> _pickPhotos() async {
    final int remaining = _maxPhotos - _photos.length;
    if (remaining <= 0) {
      AppSnackBar.showInfo(
        context,
        title: 'Photos',
        message: 'You can add up to $_maxPhotos photos.',
      );
      return;
    }
    final List<XFile> picked = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (picked.isEmpty || !mounted) return;
    setState(() {
      _photos = <String>[
        ..._photos,
        ...picked.take(remaining).map((XFile f) => f.path),
      ];
    });
  }

  void _removePhoto(String path) {
    setState(() => _photos = _photos.where((String p) => p != path).toList());
  }

  Future<void> _pickPostType() async {
    final String? selected = await showContentOptionsSheet(
      context: context,
      title: 'Post Type',
      options: ContentGeneratorMock.postTypes,
      selected: _postType,
    );
    if (selected != null) setState(() => _postType = selected);
  }

  Future<void> _pickTone() async {
    final String? selected = await showContentOptionsSheet(
      context: context,
      title: 'Tone',
      options: ContentGeneratorMock.tones,
      selected: _tone,
    );
    if (selected != null) setState(() => _tone = selected);
  }

  Future<void> _addFeature() async {
    final String? value = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardSurface,
          title: Text(
            'Add Feature',
            style: AppTypography.semiBold(fontSize: 16),
          ),
          content: CustomTextField(
            controller: _featureController,
            isExpanded: true,
            hintText: 'e.g. Ocean View',
            textCapitalization: TextCapitalization.words,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTypography.medium(color: AppColors.mutedGrey),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, _featureController.text.trim()),
              child: Text(
                'Add',
                style: AppTypography.semiBold(
                  color: AppColors.primaryButtonBg,
                ),
              ),
            ),
          ],
        );
      },
    );
    _featureController.clear();
    if (value == null || value.isEmpty) return;
    if (_features.contains(value)) return;
    setState(() => _features = <String>[..._features, value]);
  }

  void _generate() {
    if (_addressController.text.trim().isEmpty) {
      AppSnackBar.showInfo(
        context,
        title: 'Address required',
        message: 'Enter a property address to generate content.',
      );
      return;
    }
    context.push(
      AppRoutes.contentGeneratorGenerating,
      extra: _currentDraft,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProfileState profileState = context.watch<ProfileBloc>().state;
    final String officeName = switch (profileState) {
      ProfileLoaded(:final profile) when profile.officeName.trim().isNotEmpty =>
        profile.officeName.trim().toUpperCase(),
      _ => HomeMockData.officeName.toUpperCase(),
    };

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: contentGeneratorAppBar(
        context,
        title: 'CONTENT GENERATOR',
        description: officeName,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              ScreenUtils.w(16),
              ScreenUtils.h(8),
              ScreenUtils.w(16),
              0,
            ),
            child: const ContentPhaseTabs(activeIndex: 0),
          ),
          SizedBox(height: ScreenUtils.h(16)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
              children: <Widget>[
                const ContentFieldLabel('Listing Photos'),
                SizedBox(height: ScreenUtils.h(10)),
                _photosRow(),
                SizedBox(height: ScreenUtils.h(18)),
                const ContentFieldLabel('Property Address', required: true),
                SizedBox(height: ScreenUtils.h(8)),
                CustomTextField(
                  controller: _addressController,
                  isExpanded: true,
                  hintText: '171 Ocean Drive, Miami, FL 33139',
                  prefixIcon: Icon(
                    Icons.home_outlined,
                    size: ScreenUtils.sp(18),
                    color: AppColors.mutedGrey,
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                SizedBox(height: ScreenUtils.h(14)),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _miniField(
                        label: 'Price',
                        controller: _priceController,
                        hint: '7900000',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: ScreenUtils.w(8)),
                    Expanded(
                      child: _miniField(
                        label: 'Beds',
                        controller: _bedsController,
                        hint: '5',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: ScreenUtils.w(8)),
                    Expanded(
                      child: _miniField(
                        label: 'Baths',
                        controller: _bathsController,
                        hint: '5.5',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtils.w(8)),
                    Expanded(
                      child: _miniField(
                        label: 'Sqft',
                        controller: _sqftController,
                        hint: '4800',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtils.h(16)),
                const ContentFieldLabel('Post Type'),
                SizedBox(height: ScreenUtils.h(8)),
                ContentDropdownField(value: _postType, onTap: _pickPostType),
                SizedBox(height: ScreenUtils.h(16)),
                const ContentFieldLabel('Tone'),
                SizedBox(height: ScreenUtils.h(8)),
                ContentDropdownField(value: _tone, onTap: _pickTone),
                SizedBox(height: ScreenUtils.h(16)),
                const ContentFieldLabel('Key Features (Optional)'),
                SizedBox(height: ScreenUtils.h(10)),
                Wrap(
                  spacing: ScreenUtils.w(8),
                  runSpacing: ScreenUtils.h(8),
                  children: <Widget>[
                    ..._features.map(_featureChip),
                    _addFeatureChip(),
                  ],
                ),
                SizedBox(height: ScreenUtils.h(16)),
                const ContentFieldLabel('Additional Notes (Optional)'),
                SizedBox(height: ScreenUtils.h(8)),
                ContentTextArea(
                  controller: _notesController,
                  hintText:
                      'Highlight the modern design, waterfront view, open layout...',
                  maxLength: _maxNotes,
                  minHeight: 110,
                ),
                SizedBox(height: ScreenUtils.h(20)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(ScreenUtils.w(14)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
                    border: Border.all(
                      color: AppColors.primaryButtonBg.withValues(alpha: 0.45),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.auto_awesome,
                        color: AppColors.primaryButtonBg,
                        size: ScreenUtils.sp(20),
                      ),
                      SizedBox(width: ScreenUtils.w(10)),
                      Expanded(
                        child: Text(
                          'Generate engaging content for your listing.',
                          style: AppTypography.regular(
                            fontSize: 12,
                            color: AppColors.mutedGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ScreenUtils.h(24)),
              ],
            ),
          ),
          ContentBottomBar(
            child: UnifiedButton(
              label: 'Generate Content',
              onPressed: _generate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTypography.medium(fontSize: 11)),
        SizedBox(height: ScreenUtils.h(6)),
        CustomTextField(
          controller: controller,
          isExpanded: true,
          hintText: hint,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  Widget _photosRow() {
    return SizedBox(
      height: ScreenUtils.w(72),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _photos.length + 1,
        separatorBuilder: (_, _) => SizedBox(width: ScreenUtils.w(8)),
        itemBuilder: (BuildContext context, int index) {
          if (index == _photos.length) {
            return InkWell(
              onTap: _pickPhotos,
              borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
              child: Container(
                width: ScreenUtils.w(72),
                height: ScreenUtils.w(72),
                decoration: BoxDecoration(
                  color: AppColors.primaryButtonBg,
                  borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                ),
                child: Icon(
                  Icons.add,
                  color: AppColors.black,
                  size: ScreenUtils.sp(28),
                ),
              ),
            );
          }
          final String path = _photos[index];
          return Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                child: Image.file(
                  File(path),
                  width: ScreenUtils.w(72),
                  height: ScreenUtils.w(72),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: InkWell(
                  onTap: () => _removePhoto(path),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
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
    );
  }

  Widget _featureChip(String feature) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.w(10),
        vertical: ScreenUtils.h(7),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtils.r(20)),
        border: Border.all(color: AppColors.primaryButtonBg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            feature,
            style: AppTypography.medium(
              fontSize: 11,
              color: AppColors.primaryButtonBg,
            ),
          ),
          SizedBox(width: ScreenUtils.w(6)),
          InkWell(
            onTap: () {
              setState(
                () => _features =
                    _features.where((String f) => f != feature).toList(),
              );
            },
            child: Icon(
              Icons.close,
              size: ScreenUtils.sp(14),
              color: AppColors.primaryButtonBg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addFeatureChip() {
    return InkWell(
      onTap: _addFeature,
      borderRadius: BorderRadius.circular(ScreenUtils.r(20)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtils.w(12),
          vertical: ScreenUtils.h(7),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtils.r(20)),
          border: Border.all(
            color: AppColors.primaryButtonBg.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          '+ Add Feature',
          style: AppTypography.medium(
            fontSize: 11,
            color: AppColors.primaryButtonBg,
          ),
        ),
      ),
    );
  }
}

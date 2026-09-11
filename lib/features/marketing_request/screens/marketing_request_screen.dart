import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/domain/entities/agent_profile.dart';
import 'package:newlane/features/listings/domain/entities/active_listing.dart';
import 'package:newlane/features/marketing_request/bloc/create/marketing_request_bloc.dart';
import 'package:newlane/features/marketing_request/bloc/create/marketing_request_event.dart';
import 'package:newlane/features/marketing_request/bloc/create/marketing_request_state.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';
import 'package:newlane/features/marketing_request/widgets/marketing_stepper.dart';
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/custom_text_field.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

class MarketingRequestScreen extends StatefulWidget {
  const MarketingRequestScreen({super.key});

  @override
  State<MarketingRequestScreen> createState() => _MarketingRequestScreenState();
}

class _MarketingRequestScreenState extends State<MarketingRequestScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  List<MarketingListing> _myListings = <MarketingListing>[];
  bool _loadingListings = false;

  @override
  void initState() {
    super.initState();
    _loadMyListings();
  }

  Future<void> _loadMyListings() async {
    setState(() => _loadingListings = true);
    final ProfileState profileState = context.read<ProfileBloc>().state;
    final AgentProfile? profile =
        profileState is ProfileLoaded ? profileState.profile : null;
    final Result<List<ActiveListing>> result =
        await InjectionContainer.instance.fetchMyActiveListings(
      currentUserId: profile?.id ?? 0,
      currentUserName: profile?.fullName ?? '',
    );
    if (!mounted) return;
    result.when(
      ok: (List<ActiveListing> items) {
        setState(() {
          _myListings =
              items.map((ActiveListing e) => e.toMarketingListing()).toList();
          _loadingListings = false;
        });
      },
      err: (_) {
        setState(() {
          _myListings = <MarketingListing>[];
          _loadingListings = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _syncControllers(MarketingRequestState state) {
    if (_addressController.text != state.address) {
      _addressController.value = TextEditingValue(
        text: state.address,
        selection: TextSelection.collapsed(offset: state.address.length),
      );
    }
    if (_priceController.text != state.formattedPrice) {
      _priceController.value = TextEditingValue(
        text: state.formattedPrice,
        selection: TextSelection.collapsed(offset: state.formattedPrice.length),
      );
    }
    if (_notesController.text != state.notes) {
      _notesController.value = TextEditingValue(
        text: state.notes,
        selection: TextSelection.collapsed(offset: state.notes.length),
      );
    }
  }

  Future<void> _pickMedia(MarketingRequestState state) async {
    final int remaining = MarketingRequestState.maxMedia - state.mediaPaths.length;
    if (remaining <= 0) {
      AppSnackBar.showInfo(
        context,
        title: 'Upload limit',
        message: 'You can upload up to ${MarketingRequestState.maxMedia} files.',
      );
      return;
    }

    final List<XFile> picked = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (picked.isEmpty || !mounted) return;
    context.read<MarketingRequestBloc>().add(
      MarketingRequestMediaAdded(
        picked.take(remaining).map((XFile file) => file.path).toList(),
      ),
    );
  }

  Future<void> _pickType(MarketingRequestState state) async {
    final MarketingRequestType? selected =
        await showModalBottomSheet<MarketingRequestType>(
          context: context,
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ScreenUtils.r(16)),
            ),
          ),
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: MarketingRequestType.values
                    .map(
                      (MarketingRequestType type) => ListTile(
                        title: Text(
                          type.label,
                          style: AppTypography.medium(fontSize: 14),
                        ),
                        trailing: state.requestType == type
                            ? const Icon(
                                Icons.check,
                                color: AppColors.primaryButtonBg,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, type),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        );
    if (selected == null || !mounted) return;
    context.read<MarketingRequestBloc>().add(
      MarketingRequestTypeSelected(selected),
    );
  }

  Future<void> _pickListing() async {
    if (_loadingListings) {
      await _loadMyListings();
    }
    if (!mounted) return;

    if (_myListings.isEmpty) {
      AppSnackBar.showInfo(
        context,
        title: 'No listings yet',
        message:
            'Create a post with type Listing first — those appear here to select.',
      );
      return;
    }

    final MarketingListing? selected =
        await showModalBottomSheet<MarketingListing>(
          context: context,
          backgroundColor: AppColors.cardSurface,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ScreenUtils.r(16)),
            ),
          ),
          builder: (BuildContext context) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  ScreenUtils.w(16),
                  ScreenUtils.h(12),
                  ScreenUtils.w(16),
                  ScreenUtils.h(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Select Project / Listing',
                      style: AppTypography.semiBold(fontSize: 16),
                    ),
                    SizedBox(height: ScreenUtils.h(12)),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _myListings.length,
                        itemBuilder: (BuildContext context, int index) {
                          final MarketingListing listing = _myListings[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(ScreenUtils.r(6)),
                              child: listing.imageUrl.isEmpty
                                  ? Container(
                                      width: ScreenUtils.w(48),
                                      height: ScreenUtils.w(48),
                                      color: AppColors.black,
                                      child: Icon(
                                        Icons.home_outlined,
                                        color: AppColors.primaryButtonBg,
                                        size: ScreenUtils.sp(20),
                                      ),
                                    )
                                  : Image.network(
                                      listing.imageUrl,
                                      width: ScreenUtils.w(48),
                                      height: ScreenUtils.w(48),
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        BuildContext context,
                                        Object error,
                                        StackTrace? stack,
                                      ) {
                                        return Container(
                                          width: ScreenUtils.w(48),
                                          height: ScreenUtils.w(48),
                                          color: AppColors.black,
                                        );
                                      },
                                    ),
                            ),
                            title: Text(
                              listing.address,
                              style: AppTypography.medium(fontSize: 13),
                            ),
                            subtitle: Text(
                              [
                                if (listing.priceLabel.isNotEmpty)
                                  listing.priceLabel,
                                listing.title,
                              ].join(' · '),
                              style: AppTypography.regular(
                                fontSize: 11,
                                color: AppColors.mutedGrey,
                              ),
                            ),
                            onTap: () => Navigator.pop(context, listing),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
    if (selected == null || !mounted) return;
    context.read<MarketingRequestBloc>().add(
      MarketingRequestListingSelected(selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProfileState profileState = context.watch<ProfileBloc>().state;
    final String officeName = switch (profileState) {
      ProfileLoaded(:final profile) when profile.officeName.trim().isNotEmpty =>
        profile.officeName.trim().toUpperCase(),
      _ => '',
    };

    return BlocConsumer<MarketingRequestBloc, MarketingRequestState>(
      listenWhen: (MarketingRequestState previous, MarketingRequestState current) {
        return previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage ||
            previous.listing != current.listing;
      },
      listener: (BuildContext context, MarketingRequestState state) {
        if (state.listing != null) {
          _syncControllers(state);
        }
        if (state.errorMessage != null &&
            state.errorMessage!.isNotEmpty &&
            !state.submitting) {
          AppSnackBar.showError(
            context,
            title: 'Marketing Request',
            message: state.errorMessage!,
          );
        }
        if (state.successMessage != null) {
          AppSnackBar.showSuccess(
            context,
            title: 'Submitted',
            message: state.successMessage!,
          );
          context.pushReplacement(AppRoutes.myRequests);
        }
      },
      builder: (BuildContext context, MarketingRequestState state) {
        return Scaffold(
          backgroundColor: AppColors.black,
          appBar: NewLaneAppBar(
            prefixIcon: Icons.arrow_back_ios_new,
            onPrefixPressed: () {
              if (state.step > 0) {
                context.read<MarketingRequestBloc>().add(
                  const MarketingRequestBackPressed(),
                );
                return;
              }
              context.pop();
            },
            title: 'MARKETING REQUEST',
            titleFontSize: 16,
            description: officeName.isEmpty ? null : officeName,
            descriptionFontSize: 10,
            height: ScreenUtils.h(56),
          ),
          body: Column(
            children: <Widget>[
              SizedBox(height: ScreenUtils.h(8)),
              MarketingStepper(currentStep: state.step),
              SizedBox(height: ScreenUtils.h(16)),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
                  children: <Widget>[
                    ..._stepBody(state),
                    SizedBox(height: ScreenUtils.h(24)),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    ScreenUtils.w(16),
                    ScreenUtils.h(8),
                    ScreenUtils.w(16),
                    ScreenUtils.h(12),
                  ),
                  child: UnifiedButton(
                    label: state.nextLabel,
                    isLoading: state.submitting,
                    onPressed: state.submitting
                        ? null
                        : () => context.read<MarketingRequestBloc>().add(
                            const MarketingRequestNextPressed(),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _stepBody(MarketingRequestState state) {
    return switch (state.step) {
      0 => _typeStep(state),
      1 => _listingStep(state),
      2 => _detailsStep(state),
      _ => _reviewStep(state),
    };
  }

  List<Widget> _typeStep(MarketingRequestState state) {
    return <Widget>[
      _label('Request Type'),
      SizedBox(height: ScreenUtils.h(8)),
      _selectorField(
        value: state.requestType?.label ?? 'Select request type',
        placeholder: state.requestType == null,
        onTap: () => _pickType(state),
      ),
    ];
  }

  List<Widget> _listingStep(MarketingRequestState state) {
    return <Widget>[
      _label('Select Project / Listing'),
      SizedBox(height: ScreenUtils.h(8)),
      _listingPicker(state),
      SizedBox(height: ScreenUtils.h(16)),
      _label('Listing Address'),
      SizedBox(height: ScreenUtils.h(8)),
      CustomTextField(
        controller: _addressController,
        isExpanded: true,
        hintText: 'Enter listing address',
        onChanged: (String value) => context.read<MarketingRequestBloc>().add(
          MarketingRequestAddressChanged(value),
        ),
      ),
      SizedBox(height: ScreenUtils.h(16)),
      _label('Listing Price'),
      SizedBox(height: ScreenUtils.h(8)),
      CustomTextField(
        controller: _priceController,
        isExpanded: true,
        hintText: '\$0',
        keyboardType: TextInputType.number,
        onChanged: (String value) => context.read<MarketingRequestBloc>().add(
          MarketingRequestPriceChanged(value),
        ),
      ),
      if (state.listing != null) ...<Widget>[
        SizedBox(height: ScreenUtils.h(16)),
        _label('Listing Info'),
        SizedBox(height: ScreenUtils.h(8)),
        _listingInfo(state),
      ],
    ];
  }

  List<Widget> _detailsStep(MarketingRequestState state) {
    return <Widget>[
      _label('Upload Photos / Videos'),
      SizedBox(height: ScreenUtils.h(8)),
      _mediaRow(state),
      SizedBox(height: ScreenUtils.h(6)),
      Text(
        'You can upload up to ${MarketingRequestState.maxMedia} files  ${state.mediaPaths.length}/${MarketingRequestState.maxMedia}',
        style: AppTypography.regular(fontSize: 11, color: AppColors.mutedGrey),
      ),
      SizedBox(height: ScreenUtils.h(16)),
      _label('Notes / Instructions'),
      SizedBox(height: ScreenUtils.h(8)),
      _notesField(state),
    ];
  }

  List<Widget> _reviewStep(MarketingRequestState state) {
    return <Widget>[
      _reviewRow('Request Type', state.requestType?.label ?? '—'),
      _reviewRow('Listing', state.address),
      if (state.formattedPrice.isNotEmpty)
        _reviewRow('Price', state.formattedPrice),
      if (state.listing?.title.isNotEmpty == true)
        _reviewRow('Property', state.listing!.title),
      _reviewRow(
        'Files',
        '${state.mediaPaths.length} uploaded',
      ),
      _reviewRow(
        'Notes',
        state.notes.trim().isEmpty ? '—' : state.notes.trim(),
      ),
    ];
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtils.h(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: AppTypography.medium(fontSize: 11, color: AppColors.mutedGrey),
          ),
          SizedBox(height: ScreenUtils.h(6)),
          Text(value, style: AppTypography.semiBold(fontSize: 14, height: 1.3)),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: AppTypography.medium(fontSize: 12));
  }

  Widget _selectorField({
    required String value,
    required VoidCallback onTap,
    bool placeholder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: ScreenUtils.h(48),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(14)),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                value,
                style: AppTypography.regular(
                  fontSize: 14,
                  color: placeholder
                      ? AppColors.white.withValues(alpha: 0.45)
                      : AppColors.white,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primaryButtonBg,
              size: ScreenUtils.sp(22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listingPicker(MarketingRequestState state) {
    final MarketingListing? listing = state.listing;
    return GestureDetector(
      onTap: _pickListing,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(ScreenUtils.w(12)),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: listing == null
            ? Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Select a listing',
                      style: AppTypography.regular(
                        fontSize: 14,
                        color: AppColors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primaryButtonBg,
                    size: ScreenUtils.sp(22),
                  ),
                ],
              )
            : Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(ScreenUtils.r(6)),
                    child: Image.network(
                      listing.imageUrl,
                      width: ScreenUtils.w(56),
                      height: ScreenUtils.w(56),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (BuildContext context, Object error, StackTrace? stack) {
                        return Container(
                          width: ScreenUtils.w(56),
                          height: ScreenUtils.w(56),
                          color: AppColors.cardSurface,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: ScreenUtils.w(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          listing.address,
                          style: AppTypography.semiBold(fontSize: 13, height: 1.3),
                        ),
                        SizedBox(height: ScreenUtils.h(4)),
                        Text(
                          listing.priceLabel,
                          style: AppTypography.medium(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtils.w(8),
                      vertical: ScreenUtils.h(4),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22AF4D).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(ScreenUtils.r(4)),
                    ),
                    child: Text(
                      listing.status,
                      style: AppTypography.medium(
                        fontSize: 10,
                        color: const Color(0xFF22AF4D),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _listingInfo(MarketingRequestState state) {
    final MarketingListing listing = state.listing!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenUtils.w(12)),
      decoration: BoxDecoration(
        color: const Color(0xFF090909),
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        border: Border.all(
          color: AppColors.primaryButtonBg.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: <Widget>[
          _infoLine(Icons.place_outlined, listing.address),
          SizedBox(height: ScreenUtils.h(8)),
          _infoLine(Icons.attach_money, listing.priceLabel),
          SizedBox(height: ScreenUtils.h(8)),
          _infoLine(Icons.home_outlined, listing.title),
        ],
      ),
    );
  }

  Widget _infoLine(IconData icon, String text) {
    return Row(
      children: <Widget>[
        Icon(icon, size: ScreenUtils.sp(16), color: AppColors.primaryButtonBg),
        SizedBox(width: ScreenUtils.w(8)),
        Expanded(
          child: Text(
            text,
            style: AppTypography.regular(fontSize: 12, height: 1.3),
          ),
        ),
      ],
    );
  }

  Widget _mediaRow(MarketingRequestState state) {
    final bool canAdd = state.mediaPaths.length < MarketingRequestState.maxMedia;
    if (state.mediaPaths.isEmpty) {
      return GestureDetector(
        onTap: () => _pickMedia(state),
        child: Container(
          width: double.infinity,
          height: ScreenUtils.h(96),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
            border: Border.all(color: AppColors.primaryButtonBg),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add,
                color: AppColors.primaryButtonBg,
                size: ScreenUtils.sp(24),
              ),
              SizedBox(height: ScreenUtils.h(4)),
              Text(
                'Add photos',
                style: AppTypography.medium(
                  fontSize: 12,
                  color: AppColors.primaryButtonBg,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: ScreenUtils.w(72),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.mediaPaths.length + (canAdd ? 1 : 0),
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(width: ScreenUtils.w(8)),
        itemBuilder: (BuildContext context, int index) {
          if (canAdd && index == state.mediaPaths.length) {
            return GestureDetector(
              onTap: () => _pickMedia(state),
              child: Container(
                width: ScreenUtils.w(72),
                height: ScreenUtils.w(72),
                decoration: BoxDecoration(
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
          final String path = state.mediaPaths[index];
          return Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                child: Image.file(
                  File(path),
                  width: ScreenUtils.w(72),
                  height: ScreenUtils.w(72),
                  fit: BoxFit.cover,
                  errorBuilder:
                      (BuildContext context, Object error, StackTrace? stack) {
                    return Container(
                      width: ScreenUtils.w(72),
                      height: ScreenUtils.w(72),
                      color: AppColors.cardSurface,
                    );
                  },
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => context.read<MarketingRequestBloc>().add(
                    MarketingRequestMediaRemoved(path),
                  ),
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
    );
  }

  Widget _notesField(MarketingRequestState state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        ScreenUtils.w(12),
        ScreenUtils.h(10),
        ScreenUtils.w(12),
        ScreenUtils.h(8),
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          TextField(
            controller: _notesController,
            maxLines: 4,
            minLines: 3,
            maxLength: MarketingRequestState.maxNotes,
            style: AppTypography.regular(fontSize: 14, height: 1.3),
            cursorColor: AppColors.primaryButtonBg,
            onChanged: (String value) => context.read<MarketingRequestBloc>().add(
              MarketingRequestNotesChanged(value),
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              counterText: '',
              hintText: 'Please highlight the waterfront view…',
              hintStyle: AppTypography.regular(
                fontSize: 14,
                color: AppColors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
          Text(
            '${state.notes.length}/${MarketingRequestState.maxNotes}',
            style: AppTypography.regular(fontSize: 11, color: AppColors.mutedGrey),
          ),
        ],
      ),
    );
  }
}

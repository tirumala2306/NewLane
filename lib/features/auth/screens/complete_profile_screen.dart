import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newlane/core/config/app_environment.dart';
import 'package:newlane/core/constants/app_constants.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/auth/bloc/complete_profile/complete_profile_bloc.dart';
import 'package:newlane/features/auth/bloc/complete_profile/complete_profile_event.dart';
import 'package:newlane/features/auth/bloc/complete_profile/complete_profile_state.dart';
import 'package:newlane/features/auth/domain/entities/agent_profile.dart';
import 'package:newlane/features/auth/widgets/auth_avatar_picker.dart';
import 'package:newlane/features/auth/widgets/auth_form_fields.dart';
import 'package:newlane/features/auth/widgets/auth_header.dart';
import 'package:newlane/features/auth/widgets/auth_scaffold.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/app_svg.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

/// Onboarding complete-profile, or edit-from-More when [isEditMode] is true.
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key, this.isEditMode = false});

  final bool isEditMode;

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _jobTitleController;
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _avatarFile;
  String? _avatarUrl;
  List<String> _specialties = <String>[];
  bool _didPrefillFromApi = false;

  @override
  void initState() {
    super.initState();
    final storage = InjectionContainer.instance.appStorage;
    _nameController = TextEditingController(
      text: storage.readString(AppConstants.accessRequestFullNameKey) ?? '',
    );
    _phoneController = TextEditingController(
      text: storage.readString(AppConstants.accessRequestPhoneKey) ?? '',
    );
    _jobTitleController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  String? _resolveAvatarUrl(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final String base = AppEnvironment.baseUrl.replaceAll(RegExp(r'/$'), '');
    final String path = value.startsWith('/') ? value : '/$value';
    return '$base$path';
  }

  void _applyProfile(AgentProfile profile) {
    if (_didPrefillFromApi) return;
    _didPrefillFromApi = true;

    if (profile.fullName.trim().isNotEmpty) {
      _nameController.text = profile.fullName;
    }
    if (profile.phone.trim().isNotEmpty) {
      _phoneController.text = profile.phone;
    }
    if (profile.bio.trim().isNotEmpty) {
      _bioController.text = profile.bio;
    }
    if (profile.instagram.trim().isNotEmpty) {
      _instagramController.text = profile.instagram;
    }
    if (profile.website.trim().isNotEmpty) {
      _websiteController.text = profile.website;
    }
    if (profile.jobTitle.trim().isNotEmpty) {
      _jobTitleController.text = profile.jobTitle.trim();
    }
    if (profile.specialties.isNotEmpty) {
      _specialties = List<String>.from(profile.specialties);
    }
    _avatarUrl = _resolveAvatarUrl(profile.avatar);

    setState(() {});
  }

  Future<void> _pickAvatar() async {
    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _avatarFile = File(picked.path);
    });
  }

  void _onSave(BuildContext context) {
    context.read<CompleteProfileBloc>().add(
      CompleteProfileSubmitted(
        fullName: _nameController.text,
        phone: _phoneController.text,
        jobTitle: _jobTitleController.text,
        bio: _bioController.text,
        instagram: _instagramController.text,
        website: _websiteController.text,
        specialties: _specialties,
        avatarFilePath: _avatarFile?.path,
      ),
    );
  }

  void _onBack(BuildContext context) {
    if (widget.isEditMode) {
      context.pop();
      return;
    }
    context.go(AppRoutes.signIn);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompleteProfileBloc, CompleteProfileState>(
      listener: (BuildContext context, CompleteProfileState state) {
        if (state is CompleteProfileReady && state.profile != null) {
          _applyProfile(state.profile!);
          return;
        }

        if (state is CompleteProfileSuccess) {
          if (widget.isEditMode) {
            AppSnackBar.showSuccess(
              context,
              title: 'Profile Updated',
              message: state.result.message.isNotEmpty
                  ? state.result.message
                  : 'Your profile has been saved.',
            );
            context.pop(true);
            return;
          }
          InjectionContainer.instance.appStorage.setOnboardingCompleted();
          context.go(AppRoutes.home);
          return;
        }

        if (state is CompleteProfileFailure) {
          if (state.isValidation) {
            AppSnackBar.showInfo(
              context,
              title: 'Please Fill Required Fields',
              message: state.message,
            );
          } else {
            AppSnackBar.showError(
              context,
              title: 'Could Not Save Profile',
              message: state.message,
            );
          }
        }
      },
      builder: (BuildContext context, CompleteProfileState state) {
        final bool isLoading = state is CompleteProfileLoading;

        return AuthScaffold(
          onBack: () => _onBack(context),
          footerTopGap: ScreenUtils.h(50),
          footer: UnifiedButton(
            label: widget.isEditMode ? 'Save Changes' : 'Save & Continue',
            isLoading: isLoading,
            onPressed: isLoading ? null : () => _onSave(context),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AuthHeader(
                title: widget.isEditMode
                    ? 'Edit Profile'
                    : 'Complete Your Profile',
                titleFontSize: 30,
                subtitleFontSize: 16,
                subtitles: <String>[
                  widget.isEditMode
                      ? 'Update your photo and profile details.'
                      : 'Tell us a bit about yourself.',
                ],
              ),
              SizedBox(height: ScreenUtils.h(32)),
              AuthAvatarPicker(
                imageFile: _avatarFile,
                networkUrl: _avatarUrl,
                onTap: isLoading ? null : _pickAvatar,
              ),
              SizedBox(height: ScreenUtils.h(32)),
              AuthLabeledField(
                label: 'Full Name',
                child: AuthInput(
                  controller: _nameController,
                  hintText: 'Enter Name',
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              SizedBox(height: ScreenUtils.h(20)),
              AuthLabeledField(
                label: 'Phone Number',
                child: AuthInput(
                  controller: _phoneController,
                  hintText: '(305) 123-4567',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(height: ScreenUtils.h(20)),
              AuthLabeledField(
                label: 'Job Title',
                child: AuthInput(
                  controller: _jobTitleController,
                  hintText: 'Assigned by your office',
                  readOnly: true,
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(height: ScreenUtils.h(20)),
              AuthSpecialtiesField(
                selected: _specialties,
                onChanged: (List<String> value) {
                  setState(() => _specialties = value);
                },
              ),
              SizedBox(height: ScreenUtils.h(20)),
              AuthBioField(controller: _bioController),
              SizedBox(height: ScreenUtils.h(20)),
              AuthLabeledField(
                label: 'Website (Optional)',
                child: AuthInput(
                  controller: _websiteController,
                  hintText: 'www.yourwebsite.com',
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icon(
                    Icons.language,
                    color: AppColors.white.withValues(alpha: 0.8),
                    size: ScreenUtils.sp(20),
                  ),
                ),
              ),
              SizedBox(height: ScreenUtils.h(20)),
              AuthLabeledField(
                label: 'Instagram (Optional)',
                child: AuthInput(
                  controller: _instagramController,
                  hintText: 'Enter Instagram Username',
                  textInputAction: TextInputAction.done,
                  prefixIcon: AppSvg(
                    AssetConstants.instagramIcon,
                    width: ScreenUtils.sp(20),
                    height: ScreenUtils.sp(20),
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

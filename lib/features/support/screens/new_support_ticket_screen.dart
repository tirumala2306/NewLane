import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';
import 'package:newlane/features/support/domain/usecases/support_usecases.dart';
import 'package:newlane/features/support/widgets/support_form_widgets.dart';
import 'package:newlane/features/support/widgets/support_ticket_widgets.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/custom_text_field.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

class NewSupportTicketScreen extends StatefulWidget {
  const NewSupportTicketScreen({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  State<NewSupportTicketScreen> createState() => _NewSupportTicketScreenState();
}

class _NewSupportTicketScreenState extends State<NewSupportTicketScreen> {
  late final TextEditingController _subjectController;
  late final TextEditingController _descriptionController;
  late String _category;
  final List<SupportAttachment> _attachments = <SupportAttachment>[];
  final ImagePicker _picker = ImagePicker();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController();
    _descriptionController = TextEditingController();
    _category = widget.initialCategory?.trim().isNotEmpty == true
        ? widget.initialCategory!
        : 'Ticket Support';
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final String? selected = await showSupportOptionsSheet(
      context: context,
      title: 'Support Category',
      options: SupportMockData.categoryOptions,
      selected: _category,
    );
    if (selected != null) {
      setState(() => _category = selected);
    }
  }

  Future<void> _pickAttachment() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return;
    }
    final int bytes = await file.length();
    final String sizeLabel = bytes >= 1024 * 1024
        ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
        : '${(bytes / 1024).toStringAsFixed(0)} KB';
    setState(() {
      _attachments.add(
        SupportAttachment(
          name: file.name,
          sizeLabel: sizeLabel,
          path: file.path,
        ),
      );
    });
  }

  Future<void> _submit() async {
    if (_subjectController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      AppSnackBar.showInfo(
        context,
        title: 'Required fields',
        message: 'Please add a subject and description.',
      );
      return;
    }

    setState(() => _submitting = true);
    final Result<SupportTicket> result =
        await InjectionContainer.instance.createSupportTicket(
      CreateSupportTicketParams(
        category: _category,
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        attachmentPaths: _attachments
            .map((SupportAttachment a) => a.path ?? '')
            .where((String p) => p.isNotEmpty)
            .toList(),
      ),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    result.when(
      ok: (_) {
        AppSnackBar.showSuccess(
          context,
          title: 'Ticket submitted',
          message: 'Our team will get back to you soon.',
        );
        context.pushReplacement(AppRoutes.ticketSupport);
      },
      err: (failure) {
        AppSnackBar.showError(
          context,
          title: 'Submit failed',
          message: failure.message,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        onPrefixPressed: () => context.pop(),
        title: 'NEW SUPPORT TICKET',
        titleFontSize: 16,
        height: ScreenUtils.h(56),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(24)),
            child: Text(
              'Fill out the form below and our support team will get back to you.',
              textAlign: TextAlign.center,
              style: AppTypography.regular(
                fontSize: 12,
                height: 1.4,
                color: AppColors.mutedGrey,
              ),
            ),
          ),
          SizedBox(height: ScreenUtils.h(16)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
              children: <Widget>[
                const SupportFieldLabel('Support Category', required: true),
                SizedBox(height: ScreenUtils.h(8)),
                SupportDropdownField(
                  value: _category,
                  onTap: _pickCategory,
                  leading: Icon(
                    Icons.description_outlined,
                    color: AppColors.primaryButtonBg,
                    size: ScreenUtils.sp(18),
                  ),
                ),
                SizedBox(height: ScreenUtils.h(16)),
                const SupportFieldLabel('Subject', required: true),
                SizedBox(height: ScreenUtils.h(8)),
                CustomTextField(
                  controller: _subjectController,
                  isExpanded: true,
                  hintText: 'Enter a subject',
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: ScreenUtils.h(16)),
                const SupportFieldLabel('Description', required: true),
                SizedBox(height: ScreenUtils.h(8)),
                SupportTextArea(
                  controller: _descriptionController,
                  hintText: "Describe the issue you're experiencing...",
                  maxLength: 1000,
                  minHeight: 140,
                ),
                SizedBox(height: ScreenUtils.h(16)),
                Text(
                  'Attachment (Optional)',
                  style: AppTypography.medium(fontSize: 12),
                ),
                SizedBox(height: ScreenUtils.h(8)),
                DashedUploadBox(onTap: _pickAttachment),
                if (_attachments.isNotEmpty) ...<Widget>[
                  SizedBox(height: ScreenUtils.h(10)),
                  ..._attachments.asMap().entries.map(
                    (MapEntry<int, SupportAttachment> entry) => Padding(
                      padding: EdgeInsets.only(bottom: ScreenUtils.h(8)),
                      child: SupportAttachmentTile(
                        attachment: entry.value,
                        onRemove: () {
                          setState(() => _attachments.removeAt(entry.key));
                        },
                      ),
                    ),
                  ),
                ],
                SizedBox(height: ScreenUtils.h(16)),
                Container(
                  padding: EdgeInsets.all(ScreenUtils.w(12)),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryButtonBg,
                        size: ScreenUtils.sp(18),
                      ),
                      SizedBox(width: ScreenUtils.w(10)),
                      Expanded(
                        child: Text(
                          'We typically respond within 1 business day. Thank you for your patience!',
                          style: AppTypography.regular(
                            fontSize: 11,
                            height: 1.4,
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
                label: 'Submit Ticket',
                isLoading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketingRequestDetailScreen extends StatefulWidget {
  const MarketingRequestDetailScreen({super.key, this.initial});

  final MarketingRequest? initial;

  @override
  State<MarketingRequestDetailScreen> createState() =>
      _MarketingRequestDetailScreenState();
}

class _MarketingRequestDetailScreenState
    extends State<MarketingRequestDetailScreen> {
  late MarketingRequest _request;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _request = widget.initial ??
        const MarketingRequest(
          id: 0,
          requestType: MarketingRequestType.other,
          listingAddress: '',
          listingPrice: 0,
          notes: '',
          status: MarketingRequestStatus.submitted,
        );
    if (_request.id > 0) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final result = await InjectionContainer.instance.fetchMarketingRequestById(
      _request.id,
    );
    if (!mounted) return;
    result.when(
      ok: (MarketingRequest request) {
        setState(() {
          _request = request;
          _loading = false;
        });
      },
      err: (_) {
        setState(() => _loading = false);
      },
    );
  }

  Future<void> _openFile(MarketingRequestFile file) async {
    final Uri? uri = Uri.tryParse(file.url);
    if (uri == null) {
      AppSnackBar.showInfo(
        context,
        title: 'File',
        message: 'This file is not available yet.',
      );
      return;
    }
    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      AppSnackBar.showInfo(
        context,
        title: 'File',
        message: 'Could not open ${file.name}.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        prefixIconColor: AppColors.white,
        onPrefixPressed: () => context.pop(),
        title: 'REQUEST STATUS',
        titleFontSize: 16,
        description: _request.requestType.label.toUpperCase(),
        descriptionFontSize: 10,
        height: ScreenUtils.h(56),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(16),
          ScreenUtils.h(12),
          ScreenUtils.w(16),
          ScreenUtils.h(32),
        ),
        children: <Widget>[
          if (_loading)
            const LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.primaryButtonBg,
              backgroundColor: Colors.transparent,
            ),
          Text(
            _request.listingAddress.isEmpty
                ? 'Marketing request'
                : _request.listingAddress,
            style: AppTypography.semiBold(fontSize: 16, height: 1.3),
          ),
          if (_request.priceLabel.isNotEmpty) ...<Widget>[
            SizedBox(height: ScreenUtils.h(6)),
            Text(
              _request.priceLabel,
              style: AppTypography.medium(
                fontSize: 13,
                color: AppColors.primaryButtonBg,
              ),
            ),
          ],
          if (_request.notes.trim().isNotEmpty) ...<Widget>[
            SizedBox(height: ScreenUtils.h(12)),
            Text(
              _request.notes,
              style: AppTypography.regular(
                fontSize: 13,
                height: 1.4,
                color: AppColors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
          SizedBox(height: ScreenUtils.h(24)),
          Text('Track Status', style: AppTypography.semiBold(fontSize: 14)),
          SizedBox(height: ScreenUtils.h(12)),
          _StatusTimeline(current: _request.status),
          SizedBox(height: ScreenUtils.h(24)),
          Text('Final Files', style: AppTypography.semiBold(fontSize: 14)),
          SizedBox(height: ScreenUtils.h(12)),
          if (_request.finalFiles.isEmpty)
            Text(
              _request.status == MarketingRequestStatus.completed
                  ? 'No files were attached to this request.'
                  : 'Files will appear here when this request is completed.',
              style: AppTypography.regular(
                fontSize: 13,
                height: 1.4,
                color: AppColors.white.withValues(alpha: 0.6),
              ),
            )
          else
            ..._request.finalFiles.map(
              (MarketingRequestFile file) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.insert_drive_file_outlined,
                  color: AppColors.primaryButtonBg,
                ),
                title: Text(
                  file.name,
                  style: AppTypography.medium(fontSize: 13),
                ),
                trailing: IconButton(
                  onPressed: () => _openFile(file),
                  icon: const Icon(
                    Icons.download_rounded,
                    color: AppColors.primaryButtonBg,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.current});

  final MarketingRequestStatus current;

  @override
  Widget build(BuildContext context) {
    const List<MarketingRequestStatus> steps = MarketingRequestStatus.values;
    final int currentIndex = steps.indexOf(current);

    return Column(
      children: List<Widget>.generate(steps.length, (int index) {
        final MarketingRequestStatus step = steps[index];
        final bool reached = index <= currentIndex;
        return Padding(
          padding: EdgeInsets.only(bottom: ScreenUtils.h(14)),
          child: Row(
            children: <Widget>[
              Container(
                width: ScreenUtils.w(18),
                height: ScreenUtils.w(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reached
                      ? AppColors.primaryButtonBg
                      : AppColors.white.withValues(alpha: 0.2),
                ),
                child: reached
                    ? Icon(
                        Icons.check,
                        size: ScreenUtils.sp(12),
                        color: AppColors.black,
                      )
                    : null,
              ),
              SizedBox(width: ScreenUtils.w(10)),
              Text(
                step.label,
                style: AppTypography.medium(
                  fontSize: 13,
                  color: reached
                      ? AppColors.white
                      : AppColors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

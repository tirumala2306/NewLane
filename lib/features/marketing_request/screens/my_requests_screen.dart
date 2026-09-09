import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/data/mock/home_mock_data.dart';
import 'package:newlane/features/marketing_request/bloc/list/my_requests_bloc.dart';
import 'package:newlane/features/marketing_request/bloc/list/my_requests_event.dart';
import 'package:newlane/features/marketing_request/bloc/list/my_requests_state.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';
import 'package:newlane/features/marketing_request/widgets/my_request_card.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<MyRequestsBloc>().add(MyRequestsSearchChanged(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    final String officeName = HomeMockData.officeName.toUpperCase();

    return BlocConsumer<MyRequestsBloc, MyRequestsState>(
      listener: (BuildContext context, MyRequestsState state) {
        if (state is MyRequestsFailure && state.previous.isEmpty) {
          AppSnackBar.showError(
            context,
            title: 'My Requests',
            message: state.message,
          );
        }
      },
      builder: (BuildContext context, MyRequestsState state) {
        final List<MarketingRequest> all = switch (state) {
          MyRequestsLoaded(:final List<MarketingRequest> requests) => requests,
          MyRequestsLoading(:final List<MarketingRequest> previous) => previous,
          MyRequestsFailure(:final List<MarketingRequest> previous) => previous,
          _ => const <MarketingRequest>[],
        };
        final List<MarketingRequest> visible = switch (state) {
          MyRequestsLoaded() => state.visible,
          _ => all,
        };
        final bool isLoading = state is MyRequestsLoading;

        return Scaffold(
          backgroundColor: AppColors.black,
          appBar: NewLaneAppBar(
            prefixIcon: Icons.arrow_back_ios_new,
            prefixIconColor: AppColors.white,
            onPrefixPressed: () => context.pop(),
            title: 'MY REQUEST',
            titleFontSize: 16,
            description: officeName,
            descriptionFontSize: 10,
            height: ScreenUtils.h(56),
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(
                  ScreenUtils.w(16),
                  ScreenUtils.h(8),
                  ScreenUtils.w(16),
                  ScreenUtils.h(8),
                ),
                child: _Tabs(
                  completed: state.showCompleted,
                  onChanged: (bool completed) {
                    context.read<MyRequestsBloc>().add(
                      MyRequestsTabChanged(completed: completed),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
                child: _SearchRow(
                  controller: _searchController,
                  onChanged: _onSearch,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  ScreenUtils.w(16),
                  ScreenUtils.h(12),
                  ScreenUtils.w(16),
                  ScreenUtils.h(8),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${visible.length} ${state.showCompleted ? 'Completed' : 'Active'} Request${visible.length == 1 ? '' : 's'}',
                        style: AppTypography.medium(fontSize: 12),
                      ),
                    ),
                    Text(
                      'Sort: Newest',
                      style: AppTypography.medium(
                        fontSize: 12,
                        color: AppColors.primaryButtonBg,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.primaryButtonBg,
                  backgroundColor: Colors.transparent,
                ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryButtonBg,
                  backgroundColor: AppColors.cardSurface,
                  onRefresh: () async {
                    context.read<MyRequestsBloc>().add(
                      const MyRequestsRefreshed(),
                    );
                    await context.read<MyRequestsBloc>().stream.firstWhere(
                      (MyRequestsState s) => s is! MyRequestsLoading,
                    );
                  },
                  child: visible.isEmpty && !isLoading
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(ScreenUtils.w(16)),
                          children: <Widget>[
                            SizedBox(height: ScreenUtils.h(48)),
                            Text(
                              state.showCompleted
                                  ? 'No completed requests yet.'
                                  : 'No active requests yet.',
                              textAlign: TextAlign.center,
                              style: AppTypography.semiBold(fontSize: 16),
                            ),
                            SizedBox(height: ScreenUtils.h(16)),
                            UnifiedButton(
                              label: 'New Marketing Request',
                              onPressed: () =>
                                  context.push(AppRoutes.marketingRequest),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            ScreenUtils.w(16),
                            ScreenUtils.h(4),
                            ScreenUtils.w(16),
                            ScreenUtils.h(32),
                          ),
                          itemCount: visible.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              SizedBox(height: ScreenUtils.h(12)),
                          itemBuilder: (BuildContext context, int index) {
                            final MarketingRequest request = visible[index];
                            return MyRequestCard(
                              request: request,
                              onTap: () => context.push(
                                AppRoutes.marketingRequestDetail,
                                extra: request,
                              ),
                            );
                          },
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

class _Tabs extends StatelessWidget {
  const _Tabs({required this.completed, required this.onChanged});

  final bool completed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: _chip('Active', !completed, () => onChanged(false))),
        SizedBox(width: ScreenUtils.w(8)),
        Expanded(child: _chip('Completed', completed, () => onChanged(true))),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: ScreenUtils.h(40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
          border: Border.all(
            color: selected
                ? AppColors.primaryButtonBg
                : AppColors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.semiBold(
            fontSize: 13,
            color: selected
                ? AppColors.primaryButtonBg
                : AppColors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
      borderSide: const BorderSide(color: AppColors.glassBorder),
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: AppTypography.regular(fontSize: 13),
            cursorColor: AppColors.primaryButtonBg,
            decoration: InputDecoration(
              hintText: 'Search requests...',
              hintStyle: AppTypography.regular(
                fontSize: 13,
                color: AppColors.white.withValues(alpha: 0.4),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.white.withValues(alpha: 0.6),
                size: ScreenUtils.sp(20),
              ),
              filled: true,
              fillColor: AppColors.cardSurface,
              contentPadding: EdgeInsets.symmetric(
                vertical: ScreenUtils.h(12),
              ),
              border: border,
              enabledBorder: border,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                borderSide: const BorderSide(color: AppColors.primaryButtonBg),
              ),
            ),
          ),
        ),
        SizedBox(width: ScreenUtils.w(8)),
        Container(
          width: ScreenUtils.w(48),
          height: ScreenUtils.w(48),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Icon(
            Icons.filter_list,
            color: AppColors.primaryButtonBg,
            size: ScreenUtils.sp(20),
          ),
        ),
      ],
    );
  }
}

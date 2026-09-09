import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/directory/bloc/office_directory_bloc.dart';
import 'package:newlane/features/directory/bloc/office_directory_event.dart';
import 'package:newlane/features/directory/bloc/office_directory_state.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/directory/widgets/office_directory_invite_card.dart';
import 'package:newlane/features/directory/widgets/office_team_member_card.dart';
import 'package:newlane/features/home/data/mock/home_mock_data.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class OfficeDirectoryScreen extends StatefulWidget {
  const OfficeDirectoryScreen({super.key});

  @override
  State<OfficeDirectoryScreen> createState() => _OfficeDirectoryScreenState();
}

class _OfficeDirectoryScreenState extends State<OfficeDirectoryScreen> {
  static const List<String> _departments = <String>[
    'All',
    'Leadership',
    'Marketing',
    'Support',
    'Sales',
  ];

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<OfficeDirectoryBloc>().add(
        OfficeDirectorySearchChanged(value),
      );
    });
  }

  void _submitSearch(String value) {
    _debounce?.cancel();
    context.read<OfficeDirectoryBloc>().add(
      OfficeDirectorySearchChanged(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OfficeDirectoryBloc, OfficeDirectoryState>(
      listener: (BuildContext context, OfficeDirectoryState state) {
        if (state is OfficeDirectoryFailure && state.previous == null) {
          AppSnackBar.showError(
            context,
            title: 'Office Directory',
            message: state.message,
          );
        }
      },
      builder: (BuildContext context, OfficeDirectoryState state) {
        final DirectoryAgentsPage? page = switch (state) {
          OfficeDirectoryLoaded(:final DirectoryAgentsPage page) => page,
          OfficeDirectoryLoading(:final DirectoryAgentsPage? previous) =>
            previous,
          OfficeDirectoryFailure(:final DirectoryAgentsPage? previous) =>
            previous,
          _ => null,
        };
        final bool isLoading = state is OfficeDirectoryLoading;
        final List<DirectoryAgent> members =
            page?.agents ?? const <DirectoryAgent>[];
        final String officeName = state.officeName.trim().isNotEmpty
            ? state.officeName.trim().toUpperCase()
            : HomeMockData.officeName.toUpperCase();

        return Scaffold(
          backgroundColor: AppColors.black,
          appBar: NewLaneAppBar(
            prefixIcon: Icons.arrow_back_ios_new,
            prefixIconColor: AppColors.white,
            onPrefixPressed: () => context.pop(),
            title: 'OFFICE DIRECTORY',
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
                  ScreenUtils.h(12),
                ),
                child: _SearchRow(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: _submitSearch,
                ),
              ),
              _DepartmentChips(
                departments: _departments,
                selected: state.department,
                onSelected: (String department) {
                  context.read<OfficeDirectoryBloc>().add(
                    OfficeDirectoryDepartmentChanged(department),
                  );
                },
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
                    context.read<OfficeDirectoryBloc>().add(
                      const OfficeDirectoryRefreshed(),
                    );
                    await context.read<OfficeDirectoryBloc>().stream.firstWhere(
                      (OfficeDirectoryState s) => s is! OfficeDirectoryLoading,
                    );
                  },
                  child: members.isEmpty && !isLoading
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            ScreenUtils.w(16),
                            ScreenUtils.h(8),
                            ScreenUtils.w(16),
                            ScreenUtils.h(32),
                          ),
                          children: <Widget>[
                            SizedBox(height: ScreenUtils.h(48)),
                            Icon(
                              Icons.apartment_outlined,
                              size: ScreenUtils.sp(48),
                              color: AppColors.white.withValues(alpha: 0.4),
                            ),
                            SizedBox(height: ScreenUtils.h(12)),
                            Text(
                              'No teammates found',
                              textAlign: TextAlign.center,
                              style: AppTypography.semiBold(fontSize: 16),
                            ),
                            SizedBox(height: ScreenUtils.h(8)),
                            Text(
                              _searchController.text.trim().isEmpty
                                  ? 'No one in this department yet.'
                                  : 'No teammates match that search.',
                              textAlign: TextAlign.center,
                              style: AppTypography.regular(
                                fontSize: 13,
                                color: AppColors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            SizedBox(height: ScreenUtils.h(24)),
                            OfficeDirectoryInviteCard(
                              onInvite: () => _onInvite(context),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            ScreenUtils.w(16),
                            ScreenUtils.h(8),
                            ScreenUtils.w(16),
                            ScreenUtils.h(32),
                          ),
                          itemCount: members.length + 1,
                          separatorBuilder: (BuildContext context, int index) =>
                              SizedBox(height: ScreenUtils.h(12)),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == members.length) {
                              return OfficeDirectoryInviteCard(
                                onInvite: () => _onInvite(context),
                              );
                            }
                            return OfficeTeamMemberCard(
                              member: members[index],
                              onTap: () {
                                final DirectoryAgent member = members[index];
                                context.push(
                                  AppRoutes.directoryAgentWithId(member.id),
                                  extra: member,
                                );
                              },
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

  void _onInvite(BuildContext context) {
    AppSnackBar.showInfo(
      context,
      title: 'Invite Member',
      message: 'Ask your office admin to add this person to the directory.',
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

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
            onSubmitted: onSubmitted,
            style: AppTypography.regular(fontSize: 13),
            cursorColor: AppColors.primaryButtonBg,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by name, department or role..',
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
                horizontal: ScreenUtils.w(12),
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

class _DepartmentChips extends StatelessWidget {
  const _DepartmentChips({
    required this.departments,
    required this.selected,
    required this.onSelected,
  });

  final List<String> departments;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenUtils.h(40),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
        itemCount: departments.length,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(width: ScreenUtils.w(8)),
        itemBuilder: (BuildContext context, int index) {
          final String department = departments[index];
          final bool isSelected =
              department.toLowerCase() == selected.toLowerCase();
          return GestureDetector(
            onTap: () => onSelected(department),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtils.w(16),
                vertical: ScreenUtils.h(8),
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(ScreenUtils.r(6)),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryButtonBg
                      : AppColors.white.withValues(alpha: 0.2),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                department,
                style: AppTypography.medium(
                  fontSize: 12,
                  color: isSelected
                      ? AppColors.primaryButtonBg
                      : AppColors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

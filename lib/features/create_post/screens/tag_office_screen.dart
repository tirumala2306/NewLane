import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/create_post/bloc/tag_office/tag_office_bloc.dart';
import 'package:newlane/features/create_post/bloc/tag_office/tag_office_event.dart';
import 'package:newlane/features/create_post/bloc/tag_office/tag_office_state.dart';
import 'package:newlane/features/create_post/domain/entities/office.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';

class TagOfficeScreen extends StatefulWidget {
  const TagOfficeScreen({super.key, this.selectedOfficeId});

  final int? selectedOfficeId;

  @override
  State<TagOfficeScreen> createState() => _TagOfficeScreenState();
}

class _TagOfficeScreenState extends State<TagOfficeScreen> {
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
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<TagOfficeBloc>().add(TagOfficeSearchChanged(value));
    });
  }

  void _done(List<Office> offices, int? selectedId) {
    Office? selected;
    if (selectedId != null) {
      for (final Office office in offices) {
        if (office.id == selectedId) {
          selected = office;
          break;
        }
      }
    }
    context.pop(selected);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TagOfficeBloc, TagOfficeState>(
      listener: (BuildContext context, TagOfficeState state) {
        if (state is TagOfficeFailure && state.previousOffices == null) {
          AppSnackBar.showError(
            context,
            title: 'Offices',
            message: state.message,
          );
        }
      },
      builder: (BuildContext context, TagOfficeState state) {
        final List<Office> offices = switch (state) {
          TagOfficeLoaded(:final List<Office> offices) => offices,
          TagOfficeLoading(:final List<Office>? previousOffices) =>
            previousOffices ?? const <Office>[],
          TagOfficeFailure(:final List<Office>? previousOffices) =>
            previousOffices ?? const <Office>[],
          _ => const <Office>[],
        };
        final int? selectedId = switch (state) {
          TagOfficeLoaded(:final int? selectedOfficeId) => selectedOfficeId,
          TagOfficeLoading(:final int? selectedOfficeId) => selectedOfficeId,
          TagOfficeFailure(:final int? selectedOfficeId) => selectedOfficeId,
          _ => widget.selectedOfficeId,
        };
        final bool isLoading = state is TagOfficeLoading;

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
              'TAG OFFICE',
              style: AppTypography.semiBold(
                fontSize: 16,
                color: AppColors.primaryButtonBg,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => _done(offices, selectedId),
                child: Text(
                  'Done',
                  style: AppTypography.semiBold(
                    fontSize: 14,
                    color: AppColors.primaryButtonBg,
                  ),
                ),
              ),
            ],
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
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: AppTypography.medium(fontSize: 14),
                  cursorColor: AppColors.primaryButtonBg,
                  decoration: InputDecoration(
                    hintText: 'Search office or brokerage.',
                    hintStyle: AppTypography.medium(
                      fontSize: 14,
                      color: AppColors.mutedGrey,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primaryButtonBg,
                      size: ScreenUtils.sp(20),
                    ),
                    filled: true,
                    fillColor: AppColors.cardSurface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ScreenUtils.w(12),
                      vertical: ScreenUtils.h(12),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
                      borderSide: const BorderSide(
                        color: AppColors.primaryButtonBg,
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.primaryButtonBg,
                  backgroundColor: Colors.transparent,
                ),
              Expanded(
                child: offices.isEmpty && !isLoading
                    ? Center(
                        child: Text(
                          _searchController.text.trim().isEmpty
                              ? 'No offices available yet.'
                              : 'No offices match your search.',
                          style: AppTypography.medium(
                            fontSize: 14,
                            color: AppColors.mutedGrey,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          ScreenUtils.w(16),
                          ScreenUtils.h(8),
                          ScreenUtils.w(16),
                          ScreenUtils.h(24),
                        ),
                        itemCount: offices.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: ScreenUtils.h(8)),
                        itemBuilder: (BuildContext context, int index) {
                          final Office office = offices[index];
                          final bool selected = office.id == selectedId;
                          return _OfficeTile(
                            office: office,
                            selected: selected,
                            onTap: () {
                              context.read<TagOfficeBloc>().add(
                                TagOfficeSelected(office.id),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OfficeTile extends StatelessWidget {
  const _OfficeTile({
    required this.office,
    required this.selected,
    required this.onTap,
  });

  final Office office;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtils.w(14),
          vertical: ScreenUtils.h(14),
        ),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
          border: Border.all(
            color: selected
                ? AppColors.primaryButtonBg.withValues(alpha: 0.5)
                : AppColors.divider,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.apartment_outlined,
              color: AppColors.primaryButtonBg,
              size: ScreenUtils.sp(22),
            ),
            SizedBox(width: ScreenUtils.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    office.name,
                    style: AppTypography.semiBold(fontSize: 14),
                  ),
                  if (office.locationLabel.isNotEmpty) ...<Widget>[
                    SizedBox(height: ScreenUtils.h(4)),
                    Text(
                      office.locationLabel,
                      style: AppTypography.medium(
                        fontSize: 12,
                        color: AppColors.mutedGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected
                  ? AppColors.primaryButtonBg
                  : AppColors.mutedGrey,
              size: ScreenUtils.sp(22),
            ),
          ],
        ),
      ),
    );
  }
}

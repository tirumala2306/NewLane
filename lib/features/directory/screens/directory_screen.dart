import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/directory/bloc/directory_bloc.dart';
import 'package:newlane/features/directory/bloc/directory_event.dart';
import 'package:newlane/features/directory/bloc/directory_state.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/directory/widgets/directory_agent_card.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
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
      context.read<DirectoryBloc>().add(DirectorySearchChanged(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DirectoryBloc, DirectoryState>(
      listener: (BuildContext context, DirectoryState state) {
        if (state is DirectoryFailure && state.previous == null) {
          AppSnackBar.showError(
            context,
            title: 'Directory',
            message: state.message,
          );
        }
      },
      builder: (BuildContext context, DirectoryState state) {
        final DirectoryAgentsPage? page = switch (state) {
          DirectoryLoaded(:final DirectoryAgentsPage page) => page,
          DirectoryLoading(:final DirectoryAgentsPage? previous) => previous,
          DirectoryFailure(:final DirectoryAgentsPage? previous) => previous,
          _ => null,
        };
        final bool isLoading = state is DirectoryLoading;
        final List<DirectoryAgent> agents =
            page?.agents ?? const <DirectoryAgent>[];

        return Scaffold(
          backgroundColor: AppColors.black,
          appBar: NewLaneAppBar(
            prefixIcon: Icons.arrow_back_ios_new,
            prefixIconColor: AppColors.white,
            onPrefixPressed: () => context.pop(),
            title: 'AGENT DIRECTORY',
            titleFontSize: 16,
            description: 'NEWLANE',
            descriptionFontSize: 10,
            suffixIcon: Icons.refresh,
            suffixIconColor: AppColors.primaryButtonBg,
            onSuffixPressed: () {
              context.read<DirectoryBloc>().add(const DirectoryRefreshed());
            },
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
                child: _SearchField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: (String value) {
                    _debounce?.cancel();
                    context.read<DirectoryBloc>().add(
                      DirectorySearchChanged(value),
                    );
                  },
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
                    context.read<DirectoryBloc>().add(
                      const DirectoryRefreshed(),
                    );
                    await context.read<DirectoryBloc>().stream.firstWhere(
                      (DirectoryState s) => s is! DirectoryLoading,
                    );
                  },
                  child: agents.isEmpty && !isLoading
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: <Widget>[
                            SizedBox(height: ScreenUtils.h(80)),
                            Icon(
                              Icons.people_outline,
                              size: ScreenUtils.sp(48),
                              color: AppColors.white.withValues(alpha: 0.4),
                            ),
                            SizedBox(height: ScreenUtils.h(12)),
                            Text(
                              'No agents found',
                              textAlign: TextAlign.center,
                              style: AppTypography.semiBold(fontSize: 16),
                            ),
                            SizedBox(height: ScreenUtils.h(8)),
                            Text(
                              _searchController.text.trim().isEmpty
                                  ? 'No agents in your office yet.'
                                  : 'No agents in your office match that search.',
                              textAlign: TextAlign.center,
                              style: AppTypography.regular(
                                fontSize: 13,
                                color: AppColors.white.withValues(alpha: 0.6),
                              ),
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
                          itemCount: agents.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              SizedBox(height: ScreenUtils.h(12)),
                          itemBuilder: (BuildContext context, int index) {
                            return DirectoryAgentCard(
                              agent: agents[index],
                              onTap: () {
                                final DirectoryAgent agent = agents[index];
                                context.push(
                                  AppRoutes.directoryAgentWithId(agent.id),
                                  extra: agent,
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
}

class _SearchField extends StatelessWidget {
  const _SearchField({
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

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: AppTypography.regular(fontSize: 14),
      cursorColor: AppColors.primaryButtonBg,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search agents in your office…',
        hintStyle: AppTypography.regular(
          fontSize: 14,
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
    );
  }
}

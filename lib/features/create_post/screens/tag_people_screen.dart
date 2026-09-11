import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/config/app_environment.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/create_post/bloc/tag_people/tag_people_bloc.dart';
import 'package:newlane/features/create_post/bloc/tag_people/tag_people_event.dart';
import 'package:newlane/features/create_post/bloc/tag_people/tag_people_state.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/profile/widgets/profile_avatar.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';

class TagPeopleScreen extends StatefulWidget {
  const TagPeopleScreen({super.key, this.initialSelected = const <DirectoryAgent>[]});

  final List<DirectoryAgent> initialSelected;

  @override
  State<TagPeopleScreen> createState() => _TagPeopleScreenState();
}

class _TagPeopleScreenState extends State<TagPeopleScreen> {
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
      context.read<TagPeopleBloc>().add(TagPeopleSearchChanged(value));
    });
  }

  void _done(List<DirectoryAgent> agents, Set<int> selectedIds) {
    final Map<int, DirectoryAgent> byId = <int, DirectoryAgent>{
      for (final DirectoryAgent a in widget.initialSelected) a.id: a,
      for (final DirectoryAgent a in agents) a.id: a,
    };
    final List<DirectoryAgent> selected = selectedIds
        .map((int id) => byId[id])
        .whereType<DirectoryAgent>()
        .toList();
    context.pop(selected);
  }

  String? _avatarUrl(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final String base = AppEnvironment.baseUrl.replaceAll(RegExp(r'/$'), '');
    final String path = value.startsWith('/') ? value : '/$value';
    return '$base$path';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TagPeopleBloc, TagPeopleState>(
      listener: (BuildContext context, TagPeopleState state) {
        if (state is TagPeopleFailure && state.previousAgents == null) {
          AppSnackBar.showError(
            context,
            title: 'People',
            message: state.message,
          );
        }
      },
      builder: (BuildContext context, TagPeopleState state) {
        final List<DirectoryAgent> agents = switch (state) {
          TagPeopleLoaded(:final List<DirectoryAgent> agents) => agents,
          TagPeopleLoading(:final List<DirectoryAgent>? previousAgents) =>
            previousAgents ?? const <DirectoryAgent>[],
          TagPeopleFailure(:final List<DirectoryAgent>? previousAgents) =>
            previousAgents ?? const <DirectoryAgent>[],
          _ => const <DirectoryAgent>[],
        };
        final Set<int> selectedIds = switch (state) {
          TagPeopleLoaded(:final Set<int> selectedIds) => selectedIds,
          TagPeopleLoading(:final Set<int> selectedIds) => selectedIds,
          TagPeopleFailure(:final Set<int> selectedIds) => selectedIds,
          _ => widget.initialSelected.map((DirectoryAgent e) => e.id).toSet(),
        };
        final bool isLoading = state is TagPeopleLoading;

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
              'TAG PEOPLE',
              style: AppTypography.semiBold(
                fontSize: 16,
                color: AppColors.primaryButtonBg,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => _done(agents, selectedIds),
                child: Text(
                  selectedIds.isEmpty ? 'Done' : 'Done (${selectedIds.length})',
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
                    hintText: 'Search agents by name.',
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
                child: agents.isEmpty && !isLoading
                    ? Center(
                        child: Text(
                          _searchController.text.trim().isEmpty
                              ? 'No agents available yet.'
                              : 'No agents match your search.',
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
                        itemCount: agents.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: ScreenUtils.h(8)),
                        itemBuilder: (BuildContext context, int index) {
                          final DirectoryAgent agent = agents[index];
                          final bool selected = selectedIds.contains(agent.id);
                          return _PersonTile(
                            name: agent.fullName.isEmpty
                                ? 'Agent'
                                : agent.fullName,
                            subtitle: agent.jobTitle.isNotEmpty
                                ? agent.jobTitle
                                : agent.officeName,
                            avatarUrl: _avatarUrl(agent.avatar),
                            selected: selected,
                            onTap: () {
                              context.read<TagPeopleBloc>().add(
                                TagPeopleToggled(agent.id),
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

class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.avatarUrl,
  });

  final String name;
  final String subtitle;
  final String? avatarUrl;
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
          vertical: ScreenUtils.h(12),
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
            ProfileAvatar(url: avatarUrl, size: ScreenUtils.w(40)),
            SizedBox(width: ScreenUtils.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: AppTypography.semiBold(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...<Widget>[
                    SizedBox(height: ScreenUtils.h(4)),
                    Text(
                      subtitle,
                      style: AppTypography.medium(
                        fontSize: 12,
                        color: AppColors.mutedGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

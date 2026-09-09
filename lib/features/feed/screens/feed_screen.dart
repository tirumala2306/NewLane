import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/feed/bloc/feed_bloc.dart';
import 'package:newlane/features/feed/bloc/feed_event.dart';
import 'package:newlane/features/feed/bloc/feed_state.dart';
import 'package:newlane/features/feed/domain/entities/feed_post.dart';
import 'package:newlane/features/feed/widgets/feed_comments_sheet.dart';
import 'package:newlane/features/feed/widgets/feed_post_card.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  static const List<(String, String)> _filters = <(String, String)>[
    ('all', 'All'),
    ('office', 'Office'),
    ('team', 'Team'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        title: 'FEED',
        description: 'UPDATES',
        height: ScreenUtils.h(56),
      ),
      body: BlocBuilder<FeedBloc, FeedState>(
        builder: (BuildContext context, FeedState state) {
          final String filter = switch (state) {
            FeedLoaded(:final String filter) => filter,
            FeedLoading(:final String filter) => filter,
            FeedFailure(:final String filter) => filter,
            _ => 'all',
          };
          final List<FeedPost> posts = switch (state) {
            FeedLoaded(:final List<FeedPost> posts) => posts,
            FeedLoading(:final List<FeedPost> previous) => previous,
            FeedFailure(:final List<FeedPost> previous) => previous,
            _ => const <FeedPost>[],
          };
          final bool loading = state is FeedLoading || state is FeedInitial;
          final String? error = state is FeedFailure ? state.message : null;

          return Column(
            children: <Widget>[
              SizedBox(height: ScreenUtils.h(8)),
              SizedBox(
                height: ScreenUtils.h(36),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
                  itemCount: _filters.length,
                  separatorBuilder: (_, _) => SizedBox(width: ScreenUtils.w(8)),
                  itemBuilder: (BuildContext context, int index) {
                    final (String value, String label) = _filters[index];
                    final bool selected = filter == value;
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) {
                        context.read<FeedBloc>().add(FeedFilterChanged(value));
                      },
                      selectedColor: AppColors.primaryButtonBg,
                      backgroundColor: const Color(0xFF1A1A1A),
                      labelStyle: AppTypography.medium(
                        fontSize: 12,
                        color: selected ? AppColors.black : AppColors.white,
                      ),
                      side: BorderSide.none,
                      showCheckmark: false,
                    );
                  },
                ),
              ),
              SizedBox(height: ScreenUtils.h(8)),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryButtonBg,
                  backgroundColor: AppColors.cardSurface,
                  onRefresh: () async {
                    context.read<FeedBloc>().add(const FeedRefreshed());
                    await context.read<FeedBloc>().stream.firstWhere(
                      (FeedState s) => s is! FeedLoading,
                    );
                  },
                  child: loading && posts.isEmpty
                      ? ListView(
                          children: <Widget>[
                            SizedBox(height: ScreenUtils.h(120)),
                            const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryButtonBg,
                              ),
                            ),
                          ],
                        )
                      : error != null && posts.isEmpty
                          ? ListView(
                              children: <Widget>[
                                SizedBox(height: ScreenUtils.h(80)),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(ScreenUtils.w(24)),
                                    child: Text(
                                      error,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.regular(
                                        color: AppColors.mutedGrey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : posts.isEmpty
                              ? ListView(
                                  children: <Widget>[
                                    SizedBox(height: ScreenUtils.h(80)),
                                    Center(
                                      child: Text(
                                        'No posts yet',
                                        style: AppTypography.regular(
                                          color: AppColors.mutedGrey,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.separated(
                                  padding: EdgeInsets.fromLTRB(
                                    ScreenUtils.w(16),
                                    ScreenUtils.h(8),
                                    ScreenUtils.w(16),
                                    ScreenUtils.h(24),
                                  ),
                                  itemCount: posts.length,
                                  separatorBuilder: (_, _) =>
                                      SizedBox(height: ScreenUtils.h(12)),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final FeedPost post = posts[index];
                                    return FeedPostCard(
                                      post: post,
                                      onLike: () => context.read<FeedBloc>().add(
                                        FeedLikeToggled(post.id),
                                      ),
                                      onComment: () async {
                                        final bool? added =
                                            await showFeedCommentsSheet(
                                          context: context,
                                          post: post,
                                        );
                                        if (added == true && context.mounted) {
                                          context.read<FeedBloc>().add(
                                            FeedCommentCountBumped(post.id),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/feed/bloc/feed_bloc.dart';
import 'package:newlane/features/feed/bloc/feed_event.dart';
import 'package:newlane/features/feed/bloc/feed_state.dart';
import 'package:newlane/features/feed/domain/entities/feed_post.dart';
import 'package:newlane/features/feed/widgets/feed_comments_sheet.dart';
import 'package:newlane/features/feed/widgets/feed_post_card.dart';
import 'package:newlane/shared/widgets/app_skeleton.dart';
import 'package:newlane/shared/widgets/app_svg.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  static const List<(String, String)> _filters = <(String, String)>[
    ('all', 'All'),
    ('listings', 'listings'),
    ('wins', 'Wins'),
    ('events', 'Events'),
  ];

  bool _searchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return NewLaneAppBar(
      prefix: IconButton(
        onPressed: () => context.push(AppRoutes.moreNotifications),
        icon: Icon(
          CupertinoIcons.bell,
          size: ScreenUtils.sp(24),
          color: AppColors.white,
        ),
      ),
      description: 'ELEVATE. CONNECT. SUCCEED.',
      descriptionFontSize: 5,
      center: AppSvg(
        AssetConstants.newLaneAppLogo,
        height: ScreenUtils.h(30),
      ),
      suffix: IconButton(
        onPressed: () {
          setState(() {
            _searchOpen = !_searchOpen;
            if (!_searchOpen) _searchController.clear();
          });
        },
        icon: Icon(
          _searchOpen ? Icons.close : CupertinoIcons.search,
          size: ScreenUtils.sp(24),
          color: AppColors.white,
        ),
      ),
      height: ScreenUtils.h(64),
    );
  }

  List<FeedPost> _visiblePosts(List<FeedPost> posts, String filter) {
    Iterable<FeedPost> list = posts;
    final String q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((FeedPost p) {
        return p.caption.toLowerCase().contains(q) ||
            p.authorName.toLowerCase().contains(q) ||
            p.officeLabel.toLowerCase().contains(q);
      });
    }

    if (filter == 'all') return list.toList();

    return list.where((FeedPost p) {
      final String type = p.postType.toLowerCase();
      return switch (filter) {
        'listings' =>
          type.contains('list') || type.contains('listing') || type == 'listing',
        'wins' => type.contains('win'),
        'events' => type.contains('event'),
        _ => true,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: _appBar(context),
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
          final bool initialLoading =
              (state is FeedLoading || state is FeedInitial) && posts.isEmpty;
          final String? error =
              state is FeedFailure && posts.isEmpty ? state.message : null;
          final List<FeedPost> visible = _visiblePosts(posts, filter);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(
                  ScreenUtils.w(16),
                  ScreenUtils.h(12),
                  ScreenUtils.w(16),
                  ScreenUtils.h(4),
                ),
                child: Text(
                  'Social Feed',
                  style: AppTypography.semiBold(fontSize: 22),
                ),
              ),
              if (_searchOpen) ...<Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    ScreenUtils.w(16),
                    ScreenUtils.h(8),
                    ScreenUtils.w(16),
                    0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    style: AppTypography.regular(fontSize: 14),
                    cursorColor: AppColors.primaryButtonBg,
                    decoration: InputDecoration(
                      hintText: 'Search posts…',
                      hintStyle: AppTypography.regular(
                        fontSize: 14,
                        color: AppColors.mutedGrey,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF111111),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: ScreenUtils.w(14),
                        vertical: ScreenUtils.h(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
                        borderSide: BorderSide(
                          color: AppColors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
                        borderSide: const BorderSide(
                          color: AppColors.primaryButtonBg,
                        ),
                      ),
                      prefixIcon: Icon(
                        CupertinoIcons.search,
                        color: AppColors.mutedGrey,
                        size: ScreenUtils.sp(18),
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: ScreenUtils.h(12)),
              SizedBox(
                height: ScreenUtils.h(34),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
                  itemCount: _filters.length,
                  separatorBuilder: (_, _) => SizedBox(width: ScreenUtils.w(18)),
                  itemBuilder: (BuildContext context, int index) {
                    final (String value, String label) = _filters[index];
                    final bool selected = filter == value;
                    return GestureDetector(
                      onTap: () {
                        context.read<FeedBloc>().add(FeedFilterChanged(value));
                      },
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtils.w(selected ? 14 : 2),
                          vertical: ScreenUtils.h(6),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            ScreenUtils.r(8),
                          ),
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryButtonBg
                                : Colors.transparent,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: AppTypography.medium(
                            fontSize: 13,
                            color: selected
                                ? AppColors.primaryButtonBg
                                : AppColors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: ScreenUtils.h(12)),
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
                  child: initialLoading
                      ? ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            ScreenUtils.w(16),
                            ScreenUtils.h(4),
                            ScreenUtils.w(16),
                            ScreenUtils.h(24),
                          ),
                          itemCount: 3,
                          separatorBuilder: (_, _) =>
                              SizedBox(height: ScreenUtils.h(12)),
                          itemBuilder: (_, _) => const FeedPostCardSkeleton(),
                        )
                      : error != null
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: <Widget>[
                                SizedBox(height: ScreenUtils.h(80)),
                                Padding(
                                  padding: EdgeInsets.all(ScreenUtils.w(24)),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        error,
                                        textAlign: TextAlign.center,
                                        style: AppTypography.regular(
                                          color: AppColors.mutedGrey,
                                        ),
                                      ),
                                      SizedBox(height: ScreenUtils.h(16)),
                                      TextButton(
                                        onPressed: () => context
                                            .read<FeedBloc>()
                                            .add(const FeedRefreshed()),
                                        child: Text(
                                          'Retry',
                                          style: AppTypography.semiBold(
                                            color: AppColors.primaryButtonBg,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : visible.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
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
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.fromLTRB(
                                    ScreenUtils.w(16),
                                    ScreenUtils.h(4),
                                    ScreenUtils.w(16),
                                    ScreenUtils.h(24),
                                  ),
                                  itemCount: visible.length,
                                  separatorBuilder: (_, _) =>
                                      SizedBox(height: ScreenUtils.h(12)),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final FeedPost post = visible[index];
                                    return FeedPostCard(
                                      post: post,
                                      onLike: () =>
                                          context.read<FeedBloc>().add(
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

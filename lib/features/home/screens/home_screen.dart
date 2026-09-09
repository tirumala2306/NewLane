import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/data/mock/home_mock_data.dart';
import 'package:newlane/features/home/widgets/announcement_list.dart';
import 'package:newlane/features/home/widgets/home_card.dart';
import 'package:newlane/features/home/widgets/home_section_header.dart';
import 'package:newlane/features/home/widgets/my_requests_summary.dart';
import 'package:newlane/features/home/widgets/office_card.dart';
import 'package:newlane/features/home/widgets/quick_actions_grid.dart';
import 'package:newlane/features/home/widgets/social_feed_card.dart';
import 'package:newlane/features/feed/domain/entities/feed_post.dart';
import 'package:newlane/features/marketing_request/domain/usecases/get_marketing_request_counts.dart';
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';
import 'package:newlane/shared/widgets/app_svg.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Map<String, int> _quickActionBranches = <String, int>{
    'Chat': 1,
  };

  MarketingRequestCounts _requestCounts = const MarketingRequestCounts.zero();
  bool _loadingCounts = true;
  FeedPost? _feedPreview;
  bool _loadingFeed = true;

  @override
  void initState() {
    super.initState();
    _loadRequestCounts();
    _loadFeedPreview();
  }

  Future<void> _loadRequestCounts() async {
    final Result<MarketingRequestCounts> result =
        await InjectionContainer.instance.fetchMarketingRequestCounts();
    if (!mounted) return;
    result.when(
      ok: (MarketingRequestCounts counts) {
        setState(() {
          _requestCounts = counts;
          _loadingCounts = false;
        });
      },
      err: (_) {
        setState(() => _loadingCounts = false);
      },
    );
  }

  Future<void> _loadFeedPreview() async {
    final Result<List<FeedPost>> result =
        await InjectionContainer.instance.fetchFeed();
    if (!mounted) return;
    result.when(
      ok: (List<FeedPost> posts) {
        setState(() {
          _feedPreview = posts.isEmpty ? null : posts.first;
          _loadingFeed = false;
        });
      },
      err: (_) {
        setState(() => _loadingFeed = false);
      },
    );
  }

  Future<void> _openMyRequests() async {
    await context.push(AppRoutes.myRequests);
    await _loadRequestCounts();
  }

  void _openFeed() {
    StatefulNavigationShell.of(context).goBranch(2);
  }

  Future<void> _onQuickActionTap(
    BuildContext context,
    HomeQuickAction action,
  ) async {
    final int? branch = _quickActionBranches[action.title];
    if (branch != null) {
      StatefulNavigationShell.of(context).goBranch(branch);
      return;
    }

    if (action.title == 'Directory') {
      context.push(AppRoutes.directory);
      return;
    }

    if (action.title == 'Training Hub') {
      context.push(AppRoutes.trainingHub);
      return;
    }

    if (action.title == 'Marketing Request') {
      await context.push(AppRoutes.marketingRequest);
      await _loadRequestCounts();
      return;
    }

    if (action.title == 'Content Generator') {
      context.push(AppRoutes.contentGenerator);
    }
  }

  List<HomeRequestStat> get _requestStats => <HomeRequestStat>[
    HomeRequestStat(
      count: _requestCounts.inProgress,
      label: 'In Progress',
      icon: Icons.timelapse_outlined,
    ),
    HomeRequestStat(
      count: _requestCounts.completed,
      label: 'Completed',
      icon: Icons.check_circle_outline,
    ),
    HomeRequestStat(
      count: _requestCounts.pendingReview,
      label: 'Pending Review',
      icon: Icons.schedule_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double gap = ScreenUtils.h(16);
    final ProfileState profileState = context.watch<ProfileBloc>().state;
    final String officeName = switch (profileState) {
      ProfileLoaded(:final profile) when profile.officeName.trim().isNotEmpty =>
        profile.officeName.trim(),
      _ => HomeMockData.officeName,
    };

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: _appBar(context),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            ScreenUtils.w(16),
            gap,
            ScreenUtils.w(16),
            ScreenUtils.h(32),
          ),
          children: <Widget>[
            _greeting(),
            SizedBox(height: gap),
            OfficeCard(
              officeName: officeName,
              onViewOffice: () => context.push(AppRoutes.officeDirectory),
            ),
            SizedBox(height: gap),
            _announcementsCard(),
            SizedBox(height: gap),
            const HomeSectionHeader(title: 'QUICK ACTIONS'),
            SizedBox(height: gap),
            QuickActionsGrid(
              actions: HomeMockData.quickActions,
              onActionTap: (HomeQuickAction action) =>
                  _onQuickActionTap(context, action),
            ),
            SizedBox(height: gap),
            _requestsCard(context),
            SizedBox(height: gap),
            _feedCard(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return NewLaneAppBar(
      prefix: IconButton(
        onPressed: () => context.push(AppRoutes.more),
        icon: Icon(Icons.menu, size: ScreenUtils.sp(28)),
      ),
      description: 'ELEVATE. CONNECT. SUCCEED.',
      descriptionFontSize: 5,
      center: AppSvg(
        AssetConstants.newLaneAppLogo,
        height: ScreenUtils.h(30),
      ),
      suffix: IconButton(
        onPressed: () {},
        icon: Icon(CupertinoIcons.bell, size: ScreenUtils.sp(28)),
      ),
      height: ScreenUtils.h(64),
    );
  }

  String get _timeOfDayGreeting {
    final int hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning,';
    }
    if (hour >= 12 && hour < 17) {
      return 'Good afternoon,';
    }
    return 'Good evening,';
  }

  Widget _greeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          _timeOfDayGreeting,
          style: AppTypography.semiBold(
            fontSize: 12,
            color: AppColors.primaryButtonBg,
          ),
        ),
        SizedBox(height: ScreenUtils.h(4)),
        Text(
          'Welcome back!',
          style: AppTypography.semiBold(fontSize: 18),
        ),
      ],
    );
  }

  Widget _announcementsCard() {
    return HomeCard(
      padding: EdgeInsets.fromLTRB(
        ScreenUtils.w(16),
        ScreenUtils.h(16),
        ScreenUtils.w(16),
        ScreenUtils.h(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HomeSectionHeader(title: 'ANNOUNCEMENTS', onViewAll: () {}),
          const AnnouncementList(items: HomeMockData.announcements),
        ],
      ),
    );
  }

  Widget _requestsCard(BuildContext context) {
    return HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HomeSectionHeader(
            title: 'MY REQUESTS',
            onViewAll: _openMyRequests,
          ),
          SizedBox(height: ScreenUtils.h(12)),
          if (_loadingCounts)
            Padding(
              padding: EdgeInsets.symmetric(vertical: ScreenUtils.h(12)),
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryButtonBg,
                  ),
                ),
              ),
            )
          else
            MyRequestsSummary(
              stats: _requestStats,
              onStatTap: (_) => _openMyRequests(),
            ),
        ],
      ),
    );
  }

  Widget _feedCard() {
    return HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HomeSectionHeader(
            title: 'INTERNAL SOCIAL FEED',
            onViewAll: _openFeed,
          ),
          SizedBox(height: ScreenUtils.h(14)),
          if (_loadingFeed)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryButtonBg,
                  ),
                ),
              ),
            )
          else if (_feedPreview == null)
            Text(
              'No posts yet — create one from +',
              style: AppTypography.regular(
                fontSize: 12,
                color: AppColors.mutedGrey,
              ),
            )
          else
            SocialFeedCard(
              post: _feedPreview!,
              onTap: _openFeed,
            ),
        ],
      ),
    );
  }
}

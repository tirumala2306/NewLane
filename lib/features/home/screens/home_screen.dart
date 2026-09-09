import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/constants/asset_constants.dart';
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
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';
import 'package:newlane/shared/widgets/app_svg.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Map<String, int> _quickActionBranches = <String, int>{
    'Chat': 1,
  };

  void _onQuickActionTap(BuildContext context, HomeQuickAction action) {
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
      context.push(AppRoutes.marketingRequest);
      return;
    }

    if (action.title == 'Content Generator') {
      context.push(AppRoutes.contentGenerator);
    }
  }

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
            onViewAll: () => context.push(AppRoutes.myRequests),
          ),
          SizedBox(height: ScreenUtils.h(12)),
          MyRequestsSummary(
            stats: HomeMockData.requestStats,
            onStatTap: (_) => context.push(AppRoutes.myRequests),
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
          HomeSectionHeader(title: 'INTERNAL SOCIAL FEED', onViewAll: () {}),
          SizedBox(height: ScreenUtils.h(14)),
          const SocialFeedCard(post: HomeMockData.feedPost),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';
import 'package:newlane/features/support/widgets/support_category_tile.dart';
import 'package:newlane/features/support/widgets/support_hero_card.dart';
import 'package:newlane/features/support/widgets/support_need_help_card.dart';
import 'package:newlane/features/support/widgets/support_recent_tickets.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  List<SupportTicket> _recent = const <SupportTicket>[];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final Result<List<SupportTicket>> result =
        await InjectionContainer.instance.fetchMySupportTickets();
    if (!mounted) return;
    result.when(
      ok: (List<SupportTicket> tickets) {
        setState(() => _recent = tickets.take(2).toList());
      },
      err: (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final double gap = ScreenUtils.h(16);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        prefixIconColor: AppColors.white,
        onPrefixPressed: () => context.pop(),
        title: 'SUPPORT',
        titleFontSize: 16,
        description: 'NEWLANE BRICKWELL',
        descriptionFontSize: 10,
        height: ScreenUtils.h(56),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(16),
          ScreenUtils.h(8),
          ScreenUtils.w(16),
          ScreenUtils.h(32),
        ),
        children: <Widget>[
          SupportHeroCard(onChatTap: () {}),
          SizedBox(height: gap),
          Text(
            'Support Categories',
            style: AppTypography.semiBold(fontSize: 14),
          ),
          SizedBox(height: gap),
          ...SupportMockData.categories.map(
            (SupportCategory category) => Padding(
              padding: EdgeInsets.only(bottom: ScreenUtils.h(10)),
              child: SupportCategoryTile(
                category: category,
                onTap: () async {
                  if (category.title == 'Ticket Support') {
                    await context.push(AppRoutes.ticketSupport);
                    await _loadRecent();
                    return;
                  }
                  await context.push(
                    AppRoutes.newSupportTicket,
                    extra: category.title,
                  );
                  await _loadRecent();
                },
              ),
            ),
          ),
          SupportNeedHelpCard(onCallTap: () {}),
          SizedBox(height: gap),
          SupportRecentTickets(
            tickets: _recent,
            onViewAll: () async {
              await context.push(AppRoutes.ticketSupport);
              await _loadRecent();
            },
            onTicketTap: (SupportTicket ticket) async {
              await context.push(
                AppRoutes.ticketDetails,
                extra: ticket,
              );
              await _loadRecent();
            },
          ),
        ],
      ),
    );
  }
}

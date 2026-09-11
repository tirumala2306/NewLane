import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/phone_launcher.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/more/data/mock/more_mock_data.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';
import 'package:newlane/features/support/widgets/support_category_tile.dart';
import 'package:newlane/features/support/widgets/support_hero_card.dart';
import 'package:newlane/features/support/widgets/support_need_help_card.dart';
import 'package:newlane/features/support/widgets/support_recent_tickets.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  List<SupportTicket> _recent = const <SupportTicket>[];
  bool _loadingRecent = true;

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    setState(() => _loadingRecent = true);
    final Result<List<SupportTicket>> result =
        await InjectionContainer.instance.fetchMySupportTickets();
    if (!mounted) return;
    result.when(
      ok: (List<SupportTicket> tickets) {
        setState(() {
          _recent = tickets.take(3).toList();
          _loadingRecent = false;
        });
      },
      err: (_) {
        setState(() {
          _recent = const <SupportTicket>[];
          _loadingRecent = false;
        });
      },
    );
  }

  Future<void> _callSupport() async {
    final bool opened = await openPhoneDialer(MoreMockData.supportPhone);
    if (!mounted) return;
    if (!opened) {
      AppSnackBar.showInfo(
        context,
        title: 'Call',
        message: 'Could not open the phone dialer.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double gap = ScreenUtils.h(16);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        onPrefixPressed: () => context.pop(),
        title: 'SUPPORT',
        titleFontSize: 16,
        description: MoreMockData.officeName.toUpperCase(),
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
          SupportHeroCard(
            onChatTap: () => context.push(AppRoutes.ticketSupport),
          ),
          SizedBox(height: gap),
          Text(
            'Support Categories',
            style: AppTypography.semiBold(fontSize: 14),
          ),
          SizedBox(height: ScreenUtils.h(12)),
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
          SupportNeedHelpCard(onCallTap: _callSupport),
          SizedBox(height: gap),
          if (_loadingRecent)
            Padding(
              padding: EdgeInsets.only(top: ScreenUtils.h(8)),
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

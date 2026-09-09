import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';
import 'package:newlane/features/support/widgets/support_ticket_widgets.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

class TicketDetailsScreen extends StatelessWidget {
  const TicketDetailsScreen({required this.ticket, super.key});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final SupportTicket current =
        SupportTicketStore.instance.byId(ticket.id) ?? ticket;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        onPrefixPressed: () => context.pop(),
        title: 'TICKET DETAILS',
        titleFontSize: 16,
        height: ScreenUtils.h(56),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                ScreenUtils.w(16),
                ScreenUtils.h(8),
                ScreenUtils.w(16),
                ScreenUtils.h(16),
              ),
              children: <Widget>[
                SupportTicketCard(
                  ticket: current,
                  showChevron: false,
                  dateLabel: current.submittedLabel,
                ),
                SizedBox(height: ScreenUtils.h(20)),
                Text(
                  'STATUS TIMELINE',
                  style: AppTypography.medium(
                    fontSize: 11,
                    color: AppColors.mutedGrey,
                  ),
                ),
                SizedBox(height: ScreenUtils.h(14)),
                SupportTimeline(ticket: current),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                ScreenUtils.w(16),
                ScreenUtils.h(8),
                ScreenUtils.w(16),
                ScreenUtils.h(12),
              ),
              child: UnifiedButton.outline(
                label: 'View Conversation',
                onPressed: () => context.push(
                  AppRoutes.ticketConversation,
                  extra: current,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

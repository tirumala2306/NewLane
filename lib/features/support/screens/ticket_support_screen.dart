import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';
import 'package:newlane/features/support/widgets/support_ticket_widgets.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class TicketSupportScreen extends StatefulWidget {
  const TicketSupportScreen({super.key});

  @override
  State<TicketSupportScreen> createState() => _TicketSupportScreenState();
}

class _TicketSupportScreenState extends State<TicketSupportScreen> {
  SupportTicketStatus? _filter;

  @override
  void initState() {
    super.initState();
    SupportTicketStore.instance.addListener(_onStore);
  }

  @override
  void dispose() {
    SupportTicketStore.instance.removeListener(_onStore);
    super.dispose();
  }

  void _onStore() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<SupportTicket> tickets = SupportTicketStore.instance.tickets
        .where(
          (SupportTicket ticket) =>
              _filter == null || ticket.status == _filter,
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        onPrefixPressed: () => context.pop(),
        title: 'TICKET SUPPORT',
        titleFontSize: 16,
        height: ScreenUtils.h(56),
        suffixIcon: Icons.add,
        suffixIconColor: AppColors.primaryButtonBg,
        onSuffixPressed: () => context.push(AppRoutes.newSupportTicket),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              ScreenUtils.w(16),
              ScreenUtils.h(4),
              ScreenUtils.w(16),
              ScreenUtils.h(12),
            ),
            child: SupportFilterTabs(
              selected: _filter,
              onSelected: (SupportTicketStatus? value) {
                setState(() => _filter = value);
              },
            ),
          ),
          Expanded(
            child: tickets.isEmpty
                ? Center(
                    child: Text(
                      'No tickets in this filter.',
                      style: AppTypography.regular(
                        fontSize: 13,
                        color: AppColors.mutedGrey,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      ScreenUtils.w(16),
                      0,
                      ScreenUtils.w(16),
                      ScreenUtils.h(24),
                    ),
                    itemCount: tickets.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: ScreenUtils.h(10)),
                    itemBuilder: (BuildContext context, int index) {
                      final SupportTicket ticket = tickets[index];
                      return SupportTicketCard(
                        ticket: ticket,
                        onTap: () => context.push(
                          AppRoutes.ticketDetails,
                          extra: ticket,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';
import 'package:newlane/features/support/widgets/support_ticket_widgets.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

class TicketDetailsScreen extends StatefulWidget {
  const TicketDetailsScreen({required this.ticket, super.key});

  final SupportTicket ticket;

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  late SupportTicket _ticket;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
    if (_ticket.apiId > 0) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final Result<SupportTicket> result =
        await InjectionContainer.instance.fetchSupportTicketById(_ticket.apiId);
    if (!mounted) return;
    result.when(
      ok: (SupportTicket ticket) {
        setState(() {
          _ticket = ticket;
          _loading = false;
        });
      },
      err: (_) => setState(() => _loading = false),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          if (_loading)
            const LinearProgressIndicator(
              color: AppColors.primaryButtonBg,
              backgroundColor: Colors.transparent,
              minHeight: 2,
            ),
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
                  ticket: _ticket,
                  showChevron: false,
                  dateLabel: _ticket.submittedLabel,
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
                SupportTimeline(ticket: _ticket),
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
                onPressed: () async {
                  await context.push(
                    AppRoutes.ticketConversation,
                    extra: _ticket,
                  );
                  await _refresh();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

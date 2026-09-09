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
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class TicketSupportScreen extends StatefulWidget {
  const TicketSupportScreen({super.key});

  @override
  State<TicketSupportScreen> createState() => _TicketSupportScreenState();
}

class _TicketSupportScreenState extends State<TicketSupportScreen> {
  SupportTicketStatus? _filter;
  List<SupportTicket> _tickets = const <SupportTicket>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final Result<List<SupportTicket>> result =
        await InjectionContainer.instance.fetchMySupportTickets();
    if (!mounted) return;
    result.when(
      ok: (List<SupportTicket> tickets) {
        setState(() {
          _tickets = tickets;
          _loading = false;
        });
      },
      err: (failure) {
        setState(() {
          _loading = false;
          _error = failure.message;
        });
        AppSnackBar.showError(
          context,
          title: 'Tickets',
          message: failure.message,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<SupportTicket> tickets = _tickets
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
        onSuffixPressed: () async {
          await context.push(AppRoutes.newSupportTicket);
          await _load();
        },
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
            child: RefreshIndicator(
              color: AppColors.primaryButtonBg,
              backgroundColor: AppColors.cardSurface,
              onRefresh: _load,
              child: _loading
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
                  : _error != null && tickets.isEmpty
                      ? ListView(
                          children: <Widget>[
                            SizedBox(height: ScreenUtils.h(80)),
                            Center(
                              child: Text(
                                _error!,
                                style: AppTypography.regular(
                                  fontSize: 13,
                                  color: AppColors.mutedGrey,
                                ),
                              ),
                            ),
                          ],
                        )
                      : tickets.isEmpty
                          ? ListView(
                              children: <Widget>[
                                SizedBox(height: ScreenUtils.h(80)),
                                Center(
                                  child: Text(
                                    'No tickets in this filter.',
                                    style: AppTypography.regular(
                                      fontSize: 13,
                                      color: AppColors.mutedGrey,
                                    ),
                                  ),
                                ),
                              ],
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
                                  onTap: () async {
                                    await context.push(
                                      AppRoutes.ticketDetails,
                                      extra: ticket,
                                    );
                                    await _load();
                                  },
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

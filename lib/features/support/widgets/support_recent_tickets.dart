import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/home/widgets/home_card.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';

class SupportRecentTickets extends StatelessWidget {
  const SupportRecentTickets({
    required this.tickets,
    super.key,
    this.onViewAll,
    this.onTicketTap,
  });

  final List<SupportTicket> tickets;
  final VoidCallback? onViewAll;
  final ValueChanged<SupportTicket>? onTicketTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Recent Tickets',
                style: AppTypography.semiBold(fontSize: 14),
              ),
            ),
            if (onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: <Widget>[
                    Text(
                      'View All',
                      style: AppTypography.medium(
                        fontSize: 10,
                        color: AppColors.primaryButtonBg,
                      ),
                    ),
                    SizedBox(width: ScreenUtils.w(4)),
                    Icon(
                      Icons.chevron_right,
                      size: ScreenUtils.sp(20),
                      color: AppColors.primaryButtonBg,
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: ScreenUtils.h(18)),
        ...tickets.map(
          (SupportTicket ticket) => Padding(
            padding: EdgeInsets.only(bottom: ScreenUtils.h(10)),
            child: _TicketCard(
              ticket: ticket,
              onTap: onTicketTap == null ? null : () => onTicketTap!(ticket),
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, this.onTap});

  final SupportTicket ticket;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtils.w(16)),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0B),
        borderRadius: HomeCard.radius,
        border: Border.all(color: const Color(0x33EFEFEF)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: HomeCard.radius,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: ScreenUtils.w(54),
              height: ScreenUtils.w(54),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                border: Border.all(color: AppColors.primaryButtonBg),
                color: AppColors.primaryButtonBg.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.description_outlined,
                size: ScreenUtils.sp(24),
                color: AppColors.primaryButtonBg,
              ),
            ),
            SizedBox(width: ScreenUtils.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Ticket ID: ${ticket.id}',
                    style: AppTypography.semiBold(fontSize: 12),
                  ),
                  SizedBox(height: ScreenUtils.h(6)),
                  Text(
                    ticket.title,
                    style: AppTypography.medium(
                      fontSize: 10,
                      color: AppColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  SizedBox(height: ScreenUtils.h(10)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtils.w(6),
                      vertical: ScreenUtils.h(4),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ScreenUtils.r(4)),
                      border: Border.all(
                        color: ticket.status.color.withValues(
                          alpha: 0.25,
                        ),
                      ),
                      color: ticket.status.color.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: Icon(
                            Icons.circle_outlined,
                            size: ScreenUtils.sp(12),
                            color: ticket.status.color,
                          ),
                        ),
                        SizedBox(width: ScreenUtils.w(6)),
                        Text(
                          ticket.status.label,
                          style: AppTypography.medium(
                            fontSize: 10,
                            color: ticket.status.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: ScreenUtils.w(8)),
            Row(
              children: <Widget>[
                Text(ticket.timeAgo, style: AppTypography.medium(fontSize: 10, color: AppColors.white.withValues(alpha: 0.65))),
                SizedBox(width: ScreenUtils.w(8)),
                Icon(
                  Icons.chevron_right,
                    size: ScreenUtils.sp(16),
                    color: AppColors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

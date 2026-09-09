import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';

class SupportStatusBadge extends StatelessWidget {
  const SupportStatusBadge({required this.status, super.key});

  final SupportTicketStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.w(8),
        vertical: ScreenUtils.h(4),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtils.r(4)),
        border: Border.all(color: status.color),
      ),
      child: Text(
        status.label,
        style: AppTypography.semiBold(fontSize: 10, color: status.color),
      ),
    );
  }
}

class SupportTicketCard extends StatelessWidget {
  const SupportTicketCard({
    required this.ticket,
    super.key,
    this.onTap,
    this.showChevron = true,
    this.dateLabel,
  });

  final SupportTicket ticket;
  final VoidCallback? onTap;
  final bool showChevron;
  final String? dateLabel;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(ScreenUtils.r(8));

    return Material(
      color: const Color(0xFF111111),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(ScreenUtils.w(14)),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      ticket.id,
                      style: AppTypography.semiBold(fontSize: 13),
                    ),
                  ),
                  SupportStatusBadge(status: ticket.status),
                ],
              ),
              SizedBox(height: ScreenUtils.h(8)),
              Text(
                ticket.title,
                style: AppTypography.regular(fontSize: 12, height: 1.3),
              ),
              SizedBox(height: ScreenUtils.h(10)),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      dateLabel ?? ticket.updatedLabel,
                      style: AppTypography.regular(
                        fontSize: 10,
                        color: AppColors.mutedGrey,
                      ),
                    ),
                  ),
                  if (showChevron)
                    Icon(
                      Icons.chevron_right,
                      size: ScreenUtils.sp(18),
                      color: AppColors.white.withValues(alpha: 0.55),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportFilterTabs extends StatelessWidget {
  const SupportFilterTabs({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final SupportTicketStatus? selected;
  final ValueChanged<SupportTicketStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    final List<(String, SupportTicketStatus?)> filters = <(String, SupportTicketStatus?)>[
      ('All', null),
      ('Submitted', SupportTicketStatus.submitted),
      ('In Progress', SupportTicketStatus.inProgress),
      ('Resolved', SupportTicketStatus.resolved),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map(
          ((String, SupportTicketStatus?) filter) {
            final bool active = selected == filter.$2;
            return Padding(
              padding: EdgeInsets.only(right: ScreenUtils.w(8)),
              child: GestureDetector(
                onTap: () => onSelected(filter.$2),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtils.w(14),
                    vertical: ScreenUtils.h(8),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                    border: Border.all(
                      color: active
                          ? AppColors.primaryButtonBg
                          : AppColors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    filter.$1,
                    style: AppTypography.semiBold(
                      fontSize: 12,
                      color: active
                          ? AppColors.primaryButtonBg
                          : AppColors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

class SupportTimeline extends StatelessWidget {
  const SupportTimeline({
    required this.ticket,
    super.key,
  });

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final List<SupportTimelineEvent> events = ticket.timeline;
    final bool allResolved = ticket.status == SupportTicketStatus.resolved;

    return Column(
      children: List<Widget>.generate(events.length, (int index) {
        final SupportTimelineEvent event = events[index];
        final bool last = index == events.length - 1;
        final Color color = allResolved && event.completed
            ? SupportTicketStatus.resolved.color
            : event.completed
                ? event.stage.color
                : AppColors.white.withValues(alpha: 0.35);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  width: ScreenUtils.w(18),
                  height: ScreenUtils.w(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: event.completed
                        ? (allResolved
                            ? SupportTicketStatus.resolved.color
                            : event.stage.color)
                        : Colors.transparent,
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: event.completed && allResolved
                      ? Icon(
                          Icons.check,
                          size: ScreenUtils.sp(11),
                          color: AppColors.white,
                        )
                      : null,
                ),
                if (!last)
                  Container(
                    width: 1.5,
                    height: ScreenUtils.h(52),
                    color: events[index + 1].completed
                        ? (allResolved
                            ? SupportTicketStatus.resolved.color
                            : events[index + 1].stage.color)
                        : AppColors.white.withValues(alpha: 0.18),
                  ),
              ],
            ),
            SizedBox(width: ScreenUtils.w(12)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : ScreenUtils.h(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      event.stage == SupportTicketStatus.inProgress &&
                              event.completed &&
                              !allResolved
                          ? 'On Progress'
                          : event.stage.label,
                      style: AppTypography.semiBold(fontSize: 13),
                    ),
                    SizedBox(height: ScreenUtils.h(4)),
                    Text(
                      event.timestamp,
                      style: AppTypography.regular(
                        fontSize: 11,
                        color: AppColors.mutedGrey,
                      ),
                    ),
                    if (event.message != null) ...<Widget>[
                      SizedBox(height: ScreenUtils.h(4)),
                      Text(
                        event.message!,
                        style: AppTypography.regular(
                          fontSize: 11,
                          height: 1.3,
                          color: AppColors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class SupportAttachmentTile extends StatelessWidget {
  const SupportAttachmentTile({
    required this.attachment,
    super.key,
    this.onRemove,
  });

  final SupportAttachment attachment;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.w(12),
        vertical: ScreenUtils.h(10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.insert_drive_file_outlined,
            color: AppColors.primaryButtonBg,
            size: ScreenUtils.sp(20),
          ),
          SizedBox(width: ScreenUtils.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.semiBold(fontSize: 12),
                ),
                SizedBox(height: ScreenUtils.h(2)),
                Text(
                  attachment.sizeLabel,
                  style: AppTypography.regular(
                    fontSize: 10,
                    color: AppColors.mutedGrey,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: Icon(
                Icons.close,
                size: ScreenUtils.sp(18),
                color: AppColors.white,
              ),
            ),
        ],
      ),
    );
  }
}

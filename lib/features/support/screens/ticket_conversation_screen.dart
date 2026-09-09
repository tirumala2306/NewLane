import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';
import 'package:newlane/features/support/widgets/support_ticket_widgets.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class TicketConversationScreen extends StatefulWidget {
  const TicketConversationScreen({required this.ticket, super.key});

  final SupportTicket ticket;

  @override
  State<TicketConversationScreen> createState() =>
      _TicketConversationScreenState();
}

class _TicketConversationScreenState extends State<TicketConversationScreen> {
  final TextEditingController _controller = TextEditingController();

  SupportTicket get _ticket =>
      SupportTicketStore.instance.byId(widget.ticket.id) ?? widget.ticket;

  @override
  void initState() {
    super.initState();
    SupportTicketStore.instance.addListener(_onStore);
  }

  @override
  void dispose() {
    SupportTicketStore.instance.removeListener(_onStore);
    _controller.dispose();
    super.dispose();
  }

  void _onStore() {
    if (mounted) {
      setState(() {});
    }
  }

  void _send() {
    final String text = _controller.text.trim();
    if (text.isEmpty || _ticket.isClosed) {
      return;
    }
    SupportTicketStore.instance.addMessage(
      _ticket.id,
      SupportMessage(
        isMine: true,
        author: 'You',
        timestamp: 'Just now',
        text: text,
      ),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final SupportTicket ticket = _ticket;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        onPrefixPressed: () => context.pop(),
        title: 'CONVERSATION',
        titleFontSize: 16,
        height: ScreenUtils.h(56),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              ScreenUtils.w(16),
              ScreenUtils.h(8),
              ScreenUtils.w(16),
              ScreenUtils.h(8),
            ),
            child: SupportTicketCard(ticket: ticket, showChevron: false),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(
                ScreenUtils.w(16),
                ScreenUtils.h(8),
                ScreenUtils.w(16),
                ScreenUtils.h(16),
              ),
              itemCount: ticket.messages.length,
              separatorBuilder: (_, _) => SizedBox(height: ScreenUtils.h(12)),
              itemBuilder: (BuildContext context, int index) {
                return _MessageCard(message: ticket.messages[index]);
              },
            ),
          ),
          if (ticket.isClosed)
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  ScreenUtils.w(16),
                  ScreenUtils.h(8),
                  ScreenUtils.w(16),
                  ScreenUtils.h(12),
                ),
                child: Container(
                  width: double.infinity,
                  height: ScreenUtils.h(48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                  ),
                  child: Text(
                    'This ticket is closed',
                    style: AppTypography.semiBold(
                      fontSize: 13,
                      color: AppColors.mutedGrey,
                    ),
                  ),
                ),
              ),
            )
          else
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  ScreenUtils.w(16),
                  ScreenUtils.h(8),
                  ScreenUtils.w(16),
                  ScreenUtils.h(12),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: AppTypography.regular(fontSize: 13),
                        cursorColor: AppColors.primaryButtonBg,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: AppTypography.regular(
                            fontSize: 13,
                            color: AppColors.mutedGrey,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF111111),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: ScreenUtils.w(14),
                            vertical: ScreenUtils.h(12),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              ScreenUtils.r(8),
                            ),
                            borderSide: BorderSide(
                              color: AppColors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              ScreenUtils.r(8),
                            ),
                            borderSide: BorderSide(
                              color: AppColors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              ScreenUtils.r(8),
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.primaryButtonBg,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    SizedBox(width: ScreenUtils.w(8)),
                    IconButton(
                      onPressed: _send,
                      icon: Icon(
                        Icons.send_rounded,
                        color: AppColors.primaryButtonBg,
                        size: ScreenUtils.sp(22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});

  final SupportMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenUtils.w(12)),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  message.author,
                  style: AppTypography.semiBold(fontSize: 12),
                ),
              ),
              Text(
                message.timestamp,
                style: AppTypography.regular(
                  fontSize: 10,
                  color: AppColors.mutedGrey,
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtils.h(8)),
          Text(
            message.text,
            style: AppTypography.regular(fontSize: 12, height: 1.45),
          ),
          if (message.attachment != null) ...<Widget>[
            SizedBox(height: ScreenUtils.h(10)),
            Text(
              'Attachment',
              style: AppTypography.medium(
                fontSize: 10,
                color: AppColors.mutedGrey,
              ),
            ),
            SizedBox(height: ScreenUtils.h(6)),
            SupportAttachmentTile(attachment: message.attachment!),
          ],
        ],
      ),
    );
  }
}

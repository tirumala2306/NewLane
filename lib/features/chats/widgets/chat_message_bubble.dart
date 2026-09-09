import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/chats/domain/entities/chat_message.dart';

/// WhatsApp-style bubble: wraps tightly around short text ("Hi"), caps long text.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    required this.message,
    required this.isMine,
    super.key,
  });

  final ChatMessage message;
  final bool isMine;

  String get _timeLabel {
    final DateTime t = message.createdAt;
    final int hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final String minute = t.minute.toString().padLeft(2, '0');
    final String period = t.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor = isMine
        ? const Color(0xFFBD9037)
        : const Color(0xFF1F2C34);
    final Color textColor = isMine ? AppColors.black : AppColors.white;
    final Color metaColor = isMine
        ? AppColors.black.withValues(alpha: 0.55)
        : const Color(0xFF8696A0);

    final BorderRadius radius = BorderRadius.only(
      topLeft: Radius.circular(ScreenUtils.r(10)),
      topRight: Radius.circular(ScreenUtils.r(10)),
      bottomLeft: Radius.circular(ScreenUtils.r(isMine ? 10 : 2)),
      bottomRight: Radius.circular(ScreenUtils.r(isMine ? 2 : 10)),
    );

    final Widget meta = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          _timeLabel,
          style: AppTypography.regular(
            fontSize: 10,
            color: metaColor,
          ),
        ),
        if (isMine) ...<Widget>[
          SizedBox(width: ScreenUtils.w(3)),
          Icon(
            Icons.done_all,
            size: ScreenUtils.sp(14),
            color: metaColor,
          ),
        ],
      ],
    );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: IntrinsicWidth(
          child: Container(
            padding: EdgeInsets.fromLTRB(
              ScreenUtils.w(9),
              ScreenUtils.h(6),
              ScreenUtils.w(8),
              ScreenUtils.h(5),
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: radius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  message.text,
                  style: AppTypography.regular(
                    fontSize: 14.5,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: ScreenUtils.h(2)),
                meta,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

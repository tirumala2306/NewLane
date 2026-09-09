import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/chats/domain/entities/chat_message.dart';
import 'package:newlane/features/profile/widgets/profile_avatar.dart';

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
    final String period = t.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor = isMine
        ? AppColors.primaryButtonBg
        : const Color(0xFF1A1A1A);
    final Color textColor = isMine ? AppColors.black : AppColors.white;
    final Color metaColor = isMine
        ? AppColors.black.withValues(alpha: 0.65)
        : AppColors.mutedGrey;

    final Widget bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: ScreenUtils.w(280)),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(14),
          ScreenUtils.h(10),
          ScreenUtils.w(14),
          ScreenUtils.h(8),
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(ScreenUtils.r(14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.text,
                style: AppTypography.regular(
                  fontSize: 13,
                  color: textColor,
                  height: 1.35,
                ),
              ),
            ),
            SizedBox(height: ScreenUtils.h(6)),
            Row(
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
                  SizedBox(width: ScreenUtils.w(4)),
                  Icon(
                    Icons.done_all,
                    size: ScreenUtils.sp(14),
                    color: metaColor,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    if (isMine) {
      return Align(
        alignment: Alignment.centerRight,
        child: bubble,
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          ProfileAvatar(
            url: message.senderAvatar,
            size: ScreenUtils.w(28),
          ),
          SizedBox(width: ScreenUtils.w(8)),
          bubble,
        ],
      ),
    );
  }
}

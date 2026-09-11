import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/chats/domain/entities/chat_thread.dart';
import 'package:newlane/features/profile/widgets/profile_avatar.dart';

class ChatThreadTile extends StatelessWidget {
  const ChatThreadTile({
    required this.thread,
    required this.onTap,
    super.key,
  });

  final ChatThread thread;
  final VoidCallback onTap;

  String get _timeLabel {
    final DateTime t = thread.lastMessageAt;
    final int hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final String minute = t.minute.toString().padLeft(2, '0');
    final String period = t.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtils.w(12),
            vertical: ScreenUtils.h(12),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(ScreenUtils.r(10)),
            border: Border.all(
              color: AppColors.primaryButtonBg.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _leading(),
              SizedBox(width: ScreenUtils.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            thread.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.semiBold(fontSize: 14),
                          ),
                        ),
                        SizedBox(width: ScreenUtils.w(8)),
                        Text(
                          _timeLabel,
                          style: AppTypography.regular(
                            fontSize: 11,
                            color: AppColors.mutedGrey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ScreenUtils.h(6)),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            thread.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.regular(
                              fontSize: 12,
                              color: AppColors.mutedGrey,
                            ),
                          ),
                        ),
                        if (thread.hasUnread) ...<Widget>[
                          SizedBox(width: ScreenUtils.w(8)),
                          Container(
                            constraints: BoxConstraints(
                              minWidth: ScreenUtils.w(18),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtils.w(5),
                              vertical: ScreenUtils.h(2),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryButtonBg,
                              borderRadius: BorderRadius.circular(
                                ScreenUtils.r(10),
                              ),
                            ),
                            child: Text(
                              thread.unreadCount > 9
                                  ? '9+'
                                  : '${thread.unreadCount}',
                              textAlign: TextAlign.center,
                              style: AppTypography.semiBold(
                                fontSize: 10,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leading() {
    if (thread.isAnnouncement) {
      return Container(
        width: ScreenUtils.w(48),
        height: ScreenUtils.w(48),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
          border: Border.all(
            color: AppColors.primaryButtonBg.withValues(alpha: 0.25),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.campaign_rounded,
          color: AppColors.primaryButtonBg,
          size: ScreenUtils.sp(24),
        ),
      );
    }

    return ProfileAvatar(
      url: thread.avatarUrl.isEmpty ? null : thread.avatarUrl,
      size: ScreenUtils.w(48),
    );
  }
}

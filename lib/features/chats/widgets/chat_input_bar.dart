import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';

/// Text-only composer. Attach / emoji / mic stay visual for later features.
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    required this.controller,
    required this.onChanged,
    required this.onSend,
    required this.canSend,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final bool canSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(12),
          ScreenUtils.h(8),
          ScreenUtils.w(12),
          ScreenUtils.h(10),
        ),
        child: Row(
          children: <Widget>[
            _circleIcon(Icons.add, onTap: () {}),
            SizedBox(width: ScreenUtils.w(8)),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(14)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtils.r(28)),
                  border: Border.all(color: AppColors.primaryButtonBg),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: onChanged,
                        style: AppTypography.regular(fontSize: 13),
                        cursorColor: AppColors.primaryButtonBg,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          if (canSend) onSend();
                        },
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: AppTypography.regular(
                            fontSize: 13,
                            color: AppColors.mutedGrey,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: ScreenUtils.h(12),
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.emoji_emotions_outlined,
                      color: AppColors.primaryButtonBg,
                      size: ScreenUtils.sp(22),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: ScreenUtils.w(8)),
            if (canSend)
              _circleIcon(Icons.send_rounded, onTap: onSend, filled: true)
            else
              _circleIcon(Icons.mic_none_rounded, onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon(
    IconData icon, {
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return Material(
      color: filled ? AppColors.primaryButtonBg : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: ScreenUtils.w(40),
          height: ScreenUtils.w(40),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: filled
                ? null
                : Border.all(color: AppColors.primaryButtonBg),
          ),
          child: Icon(
            icon,
            size: ScreenUtils.sp(20),
            color: filled ? AppColors.black : AppColors.primaryButtonBg,
          ),
        ),
      ),
    );
  }
}

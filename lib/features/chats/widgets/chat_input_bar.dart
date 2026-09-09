import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';

/// WhatsApp-like text composer (send when text present).
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
    return Material(
      color: const Color(0xFF121212),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            ScreenUtils.w(8),
            ScreenUtils.h(8),
            ScreenUtils.w(8),
            ScreenUtils.h(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Container(
                  constraints: BoxConstraints(minHeight: ScreenUtils.h(44)),
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(14)),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(ScreenUtils.r(24)),
                  ),
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: AppTypography.regular(fontSize: 15),
                    cursorColor: AppColors.primaryButtonBg,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) {
                      if (canSend) onSend();
                    },
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: AppTypography.regular(
                        fontSize: 15,
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
              ),
              SizedBox(width: ScreenUtils.w(8)),
              Material(
                color: AppColors.primaryButtonBg,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: canSend ? onSend : null,
                  child: SizedBox(
                    width: ScreenUtils.w(44),
                    height: ScreenUtils.w(44),
                    child: Icon(
                      Icons.send_rounded,
                      size: ScreenUtils.sp(20),
                      color: canSend
                          ? AppColors.black
                          : AppColors.black.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

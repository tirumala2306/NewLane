import 'package:flutter/material.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/chats/domain/entities/chat_filter.dart';

class ChatFilterTabs extends StatelessWidget {
  const ChatFilterTabs({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final ChatFilter selected;
  final ValueChanged<ChatFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(16)),
      child: Row(
        children: ChatFilter.values.map((ChatFilter filter) {
          final bool isSelected = filter == selected;
          return Padding(
            padding: EdgeInsets.only(right: ScreenUtils.w(10)),
            child: GestureDetector(
              onTap: () => onChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtils.w(14),
                  vertical: ScreenUtils.h(8),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryButtonBg
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  filter.label,
                  style: AppTypography.medium(
                    fontSize: 12,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.mutedGrey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/firebase/firebase_bootstrap.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/chats/bloc/conversation/conversation_bloc.dart';
import 'package:newlane/features/chats/bloc/conversation/conversation_event.dart';
import 'package:newlane/features/chats/bloc/conversation/conversation_state.dart';
import 'package:newlane/features/chats/domain/entities/chat_message.dart';
import 'package:newlane/features/chats/widgets/chat_input_bar.dart';
import 'package:newlane/features/chats/widgets/chat_message_bubble.dart';
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';
import 'package:newlane/features/profile/widgets/profile_avatar.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    required this.chatId,
    required this.title,
    this.avatarUrl = '',
    this.isAnnouncement = false,
    super.key,
  });

  final String chatId;
  final String title;
  final String avatarUrl;
  final bool isAnnouncement;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _userId(ProfileState state) {
    if (!FirebaseBootstrap.isReady) return 'me';
    if (state is ProfileLoaded) return state.profile.id.toString();
    return 'me';
  }

  String _userName(ProfileState state) {
    if (state is ProfileLoaded && state.profile.fullName.trim().isNotEmpty) {
      return state.profile.fullName.trim();
    }
    return 'You';
  }

  String _userAvatar(ProfileState state) {
    if (state is ProfileLoaded) return state.profile.avatar;
    return '';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  String _dateLabel(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(date.year, date.month, date.day);
    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ProfileState profileState = context.watch<ProfileBloc>().state;
    final String title = widget.title.trim().isEmpty ? 'Chat' : widget.title.trim();

    return BlocProvider(
      create: (_) => InjectionContainer.instance.createConversationBloc()
        ..add(
          ConversationStarted(
            chatId: widget.chatId,
            currentUserId: _userId(profileState),
            currentUserName: _userName(profileState),
            currentUserAvatar: _userAvatar(profileState),
          ),
        ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0B0B),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leadingWidth: ScreenUtils.w(40),
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: ScreenUtils.sp(18),
              color: AppColors.white,
            ),
          ),
          titleSpacing: 0,
          title: Row(
            children: <Widget>[
              if (widget.isAnnouncement)
                Container(
                  width: ScreenUtils.w(40),
                  height: ScreenUtils.w(40),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                  ),
                  child: Icon(
                    Icons.campaign_rounded,
                    color: AppColors.primaryButtonBg,
                    size: ScreenUtils.sp(20),
                  ),
                )
              else
                ProfileAvatar(
                  url: widget.avatarUrl.isEmpty ? null : widget.avatarUrl,
                  size: ScreenUtils.w(40),
                ),
              SizedBox(width: ScreenUtils.w(10)),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.semiBold(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xFF0B0B0B),
                ),
                child: BlocConsumer<ConversationBloc, ConversationState>(
                  listener: (BuildContext context, ConversationState state) {
                    if (state is ConversationReady) {
                      _scrollToBottom();
                    }
                  },
                  builder: (BuildContext context, ConversationState state) {
                    if (state is ConversationLoading ||
                        state is ConversationInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryButtonBg,
                        ),
                      );
                    }
                    if (state is ConversationFailure) {
                      return Center(
                        child: Text(
                          state.message,
                          style: AppTypography.regular(
                            color: AppColors.mutedGrey,
                          ),
                        ),
                      );
                    }
                    if (state is! ConversationReady) {
                      return const SizedBox.shrink();
                    }

                    final List<ChatMessage> messages = state.messages;
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'Say hi to $title',
                          style: AppTypography.regular(
                            fontSize: 13,
                            color: AppColors.mutedGrey,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(
                        ScreenUtils.w(10),
                        ScreenUtils.h(10),
                        ScreenUtils.w(10),
                        ScreenUtils.h(8),
                      ),
                      itemCount: messages.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: ScreenUtils.h(14),
                              top: ScreenUtils.h(4),
                            ),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtils.w(10),
                                  vertical: ScreenUtils.h(4),
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(
                                    ScreenUtils.r(6),
                                  ),
                                ),
                                child: Text(
                                  _dateLabel(messages.first.createdAt),
                                  style: AppTypography.regular(
                                    fontSize: 11,
                                    color: AppColors.mutedGrey,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final ChatMessage message = messages[index - 1];
                        return Padding(
                          padding: EdgeInsets.only(bottom: ScreenUtils.h(4)),
                          child: ChatMessageBubble(
                            message: message,
                            isMine: message.isMine(state.currentUserId),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            if (!widget.isAnnouncement)
              BlocBuilder<ConversationBloc, ConversationState>(
                builder: (BuildContext context, ConversationState state) {
                  final bool canSend =
                      state is ConversationReady && state.canSend;
                  return ChatInputBar(
                    controller: _controller,
                    canSend: canSend,
                    onChanged: (String value) {
                      context.read<ConversationBloc>().add(
                        ConversationTextChanged(value),
                      );
                    },
                    onSend: () {
                      context.read<ConversationBloc>().add(
                        const ConversationSendPressed(),
                      );
                      _controller.clear();
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

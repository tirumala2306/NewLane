import 'package:flutter/cupertino.dart';
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
    this.isOnline = false,
    this.isAnnouncement = false,
    super.key,
  });

  final String chatId;
  final String title;
  final String avatarUrl;
  final bool isOnline;
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
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  String _dateLabel(DateTime date) {
    return 'Today, ${_monthName(date.month)} ${date.day}';
  }

  String _monthName(int month) {
    const List<String> names = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final ProfileState profileState = context.watch<ProfileBloc>().state;

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
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
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
                  width: ScreenUtils.w(36),
                  height: ScreenUtils.w(36),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                  ),
                  child: Icon(
                    Icons.campaign_rounded,
                    color: AppColors.primaryButtonBg,
                    size: ScreenUtils.sp(18),
                  ),
                )
              else
                ProfileAvatar(
                  url: widget.avatarUrl,
                  size: ScreenUtils.w(36),
                  showOnline: true,
                  isOnline: widget.isOnline,
                ),
              SizedBox(width: ScreenUtils.w(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.semiBold(fontSize: 14),
                    ),
                    if (!widget.isAnnouncement) ...<Widget>[
                      SizedBox(height: ScreenUtils.h(2)),
                      Row(
                        children: <Widget>[
                          Container(
                            width: ScreenUtils.w(7),
                            height: ScreenUtils.w(7),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.isOnline
                                  ? const Color(0xFF22AF4D)
                                  : AppColors.mutedGrey,
                            ),
                          ),
                          SizedBox(width: ScreenUtils.w(5)),
                          Text(
                            widget.isOnline ? 'Online' : 'Offline',
                            style: AppTypography.regular(
                              fontSize: 11,
                              color: AppColors.mutedGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {},
              icon: Icon(
                CupertinoIcons.phone,
                color: AppColors.primaryButtonBg,
                size: ScreenUtils.sp(20),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                CupertinoIcons.videocam,
                color: AppColors.primaryButtonBg,
                size: ScreenUtils.sp(22),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_vert,
                color: AppColors.primaryButtonBg,
                size: ScreenUtils.sp(22),
              ),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
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
                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(
                      ScreenUtils.w(16),
                      ScreenUtils.h(8),
                      ScreenUtils.w(16),
                      ScreenUtils.h(12),
                    ),
                    itemCount: messages.isEmpty ? 1 : messages.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        final DateTime labelDate = messages.isNotEmpty
                            ? messages.first.createdAt
                            : DateTime.now();
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: ScreenUtils.h(16),
                            top: ScreenUtils.h(4),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(child: Divider(color: AppColors.divider)),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtils.w(10),
                                ),
                                child: Text(
                                  _dateLabel(labelDate),
                                  style: AppTypography.regular(
                                    fontSize: 11,
                                    color: AppColors.mutedGrey,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: AppColors.divider)),
                            ],
                          ),
                        );
                      }

                      final ChatMessage message = messages[index - 1];
                      return Padding(
                        padding: EdgeInsets.only(bottom: ScreenUtils.h(10)),
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

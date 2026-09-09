import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/firebase/firebase_bootstrap.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/chats/bloc/chat_list/chat_list_bloc.dart';
import 'package:newlane/features/chats/bloc/chat_list/chat_list_event.dart';
import 'package:newlane/features/chats/bloc/chat_list/chat_list_state.dart';
import 'package:newlane/features/chats/domain/entities/chat_filter.dart';
import 'package:newlane/features/chats/domain/entities/chat_thread.dart';
import 'package:newlane/features/chats/widgets/chat_filter_tabs.dart';
import 'package:newlane/features/chats/widgets/chat_thread_tile.dart';
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _searchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _resolveUserId(ProfileState profileState) {
    // Mock seed uses senderId "me" until Firebase is wired.
    if (!FirebaseBootstrap.isReady) return 'me';
    if (profileState is ProfileLoaded) {
      return profileState.profile.id.toString();
    }
    return 'me';
  }

  String _officeSubtitle(ProfileState profileState) {
    if (profileState is ProfileLoaded &&
        profileState.profile.officeName.trim().isNotEmpty) {
      return profileState.profile.officeName.trim().toUpperCase();
    }
    return 'NEWLANE';
  }

  Future<void> _seedDemoFromBackend(BuildContext context) async {
    final ProfileState profileState = context.read<ProfileBloc>().state;
    final String userId = _resolveUserId(profileState);
    try {
      final Map<String, dynamic> result = await InjectionContainer
          .instance
          .chatApiRemoteDataSource
          .seedDemo(currentUserId: userId);
      if (!context.mounted) return;
      AppSnackBar.showInfo(
        context,
        title: 'Chat seed',
        message: result.isEmpty
            ? 'Seed requested. Open Chat again if list is empty.'
            : 'Seeded ${result['dmChatId'] ?? 'chats'}',
      );
      context.read<ChatListBloc>().add(ChatListStarted(currentUserId: userId));
    } catch (error) {
      if (!context.mounted) return;
      AppSnackBar.showError(
        context,
        title: 'Chat seed failed',
        message:
            '$error — deploy backend-chat on VPS and ensure Firebase Admin key.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProfileState profileState = context.watch<ProfileBloc>().state;

    return BlocProvider(
      create: (_) => InjectionContainer.instance.createChatListBloc()
        ..add(ChatListStarted(currentUserId: _resolveUserId(profileState))),
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: AppColors.black,
            appBar: NewLaneAppBar(
              prefix: IconButton(
                onPressed: () => context.push(AppRoutes.more),
                icon: Icon(Icons.menu, size: ScreenUtils.sp(28)),
              ),
              title: 'OFFICE CHAT',
              titleFontSize: 16,
              description: _officeSubtitle(profileState),
              descriptionFontSize: 10,
              suffix: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _searchOpen = !_searchOpen;
                        if (!_searchOpen) {
                          _searchController.clear();
                          context.read<ChatListBloc>().add(
                            const ChatListSearchChanged(''),
                          );
                        }
                      });
                    },
                    icon: Icon(
                      CupertinoIcons.search,
                      color: AppColors.primaryButtonBg,
                      size: ScreenUtils.sp(22),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _seedDemoFromBackend(context),
                    tooltip: 'Seed demo chats (API)',
                    icon: Icon(
                      CupertinoIcons.square_pencil,
                      color: AppColors.primaryButtonBg,
                      size: ScreenUtils.sp(22),
                    ),
                  ),
                ],
              ),
              height: ScreenUtils.h(56),
            ),
            body: Column(
              children: <Widget>[
                if (_searchOpen)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      ScreenUtils.w(16),
                      0,
                      ScreenUtils.w(16),
                      ScreenUtils.h(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: AppTypography.regular(fontSize: 13),
                      cursorColor: AppColors.primaryButtonBg,
                      onChanged: (String value) {
                        context.read<ChatListBloc>().add(
                          ChatListSearchChanged(value),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Search chats...',
                        hintStyle: AppTypography.regular(
                          fontSize: 13,
                          color: AppColors.mutedGrey,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0D0D0D),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: ScreenUtils.w(14),
                          vertical: ScreenUtils.h(10),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(ScreenUtils.r(10)),
                          borderSide: const BorderSide(color: AppColors.glassBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(ScreenUtils.r(10)),
                          borderSide: const BorderSide(color: AppColors.glassBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(ScreenUtils.r(10)),
                          borderSide: const BorderSide(
                            color: AppColors.primaryButtonBg,
                          ),
                        ),
                      ),
                    ),
                  ),
                BlocBuilder<ChatListBloc, ChatListState>(
                  builder: (BuildContext context, ChatListState state) {
                    final ChatFilter filter = state is ChatListLoaded
                        ? state.filter
                        : ChatFilter.all;
                    return ChatFilterTabs(
                      selected: filter,
                      onChanged: (ChatFilter value) {
                        context.read<ChatListBloc>().add(
                          ChatListFilterChanged(value),
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: ScreenUtils.h(12)),
                Expanded(
                  child: BlocBuilder<ChatListBloc, ChatListState>(
                    builder: (BuildContext context, ChatListState state) {
                      if (state is ChatListLoading ||
                          state is ChatListInitial) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryButtonBg,
                          ),
                        );
                      }
                      if (state is ChatListFailure) {
                        return Center(
                          child: Text(
                            state.message,
                            style: AppTypography.regular(
                              color: AppColors.mutedGrey,
                            ),
                          ),
                        );
                      }
                      if (state is! ChatListLoaded) {
                        return const SizedBox.shrink();
                      }

                      final List<ChatThread> threads = state.visibleThreads;
                      if (threads.isEmpty) {
                        return Center(
                          child: Text(
                            'No chats yet',
                            style: AppTypography.medium(
                              color: AppColors.mutedGrey,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          ScreenUtils.w(16),
                          0,
                          ScreenUtils.w(16),
                          ScreenUtils.h(24),
                        ),
                        itemCount: threads.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            SizedBox(height: ScreenUtils.h(10)),
                        itemBuilder: (BuildContext context, int index) {
                          final ChatThread thread = threads[index];
                          return ChatThreadTile(
                            thread: thread,
                            onTap: () {
                              context.push(
                                AppRoutes.conversationWithId(thread.id),
                                extra: <String, dynamic>{
                                  'title': thread.title,
                                  'avatarUrl': thread.avatarUrl,
                                  'isOnline': thread.isOnline,
                                  'isAnnouncement': thread.isAnnouncement,
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

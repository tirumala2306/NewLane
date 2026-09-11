import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/firebase/firebase_bootstrap.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/features/chats/domain/entities/chat_thread.dart';
import 'package:newlane/features/chats/repositories/chat_repository.dart';
import 'package:newlane/features/profile/bloc/profile_bloc.dart';
import 'package:newlane/features/profile/bloc/profile_event.dart';
import 'package:newlane/features/profile/bloc/profile_state.dart';
import 'package:newlane/shared/widgets/custom_bottom_nav_bar.dart';

/// Shell that hosts tab branches with [CustomBottomNavBar].
class MainShell extends StatefulWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  StreamSubscription<List<ChatThread>>? _threadsSub;
  String _watchingUserId = '';
  int _chatUnreadTotal = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ProfileState state = context.read<ProfileBloc>().state;
      if (state is! ProfileLoaded) {
        context.read<ProfileBloc>().add(const ProfileLoadRequested());
      } else {
        _syncUnreadWatch(state);
      }
    });
  }

  @override
  void dispose() {
    unawaited(_threadsSub?.cancel());
    super.dispose();
  }

  String _userId(ProfileState state) {
    if (!FirebaseBootstrap.isReady) return 'me';
    if (state is ProfileLoaded) return state.profile.id.toString();
    return '';
  }

  void _syncUnreadWatch(ProfileState state) {
    final String userId = _userId(state);
    if (userId.isEmpty || userId == _watchingUserId) return;
    _watchingUserId = userId;
    unawaited(_threadsSub?.cancel());

    final ChatRepository repo = InjectionContainer.instance.chatRepository;
    _threadsSub = repo.watchThreads(currentUserId: userId).listen(
      (List<ChatThread> threads) {
        final int total = threads.fold<int>(
          0,
          (int sum, ChatThread t) => sum + (t.unreadCount > 0 ? t.unreadCount : 0),
        );
        if (!mounted) return;
        if (total != _chatUnreadTotal) {
          setState(() => _chatUnreadTotal = total);
        }
      },
      onError: (_) {
        if (!mounted) return;
        if (_chatUnreadTotal != 0) {
          setState(() => _chatUnreadTotal = 0);
        }
      },
    );
  }

  void _onItemSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (BuildContext context, ProfileState state) {
        if (state is ProfileLoaded) {
          _syncUnreadWatch(state);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.black,
          body: widget.navigationShell,
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: widget.navigationShell.currentIndex,
            onItemSelected: _onItemSelected,
            onCenterTap: () => context.push(AppRoutes.createPost),
            chatUnreadCount: _chatUnreadTotal,
          ),
        ),
      ),
    );
  }
}

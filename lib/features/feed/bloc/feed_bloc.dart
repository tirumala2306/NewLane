import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/feed/bloc/feed_event.dart';
import 'package:newlane/features/feed/bloc/feed_state.dart';
import 'package:newlane/features/feed/domain/entities/feed_post.dart';
import 'package:newlane/features/feed/domain/usecases/feed_usecases.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc({
    required GetFeed getFeed,
    required ToggleFeedLike toggleFeedLike,
  }) : _getFeed = getFeed,
       _toggleFeedLike = toggleFeedLike,
       super(const FeedInitial()) {
    on<FeedStarted>(_onStarted);
    on<FeedRefreshed>(_onRefreshed);
    on<FeedFilterChanged>(_onFilterChanged);
    on<FeedLikeToggled>(_onLikeToggled);
    on<FeedCommentCountBumped>(_onCommentBumped);
  }

  final GetFeed _getFeed;
  final ToggleFeedLike _toggleFeedLike;
  String _filter = 'all';

  Future<void> _onStarted(FeedStarted event, Emitter<FeedState> emit) {
    _filter = event.filter;
    return _load(emit);
  }

  Future<void> _onRefreshed(FeedRefreshed event, Emitter<FeedState> emit) {
    return _load(emit);
  }

  Future<void> _onFilterChanged(
    FeedFilterChanged event,
    Emitter<FeedState> emit,
  ) {
    _filter = event.filter;
    return _load(emit);
  }

  Future<void> _onLikeToggled(
    FeedLikeToggled event,
    Emitter<FeedState> emit,
  ) async {
    final List<FeedPost> current = _currentPosts();
    final int index = current.indexWhere((FeedPost p) => p.id == event.postId);
    if (index < 0) return;

    final FeedPost post = current[index];
    final bool nextLiked = !post.likedByMe;
    final List<FeedPost> optimistic = List<FeedPost>.from(current);
    optimistic[index] = post.copyWith(
      likedByMe: nextLiked,
      likesCount: (post.likesCount + (nextLiked ? 1 : -1)).clamp(0, 1 << 30),
    );
    emit(FeedLoaded(posts: optimistic, filter: _filter));

    final Result<FeedLikeResult> result = await _toggleFeedLike(
      ToggleFeedLikeParams(
        postId: post.id,
        currentlyLiked: post.likedByMe,
      ),
    );

    result.when(
      ok: (FeedLikeResult value) {
        final List<FeedPost> synced = List<FeedPost>.from(_currentPosts());
        final int i = synced.indexWhere((FeedPost p) => p.id == event.postId);
        if (i < 0) return;
        final int count = value.likesCount > 0
            ? value.likesCount
            : optimistic[index].likesCount;
        synced[i] = synced[i].copyWith(
          likedByMe: value.liked,
          likesCount: count,
        );
        emit(FeedLoaded(posts: synced, filter: _filter));
      },
      err: (_) {
        emit(FeedLoaded(posts: current, filter: _filter));
      },
    );
  }

  void _onCommentBumped(
    FeedCommentCountBumped event,
    Emitter<FeedState> emit,
  ) {
    final List<FeedPost> current = List<FeedPost>.from(_currentPosts());
    final int index = current.indexWhere((FeedPost p) => p.id == event.postId);
    if (index < 0) return;
    current[index] = current[index].copyWith(
      commentsCount: current[index].commentsCount + 1,
    );
    emit(FeedLoaded(posts: current, filter: _filter));
  }

  List<FeedPost> _currentPosts() {
    return switch (state) {
      FeedLoaded(:final List<FeedPost> posts) => posts,
      FeedLoading(:final List<FeedPost> previous) => previous,
      FeedFailure(:final List<FeedPost> previous) => previous,
      _ => const <FeedPost>[],
    };
  }

  Future<void> _load(Emitter<FeedState> emit) async {
    final List<FeedPost> previous = _currentPosts();
    emit(FeedLoading(previous: previous, filter: _filter));
    AppLog.line('[BLOC] feed load filter=$_filter');

    final Result<List<FeedPost>> result = await _getFeed(
      GetFeedParams(filter: _filter),
    );
    result.when(
      ok: (List<FeedPost> posts) {
        emit(FeedLoaded(posts: posts, filter: _filter));
      },
      err: (failure) {
        emit(
          FeedFailure(
            failure.message,
            previous: previous,
            filter: _filter,
          ),
        );
      },
    );
  }
}

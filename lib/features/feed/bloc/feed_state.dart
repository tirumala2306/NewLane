import 'package:equatable/equatable.dart';
import 'package:newlane/features/feed/domain/entities/feed_post.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => const <Object?>[];
}

class FeedInitial extends FeedState {
  const FeedInitial();
}

class FeedLoading extends FeedState {
  const FeedLoading({this.previous = const <FeedPost>[], this.filter = 'all'});

  final List<FeedPost> previous;
  final String filter;

  @override
  List<Object?> get props => <Object?>[previous, filter];
}

class FeedLoaded extends FeedState {
  const FeedLoaded({
    required this.posts,
    this.filter = 'all',
  });

  final List<FeedPost> posts;
  final String filter;

  @override
  List<Object?> get props => <Object?>[posts, filter];
}

class FeedFailure extends FeedState {
  const FeedFailure(
    this.message, {
    this.previous = const <FeedPost>[],
    this.filter = 'all',
  });

  final String message;
  final List<FeedPost> previous;
  final String filter;

  @override
  List<Object?> get props => <Object?>[message, previous, filter];
}

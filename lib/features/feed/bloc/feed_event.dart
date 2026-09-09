import 'package:equatable/equatable.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

class FeedStarted extends FeedEvent {
  const FeedStarted({this.filter = 'all'});

  final String filter;

  @override
  List<Object?> get props => <Object?>[filter];
}

class FeedRefreshed extends FeedEvent {
  const FeedRefreshed();
}

class FeedFilterChanged extends FeedEvent {
  const FeedFilterChanged(this.filter);

  final String filter;

  @override
  List<Object?> get props => <Object?>[filter];
}

class FeedLikeToggled extends FeedEvent {
  const FeedLikeToggled(this.postId);

  final int postId;

  @override
  List<Object?> get props => <Object?>[postId];
}

class FeedCommentCountBumped extends FeedEvent {
  const FeedCommentCountBumped(this.postId);

  final int postId;

  @override
  List<Object?> get props => <Object?>[postId];
}

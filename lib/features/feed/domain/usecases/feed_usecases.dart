import 'package:equatable/equatable.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/feed/domain/entities/feed_post.dart';
import 'package:newlane/features/feed/repositories/feed_repository.dart';

class GetFeed implements UseCase<Result<List<FeedPost>>, GetFeedParams> {
  const GetFeed(this._repository);

  final FeedRepository _repository;

  @override
  Future<Result<List<FeedPost>>> call(GetFeedParams params) {
    return _repository.getFeed(filter: params.filter);
  }
}

class GetFeedParams extends Equatable {
  const GetFeedParams({this.filter = 'all'});

  final String filter;

  @override
  List<Object?> get props => <Object?>[filter];
}

class ToggleFeedLike
    implements UseCase<Result<FeedLikeResult>, ToggleFeedLikeParams> {
  const ToggleFeedLike(this._repository);

  final FeedRepository _repository;

  @override
  Future<Result<FeedLikeResult>> call(ToggleFeedLikeParams params) {
    return _repository.toggleLike(
      postId: params.postId,
      currentlyLiked: params.currentlyLiked,
    );
  }
}

class ToggleFeedLikeParams extends Equatable {
  const ToggleFeedLikeParams({
    required this.postId,
    required this.currentlyLiked,
  });

  final int postId;
  final bool currentlyLiked;

  @override
  List<Object?> get props => <Object?>[postId, currentlyLiked];
}

class GetFeedComments
    implements UseCase<Result<List<FeedComment>>, GetFeedCommentsParams> {
  const GetFeedComments(this._repository);

  final FeedRepository _repository;

  @override
  Future<Result<List<FeedComment>>> call(GetFeedCommentsParams params) {
    return _repository.getComments(params.postId);
  }
}

class GetFeedCommentsParams extends Equatable {
  const GetFeedCommentsParams(this.postId);

  final int postId;

  @override
  List<Object?> get props => <Object?>[postId];
}

class AddFeedComment
    implements UseCase<Result<FeedComment>, AddFeedCommentParams> {
  const AddFeedComment(this._repository);

  final FeedRepository _repository;

  @override
  Future<Result<FeedComment>> call(AddFeedCommentParams params) {
    return _repository.addComment(postId: params.postId, text: params.text);
  }
}

class AddFeedCommentParams extends Equatable {
  const AddFeedCommentParams({required this.postId, required this.text});

  final int postId;
  final String text;

  @override
  List<Object?> get props => <Object?>[postId, text];
}

class CreateFeedPost
    implements UseCase<Result<FeedPost>, CreateFeedPostParams> {
  const CreateFeedPost(this._repository);

  final FeedRepository _repository;

  @override
  Future<Result<FeedPost>> call(CreateFeedPostParams params) {
    return _repository.createPost(
      caption: params.caption,
      postType: params.postType,
      visibility: params.visibility,
      mediaPaths: params.mediaPaths,
    );
  }
}

class CreateFeedPostParams extends Equatable {
  const CreateFeedPostParams({
    required this.caption,
    required this.postType,
    required this.visibility,
    this.mediaPaths = const <String>[],
  });

  final String caption;
  final String postType;
  final String visibility;
  final List<String> mediaPaths;

  @override
  List<Object?> get props =>
      <Object?>[caption, postType, visibility, mediaPaths];
}

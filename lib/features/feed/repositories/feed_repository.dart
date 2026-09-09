import 'package:newlane/core/errors/result.dart';
import 'package:newlane/features/feed/domain/entities/feed_post.dart';

abstract class FeedRepository {
  Future<Result<List<FeedPost>>> getFeed({String filter = 'all'});

  Future<Result<FeedPost>> getPostById(int postId);

  Future<Result<FeedLikeResult>> toggleLike({
    required int postId,
    required bool currentlyLiked,
  });

  Future<Result<List<FeedComment>>> getComments(int postId);

  Future<Result<FeedComment>> addComment({
    required int postId,
    required String text,
  });

  Future<Result<FeedPost>> createPost({
    required String caption,
    required String postType,
    required String visibility,
    List<String> mediaPaths = const <String>[],
  });
}

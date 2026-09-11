import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/feed/data/datasources/feed_remote_data_source.dart';
import 'package:newlane/features/feed/domain/entities/feed_post.dart';
import 'package:newlane/features/feed/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  const FeedRepositoryImpl({required FeedRemoteDataSource remote})
    : _remote = remote;

  final FeedRemoteDataSource _remote;

  @override
  Future<Result<List<FeedPost>>> getFeed({String filter = 'all'}) {
    return _guard(() async {
      final model = await _remote.getFeed(filter: filter);
      return model.toEntities();
    });
  }

  @override
  Future<Result<FeedPost>> getPostById(int postId) {
    return _guard(() async {
      final model = await _remote.getPostById(postId);
      return model.toEntity();
    });
  }

  @override
  Future<Result<FeedLikeResult>> toggleLike({
    required int postId,
    required bool currentlyLiked,
  }) {
    return _guard(() async {
      final model = await _remote.toggleLike(
        postId,
        currentlyLiked: currentlyLiked,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Result<List<FeedComment>>> getComments(int postId) {
    return _guard(() async {
      final model = await _remote.getComments(postId);
      return model.toEntities();
    });
  }

  @override
  Future<Result<FeedComment>> addComment({
    required int postId,
    required String text,
  }) {
    return _guard(() async {
      final model = await _remote.addComment(postId: postId, text: text);
      return model.toEntity();
    });
  }

  @override
  Future<Result<FeedPost>> createPost({
    required String caption,
    required String postType,
    required String visibility,
    List<String> mediaPaths = const <String>[],
    String locationLabel = '',
    String price = '',
    List<int> taggedUserIds = const <int>[],
    int? officeId,
  }) {
    return _guard(() async {
      final model = await _remote.createPost(
        caption: caption,
        postType: postType,
        visibility: visibility,
        mediaPaths: mediaPaths,
        locationLabel: locationLabel,
        price: price,
        taggedUserIds: taggedUserIds,
        officeId: officeId,
      );
      return model.toEntity();
    });
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Ok<T>(await action());
    } on ValidationException catch (error) {
      return Err<T>(ValidationFailure(error.message));
    } on NetworkException catch (error) {
      return Err<T>(NetworkFailure(error.message));
    } on ServerException catch (error) {
      return Err<T>(ServerFailure(error.message, statusCode: error.statusCode));
    } catch (error) {
      AppLog.line('[REPO] feed UNKNOWN error: $error');
      return Err<T>(
        const UnknownFailure('Something went wrong. Please try again.'),
      );
    }
  }
}

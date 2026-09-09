import 'package:dio/dio.dart';
import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/network/api_client.dart';
import 'package:newlane/core/network/api_endpoints.dart';
import 'package:newlane/core/network/api_envelope.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/features/feed/models/feed_post_model.dart';

abstract class FeedRemoteDataSource {
  Future<FeedPostListModel> getFeed({String filter = 'all'});

  Future<FeedPostModel> getPostById(int postId);

  Future<FeedLikeResultModel> toggleLike(int postId, {required bool currentlyLiked});

  Future<FeedCommentListModel> getComments(int postId);

  Future<FeedCommentModel> addComment({
    required int postId,
    required String text,
  });

  Future<FeedPostModel> createPost({
    required String caption,
    required String postType,
    required String visibility,
    List<String> mediaPaths = const <String>[],
  });
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  const FeedRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<FeedPostListModel> getFeed({String filter = 'all'}) async {
    AppLog.line('[DATA SOURCE] GET ${ApiEndpoints.feed}?filter=$filter');
    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.feed,
      queryParameters: <String, dynamic>{'filter': filter},
    );
    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    return FeedPostListModel.fromEnvelope(envelope.data);
  }

  @override
  Future<FeedPostModel> getPostById(int postId) async {
    final String path = ApiEndpoints.feedById(postId);
    AppLog.line('[DATA SOURCE] GET $path');
    final response = await _apiClient.get<dynamic>(path);
    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    final Object? raw = envelope.data;
    final Map<String, dynamic> map;
    if (raw is Map) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(raw);
      final Object? nested = data['post'] ?? data['feed'];
      map = nested is Map ? Map<String, dynamic>.from(nested) : data;
    } else {
      map = <String, dynamic>{};
    }
    return FeedPostModel.fromJson(map);
  }

  @override
  Future<FeedLikeResultModel> toggleLike(
    int postId, {
    required bool currentlyLiked,
  }) async {
    final String path = ApiEndpoints.feedLike(postId);
    AppLog.line('[DATA SOURCE] POST $path');
    final response = await _apiClient.post<dynamic>(path);
    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    return FeedLikeResultModel.fromEnvelope(
      envelope.data,
      fallbackLiked: !currentlyLiked,
    );
  }

  @override
  Future<FeedCommentListModel> getComments(int postId) async {
    final String path = ApiEndpoints.feedComments(postId);
    AppLog.line('[DATA SOURCE] GET $path');
    final response = await _apiClient.get<dynamic>(path);
    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    return FeedCommentListModel.fromEnvelope(envelope.data);
  }

  @override
  Future<FeedCommentModel> addComment({
    required int postId,
    required String text,
  }) async {
    final String path = ApiEndpoints.feedComments(postId);
    AppLog.line('[DATA SOURCE] POST $path');
    final response = await _apiClient.post<dynamic>(
      path,
      data: <String, dynamic>{'text': text.trim(), 'comment': text.trim()},
    );
    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    final Object? raw = envelope.data;
    if (raw is Map) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(raw);
      final Object? nested = data['comment'] ?? data['item'];
      final Map<String, dynamic> map = nested is Map
          ? Map<String, dynamic>.from(nested)
          : data;
      return FeedCommentModel.fromJson(map);
    }
    return FeedCommentModel(
      id: 0,
      text: text.trim(),
      authorName: 'You',
    );
  }

  @override
  Future<FeedPostModel> createPost({
    required String caption,
    required String postType,
    required String visibility,
    List<String> mediaPaths = const <String>[],
  }) async {
    AppLog.line('[DATA SOURCE] POST ${ApiEndpoints.feed}');
    final FormData formData = FormData();
    formData.fields.addAll(<MapEntry<String, String>>[
      MapEntry<String, String>('caption', caption.trim()),
      MapEntry<String, String>('postType', postType),
      MapEntry<String, String>('visibility', visibility),
    ]);

    for (final String path in mediaPaths) {
      final String trimmed = path.trim();
      if (trimmed.isEmpty) continue;
      final String fileName = trimmed.split(RegExp(r'[\\/]')).last;
      formData.files.add(
        MapEntry<String, MultipartFile>(
          'media',
          await MultipartFile.fromFile(trimmed, filename: fileName),
        ),
      );
    }

    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.feed,
      data: formData,
    );
    final ApiEnvelope envelope = _requireSuccess(
      response.data,
      response.statusCode,
    );
    final Object? raw = envelope.data;
    if (raw is Map) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(raw);
      final Object? nested = data['post'] ?? data['feed'];
      final Map<String, dynamic> map = nested is Map
          ? Map<String, dynamic>.from(nested)
          : data;
      return FeedPostModel.fromJson(map);
    }
    return FeedPostModel(
      id: 0,
      caption: caption,
      authorName: 'You',
      postType: postType,
      visibility: visibility,
    );
  }

  ApiEnvelope _requireSuccess(dynamic data, int? statusCode) {
    final ApiEnvelope envelope = ApiEnvelope.from(data);
    if (!envelope.success) {
      throw ServerException(
        envelope.message.isEmpty ? 'Request failed.' : envelope.message,
        statusCode: statusCode,
      );
    }
    return envelope;
  }
}

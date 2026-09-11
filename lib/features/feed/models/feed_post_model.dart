import 'package:newlane/core/utils/media_url.dart';
import 'package:newlane/features/feed/domain/entities/feed_post.dart';

class FeedPostModel {
  const FeedPostModel({
    required this.id,
    required this.caption,
    required this.authorName,
    this.authorId = 0,
    this.authorAvatar = '',
    this.officeLabel = '',
    this.postType = '',
    this.visibility = 'All',
    this.imageUrl = '',
    this.mediaUrls = const <String>[],
    this.locationLabel = '',
    this.likesCount = 0,
    this.commentsCount = 0,
    this.likedByMe = false,
    this.createdAt,
  });

  factory FeedPostModel.fromJson(Map<String, dynamic> json) {
    final Object? authorRaw = json['author'] ?? json['agent'] ?? json['user'];
    final Map<String, dynamic> author = authorRaw is Map
        ? Map<String, dynamic>.from(authorRaw)
        : <String, dynamic>{};

    final List<String> media = _asUrlList(
      json['media'] ?? json['mediaUrls'] ?? json['images'] ?? json['files'],
    );
    final String image =
        (json['imageUrl'] ??
                json['image'] ??
                json['thumbnail'] ??
                (media.isNotEmpty ? media.first : ''))
            .toString();

    return FeedPostModel(
      id: _asInt(json['id'] ?? json['_id']),
      caption: (json['caption'] ?? json['text'] ?? json['content'] ?? '')
          .toString(),
      authorName:
          (json['authorName'] ??
                  author['fullName'] ??
                  author['name'] ??
                  'Agent')
              .toString(),
      authorId: _asInt(
        json['authorId'] ??
            json['author_id'] ??
            json['userId'] ??
            json['user_id'] ??
            author['id'],
      ),
      authorAvatar: resolveMediaUrl(
            (json['authorAvatar'] ??
                    author['avatar'] ??
                    author['avatarUrl'] ??
                    '')
                .toString(),
          ) ??
          '',
      officeLabel: _asOfficeLabel(
        json['officeName'] ??
            json['office'] ??
            author['officeName'] ??
            author['office'],
      ),
      postType: (json['postType'] ?? json['type'] ?? '').toString(),
      visibility: (json['visibility'] ?? json['shareTo'] ?? 'All').toString(),
      imageUrl: resolveMediaUrl(image) ?? '',
      mediaUrls: media
          .map((String u) => resolveMediaUrl(u) ?? u)
          .where((String u) => u.isNotEmpty)
          .toList(),
      locationLabel: _asLocationLabel(
        json['locationLabel'] ??
            json['location'] ??
            json['address'] ??
            json['place'],
      ),
      likesCount: _asInt(
        json['likesCount'] ?? json['likes'] ?? json['likeCount'],
      ),
      commentsCount: _asInt(
        json['commentsCount'] ?? json['comments'] ?? json['commentCount'],
      ),
      likedByMe:
          json['likedByMe'] == true ||
          json['isLiked'] == true ||
          json['liked'] == true,
      createdAt: _asDate(
        json['createdAt'] ?? json['created_at'] ?? json['postedAt'],
      ),
    );
  }

  final int id;
  final String caption;
  final String authorName;
  final int authorId;
  final String authorAvatar;
  final String officeLabel;
  final String postType;
  final String visibility;
  final String imageUrl;
  final List<String> mediaUrls;
  final String locationLabel;
  final int likesCount;
  final int commentsCount;
  final bool likedByMe;
  final DateTime? createdAt;

  FeedPost toEntity() {
    return FeedPost(
      id: id,
      caption: caption,
      authorName: authorName,
      authorId: authorId,
      authorAvatar: authorAvatar,
      officeLabel: officeLabel,
      postType: postType,
      visibility: visibility,
      imageUrl: imageUrl,
      mediaUrls: mediaUrls,
      locationLabel: locationLabel,
      likesCount: likesCount,
      commentsCount: commentsCount,
      likedByMe: likedByMe,
      createdAt: createdAt,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value'.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
  }

  /// API sometimes returns office as `{id, name}` — never use Map.toString().
  static String _asOfficeLabel(dynamic value) {
    if (value == null) return '';
    if (value is String) {
      final String t = value.trim();
      if (t.isEmpty || t.startsWith('{')) return '';
      return t;
    }
    if (value is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(value);
      return (map['name'] ??
              map['officeName'] ??
              map['title'] ??
              map['label'] ??
              '')
          .toString()
          .trim();
    }
    return '';
  }

  static String _asLocationLabel(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(value);
      return (map['address'] ??
              map['label'] ??
              map['name'] ??
              map['formatted'] ??
              '')
          .toString()
          .trim();
    }
    return '';
  }

  static DateTime? _asDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static List<String> _asUrlList(dynamic raw) {
    if (raw is! List) return const <String>[];
    return raw
        .map((Object? item) {
          if (item is String) return item;
          if (item is Map) {
            return (item['url'] ?? item['path'] ?? item['src'] ?? '').toString();
          }
          return '';
        })
        .where((String url) => url.trim().isNotEmpty)
        .toList();
  }
}

class FeedPostListModel {
  const FeedPostListModel({required this.posts});

  factory FeedPostListModel.fromEnvelope(dynamic data) {
    final List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? raw =
          map['posts'] ?? map['items'] ?? map['feed'] ?? map['data'];
      list = raw is List ? raw : const <dynamic>[];
    } else {
      list = const <dynamic>[];
    }

    return FeedPostListModel(
      posts: list
          .whereType<Map>()
          .map(
            (Map item) =>
                FeedPostModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  final List<FeedPostModel> posts;

  List<FeedPost> toEntities() =>
      posts.map((FeedPostModel e) => e.toEntity()).toList();
}

class FeedCommentModel {
  const FeedCommentModel({
    required this.id,
    required this.text,
    required this.authorName,
    this.authorAvatar = '',
    this.createdAt,
  });

  factory FeedCommentModel.fromJson(Map<String, dynamic> json) {
    final Object? authorRaw = json['author'] ?? json['agent'] ?? json['user'];
    final Map<String, dynamic> author = authorRaw is Map
        ? Map<String, dynamic>.from(authorRaw)
        : <String, dynamic>{};

    return FeedCommentModel(
      id: FeedPostModel._asInt(json['id'] ?? json['_id']),
      text: (json['text'] ?? json['comment'] ?? json['body'] ?? '').toString(),
      authorName:
          (json['authorName'] ??
                  author['fullName'] ??
                  author['name'] ??
                  'Agent')
              .toString(),
      authorAvatar: resolveMediaUrl(
            (json['authorAvatar'] ?? author['avatar'] ?? '').toString(),
          ) ??
          '',
      createdAt: FeedPostModel._asDate(json['createdAt'] ?? json['created_at']),
    );
  }

  final int id;
  final String text;
  final String authorName;
  final String authorAvatar;
  final DateTime? createdAt;

  FeedComment toEntity() {
    return FeedComment(
      id: id,
      text: text,
      authorName: authorName,
      authorAvatar: authorAvatar,
      createdAt: createdAt,
    );
  }
}

class FeedCommentListModel {
  const FeedCommentListModel({required this.comments});

  factory FeedCommentListModel.fromEnvelope(dynamic data) {
    final List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? raw = map['comments'] ?? map['items'] ?? map['data'];
      list = raw is List ? raw : const <dynamic>[];
    } else {
      list = const <dynamic>[];
    }

    return FeedCommentListModel(
      comments: list
          .whereType<Map>()
          .map(
            (Map item) =>
                FeedCommentModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  final List<FeedCommentModel> comments;

  List<FeedComment> toEntities() =>
      comments.map((FeedCommentModel e) => e.toEntity()).toList();
}

class FeedLikeResultModel {
  const FeedLikeResultModel({
    required this.liked,
    required this.likesCount,
  });

  factory FeedLikeResultModel.fromEnvelope(dynamic data, {bool? fallbackLiked}) {
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? nested = map['post'] ?? map['feed'];
      final Map<String, dynamic> source = nested is Map
          ? Map<String, dynamic>.from(nested)
          : map;
      return FeedLikeResultModel(
        liked:
            source['likedByMe'] == true ||
            source['isLiked'] == true ||
            source['liked'] == true ||
            (fallbackLiked ?? false),
        likesCount: FeedPostModel._asInt(
          source['likesCount'] ?? source['likes'] ?? source['likeCount'],
        ),
      );
    }
    return FeedLikeResultModel(
      liked: fallbackLiked ?? true,
      likesCount: 0,
    );
  }

  final bool liked;
  final int likesCount;

  FeedLikeResult toEntity() =>
      FeedLikeResult(liked: liked, likesCount: likesCount);
}

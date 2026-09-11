class FeedPost {
  const FeedPost({
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

  String get timeAgo {
    final DateTime? date = createdAt;
    if (date == null) return '';
    final Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  FeedPost copyWith({
    int? likesCount,
    int? commentsCount,
    bool? likedByMe,
  }) {
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
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      likedByMe: likedByMe ?? this.likedByMe,
      createdAt: createdAt,
    );
  }
}

class FeedComment {
  const FeedComment({
    required this.id,
    required this.text,
    required this.authorName,
    this.authorAvatar = '',
    this.createdAt,
  });

  final int id;
  final String text;
  final String authorName;
  final String authorAvatar;
  final DateTime? createdAt;
}

class FeedLikeResult {
  const FeedLikeResult({
    required this.liked,
    required this.likesCount,
  });

  final bool liked;
  final int likesCount;
}

import 'package:newlane/core/errors/exceptions.dart';
import 'package:newlane/core/errors/failures.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/core/utils/media_url.dart';
import 'package:newlane/features/feed/domain/entities/feed_post.dart';
import 'package:newlane/features/feed/repositories/feed_repository.dart';
import 'package:newlane/features/listings/domain/entities/active_listing.dart';
import 'package:newlane/features/listings/repositories/listings_repository.dart';

class ListingsRepositoryImpl implements ListingsRepository {
  const ListingsRepositoryImpl({required FeedRepository feedRepository})
      : _feed = feedRepository;

  final FeedRepository _feed;

  @override
  Future<Result<List<ActiveListing>>> getMyActiveListings({
    required int currentUserId,
    required String currentUserName,
  }) async {
    try {
      final Result<List<FeedPost>> mine = await _feed.getFeed(filter: 'mine');
      bool fromMineFeed = false;
      List<FeedPost> posts = <FeedPost>[];

      if (mine is Ok<List<FeedPost>> && mine.value.isNotEmpty) {
        posts = mine.value;
        fromMineFeed = true;
      } else {
        final Result<List<FeedPost>> all = await _feed.getFeed(filter: 'all');
        if (all is Err<List<FeedPost>>) {
          return Err<List<ActiveListing>>(all.failure);
        }
        posts = (all as Ok<List<FeedPost>>).value;
      }

      return Ok<List<ActiveListing>>(
        _toListings(
          posts,
          agentId: currentUserId,
          agentName: currentUserName,
          fromMineFeed: fromMineFeed,
        ),
      );
    } on ServerException catch (e) {
      return Err<List<ActiveListing>>(
        ServerFailure(e.message, statusCode: e.statusCode),
      );
    } on NetworkException catch (e) {
      return Err<List<ActiveListing>>(NetworkFailure(e.message));
    } catch (e) {
      AppLog.line('[LISTINGS] $e');
      return const Err<List<ActiveListing>>(
        UnknownFailure('Could not load listings.'),
      );
    }
  }

  @override
  Future<Result<List<ActiveListing>>> getActiveListingsForAgent({
    required int agentId,
    required String agentName,
  }) async {
    try {
      final Result<List<FeedPost>> result = await _feed.getFeed(filter: 'all');
      if (result is Err<List<FeedPost>>) {
        return Err<List<ActiveListing>>(result.failure);
      }
      final List<ActiveListing> listings = _toListings(
        (result as Ok<List<FeedPost>>).value,
        agentId: agentId,
        agentName: agentName,
        fromMineFeed: false,
      );
      AppLog.line(
        '[LISTINGS] agent=$agentId name="$agentName" found=${listings.length}',
      );
      return Ok<List<ActiveListing>>(listings);
    } on ServerException catch (e) {
      return Err<List<ActiveListing>>(
        ServerFailure(e.message, statusCode: e.statusCode),
      );
    } on NetworkException catch (e) {
      return Err<List<ActiveListing>>(NetworkFailure(e.message));
    } catch (e) {
      AppLog.line('[LISTINGS] $e');
      return const Err<List<ActiveListing>>(
        UnknownFailure('Could not load listings.'),
      );
    }
  }

  List<ActiveListing> _toListings(
    List<FeedPost> posts, {
    required int agentId,
    required String agentName,
    bool fromMineFeed = false,
  }) {
    final String nameKey = agentName.trim().toLowerCase();
    final List<ActiveListing> listings = <ActiveListing>[];

    for (final FeedPost post in posts) {
      if (!_isListingPost(post)) continue;
      if (!_isAuthoredBy(post, agentId: agentId, nameKey: nameKey, fromMineFeed: fromMineFeed)) {
        continue;
      }

      final String rawImage = post.imageUrl.isNotEmpty
          ? post.imageUrl
          : (post.mediaUrls.isNotEmpty ? post.mediaUrls.first : '');
      final String image = resolveMediaUrl(rawImage) ?? rawImage;

      listings.add(
        activeListingFromFeedParts(
          postId: post.id,
          caption: post.caption,
          imageUrl: image,
          locationLabel: post.locationLabel,
          authorName: post.authorName,
        ),
      );
    }

    return listings;
  }

  bool _isListingPost(FeedPost post) {
    final String type = post.postType.trim().toLowerCase();
    return type == 'listing' || type == 'listings';
  }

  bool _isAuthoredBy(
    FeedPost post, {
    required int agentId,
    required String nameKey,
    required bool fromMineFeed,
  }) {
    final bool byId = agentId > 0 && post.authorId == agentId;
    final String author = post.authorName.trim().toLowerCase();
    final bool byExactName = nameKey.isNotEmpty && author == nameKey;
    final bool byLooseName = nameKey.isNotEmpty &&
        author.isNotEmpty &&
        (author.contains(nameKey) || nameKey.contains(author));

    if (fromMineFeed) {
      if (post.authorId > 0 && agentId > 0 && !byId) return false;
      return true;
    }

    if (byId) return true;
    if (post.authorId > 0 && agentId > 0) return false;
    return byExactName || byLooseName;
  }
}

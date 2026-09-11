import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';

class MarketingRequestModel {
  const MarketingRequestModel({
    required this.id,
    required this.requestType,
    required this.listingAddress,
    required this.listingPrice,
    required this.notes,
    required this.status,
    this.listingTitle = '',
    this.thumbnailUrl = '',
    this.createdAt,
    this.mediaUrls = const <String>[],
    this.finalFiles = const <MarketingRequestFile>[],
  });

  factory MarketingRequestModel.fromJson(Map<String, dynamic> json) {
    final Object? listingRaw = json['listing'] ?? json['project'];
    final Map<String, dynamic> listing = listingRaw is Map
        ? Map<String, dynamic>.from(listingRaw)
        : <String, dynamic>{};

    final String address =
        (json['listingAddress'] ??
                json['address'] ??
                listing['address'] ??
                '')
            .toString();
    final int price = _asInt(
      json['listingPrice'] ?? json['price'] ?? listing['price'],
    );
    final String title =
        (json['listingTitle'] ??
                json['propertyTitle'] ??
                listing['title'] ??
                listing['name'] ??
                '')
            .toString();

    return MarketingRequestModel(
      id: _asInt(json['id'] ?? json['_id']),
      requestType: MarketingRequestType.fromLabel(
        (json['requestType'] ?? json['type'] ?? '').toString(),
      ),
      listingAddress: address,
      listingPrice: price,
      notes: (json['notes'] ?? json['instructions'] ?? '').toString(),
      status: MarketingRequestStatus.fromRaw(
        (json['status'] ??
                json['state'] ??
                json['requestStatus'] ??
                json['request_status'] ??
                '')
            .toString(),
      ),
      listingTitle: title,
      thumbnailUrl: (json['thumbnail'] ??
              json['thumbnailUrl'] ??
              json['image'] ??
              listing['image'] ??
              listing['thumbnail'] ??
              '')
          .toString(),
      createdAt: _asDate(
        json['createdAt'] ?? json['requestedAt'] ?? json['created_at'],
      ),
      mediaUrls: _asUrlList(json['media'] ?? json['mediaUrls'] ?? json['files']),
      finalFiles: _asFiles(
        json['finalFiles'] ?? json['deliverables'] ?? json['outputs'],
      ),
    );
  }

  final int id;
  final MarketingRequestType requestType;
  final String listingAddress;
  final int listingPrice;
  final String notes;
  final MarketingRequestStatus status;
  final String listingTitle;
  final String thumbnailUrl;
  final DateTime? createdAt;
  final List<String> mediaUrls;
  final List<MarketingRequestFile> finalFiles;

  MarketingRequest toEntity() {
    return MarketingRequest(
      id: id,
      requestType: requestType,
      listingAddress: listingAddress,
      listingPrice: listingPrice,
      notes: notes,
      status: status,
      listingTitle: listingTitle,
      thumbnailUrl: thumbnailUrl,
      createdAt: createdAt,
      mediaUrls: mediaUrls,
      finalFiles: finalFiles,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    final String raw = '$value'.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ?? 0;
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
            return (item['url'] ?? item['path'] ?? '').toString();
          }
          return '';
        })
        .where((String url) => url.trim().isNotEmpty)
        .toList();
  }

  static List<MarketingRequestFile> _asFiles(dynamic raw) {
    if (raw is! List) return const <MarketingRequestFile>[];
    return raw
        .map((Object? item) {
          if (item is String) {
            final String url = item.trim();
            return MarketingRequestFile(
              name: url.split('/').last,
              url: url,
            );
          }
          if (item is Map) {
            final Map<String, dynamic> map = Map<String, dynamic>.from(item);
            final String url = (map['url'] ?? map['path'] ?? '').toString();
            final String name =
                (map['name'] ?? map['fileName'] ?? url.split('/').last)
                    .toString();
            return MarketingRequestFile(name: name, url: url);
          }
          return const MarketingRequestFile(name: '', url: '');
        })
        .where((MarketingRequestFile file) => file.url.trim().isNotEmpty)
        .toList();
  }
}

class MarketingRequestSubmitModel {
  const MarketingRequestSubmitModel({
    required this.message,
    this.request,
  });

  factory MarketingRequestSubmitModel.fromEnvelope({
    required String message,
    required dynamic data,
  }) {
    MarketingRequestModel? request;
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? nested = map['request'] ?? map['marketingRequest'];
      if (nested is Map) {
        request = MarketingRequestModel.fromJson(
          Map<String, dynamic>.from(nested),
        );
      } else if (map['id'] != null || map['requestType'] != null) {
        request = MarketingRequestModel.fromJson(map);
      }
    }
    return MarketingRequestSubmitModel(message: message, request: request);
  }

  final String message;
  final MarketingRequestModel? request;

  MarketingRequestSubmitResult toEntity() {
    return MarketingRequestSubmitResult(
      message: message,
      request: request?.toEntity(),
    );
  }
}

class MarketingRequestListModel {
  const MarketingRequestListModel({required this.requests});

  factory MarketingRequestListModel.fromEnvelope(dynamic data) {
    final List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? raw = map['requests'] ??
          map['items'] ??
          map['marketingRequests'] ??
          map['marketing_requests'] ??
          map['results'] ??
          map['rows'] ??
          map['data'];
      if (raw is List) {
        list = raw;
      } else if (raw is Map) {
        final Map<String, dynamic> nested = Map<String, dynamic>.from(raw);
        final Object? nestedList = nested['requests'] ??
            nested['items'] ??
            nested['marketingRequests'] ??
            nested['marketing_requests'];
        list = nestedList is List ? nestedList : const <dynamic>[];
      } else {
        list = const <dynamic>[];
      }
    } else {
      list = const <dynamic>[];
    }

    final List<MarketingRequestModel> requests = list
        .whereType<Map>()
        .map(
          (Map item) =>
              MarketingRequestModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();

    return MarketingRequestListModel(requests: requests);
  }

  final List<MarketingRequestModel> requests;

  List<MarketingRequest> toEntities() =>
      requests.map((MarketingRequestModel e) => e.toEntity()).toList();
}

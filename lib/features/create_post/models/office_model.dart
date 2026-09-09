import 'package:newlane/features/create_post/domain/entities/office.dart';

class OfficeModel {
  const OfficeModel({
    required this.id,
    required this.name,
    this.city = '',
    this.state = '',
    this.address = '',
  });

  factory OfficeModel.fromJson(Map<String, dynamic> json) {
    return OfficeModel(
      id: _asInt(json['id'] ?? json['_id']),
      name: (json['name'] ?? json['officeName'] ?? json['title'] ?? '')
          .toString()
          .trim(),
      city: (json['city'] ?? '').toString().trim(),
      state: (json['state'] ?? json['region'] ?? '').toString().trim(),
      address: (json['address'] ?? json['fullAddress'] ?? '')
          .toString()
          .trim(),
    );
  }

  final int id;
  final String name;
  final String city;
  final String state;
  final String address;

  Office toEntity() {
    return Office(
      id: id,
      name: name,
      city: city,
      state: state,
      address: address,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}

class OfficesPageModel {
  const OfficesPageModel({required this.offices});

  factory OfficesPageModel.fromEnvelope(dynamic data) {
    final Map<String, dynamic> map = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};

    final Object? raw = map['offices'] ?? map['items'] ?? data;
    final List<dynamic> list = raw is List ? raw : const <dynamic>[];

    final List<OfficeModel> offices = list
        .whereType<Map>()
        .map(
          (Map item) => OfficeModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((OfficeModel o) => o.id > 0 && o.name.isNotEmpty)
        .toList();

    return OfficesPageModel(offices: offices);
  }

  final List<OfficeModel> offices;

  List<Office> toEntities() =>
      offices.map((OfficeModel o) => o.toEntity()).toList();
}

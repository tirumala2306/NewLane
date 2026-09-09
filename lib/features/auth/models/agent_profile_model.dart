import 'package:newlane/features/auth/domain/entities/agent_profile.dart';

class AgentProfileModel {
  const AgentProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.jobTitle,
    required this.bio,
    required this.instagram,
    required this.avatar,
    required this.status,
    this.website = '',
    this.role = '',
    this.officeId = 0,
    this.officeName = '',
    this.specialties = const <String>[],
  });

  factory AgentProfileModel.fromEnvelope({required dynamic data}) {
    final Map<String, dynamic> map = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};

    // GET /api/agents/me may nest under `user` or return user fields directly.
    final Object? userRaw = map['user'];
    final Map<String, dynamic> user = userRaw is Map
        ? Map<String, dynamic>.from(userRaw)
        : map;

    final Object? specialtiesRaw = user['specialties'];
    final List<String> specialties = specialtiesRaw is List
        ? specialtiesRaw.map((Object? e) => e.toString()).toList()
        : const <String>[];

    return AgentProfileModel(
      id: _asInt(user['id'] ?? user['_id']),
      fullName: user['fullName']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      phone: user['phone']?.toString() ?? '',
      jobTitle: user['jobTitle']?.toString() ?? '',
      bio: user['bio']?.toString() ?? '',
      instagram: user['instagram']?.toString() ?? '',
      website: user['website']?.toString() ?? '',
      avatar: user['avatar']?.toString() ?? '',
      status: user['status']?.toString() ?? '',
      role: user['role']?.toString() ?? '',
      officeId: _officeId(user),
      officeName: _officeName(user),
      specialties: specialties,
    );
  }

  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String jobTitle;
  final String bio;
  final String instagram;
  final String website;
  final String avatar;
  final String status;
  final String role;
  final int officeId;
  final String officeName;
  final List<String> specialties;

  AgentProfile toEntity() {
    return AgentProfile(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      jobTitle: jobTitle,
      bio: bio,
      instagram: instagram,
      website: website,
      avatar: avatar,
      status: status,
      role: role,
      officeId: officeId,
      officeName: officeName,
      specialties: specialties,
    );
  }

  static int _officeId(Map<String, dynamic> user) {
    final int fromDirect = _asInt(
      user['officeId'] ?? user['office_id'] ?? user['assignedOfficeId'],
    );
    if (fromDirect > 0) return fromDirect;

    final Object? officeRaw =
        user['office'] ?? user['assignedOffice'] ?? user['assigned_office'];
    if (officeRaw is Map) {
      final int id = _asInt(officeRaw['id'] ?? officeRaw['_id']);
      if (id > 0) return id;
    }
    final int fromOffice = _asInt(officeRaw);
    if (fromOffice > 0) return fromOffice;
    return 0;
  }

  static String _officeName(Map<String, dynamic> user) {
    for (final Object? direct in <Object?>[
      user['officeName'],
      user['office_name'],
    ]) {
      if (direct is String && direct.trim().isNotEmpty) {
        return direct.trim();
      }
    }

    final Object? officeRaw =
        user['office'] ?? user['assignedOffice'] ?? user['assigned_office'];
    if (officeRaw is Map) {
      final Map<String, dynamic> office = Map<String, dynamic>.from(officeRaw);
      final String name =
          (office['name'] ?? office['officeName'] ?? office['title'] ?? '')
              .toString()
              .trim();
      if (name.isNotEmpty) return name;
    }
    if (officeRaw is String && officeRaw.trim().isNotEmpty) {
      return officeRaw.trim();
    }
    return '';
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}

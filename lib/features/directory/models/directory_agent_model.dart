import 'package:newlane/features/directory/domain/entities/directory_agent.dart';

class DirectoryAgentModel {
  const DirectoryAgentModel({
    required this.id,
    required this.fullName,
    required this.jobTitle,
    required this.avatar,
    required this.bio,
    required this.specialties,
    required this.stats,
    this.instagram = '',
    this.website = '',
    this.officeName = '',
    this.email = '',
    this.phone = '',
    this.role = '',
    this.department = '',
  });

  factory DirectoryAgentModel.fromJson(Map<String, dynamic> json) {
    final Object? statsRaw = json['stats'];
    final Map<String, dynamic> statsMap = statsRaw is Map
        ? Map<String, dynamic>.from(statsRaw)
        : <String, dynamic>{};

    final Object? specialtiesRaw = json['specialties'];
    final List<String> specialties = specialtiesRaw is List
        ? specialtiesRaw.map((Object? e) => e.toString()).toList()
        : const <String>[];

    final Object? officeRaw = json['office'];
    String officeName = '';
    if (officeRaw is Map) {
      officeName =
          officeRaw['name']?.toString() ??
          officeRaw['officeName']?.toString() ??
          '';
    } else if (officeRaw is String) {
      officeName = officeRaw;
    }

    final String parsedRole =
        (json['role'] ?? json['roleLabel'] ?? json['badge'] ?? '').toString();
    final String parsedTitle =
        (json['jobTitle'] ?? json['title'] ?? json['position'] ?? '')
            .toString();

    return DirectoryAgentModel(
      id: _asInt(json['id'] ?? json['_id']),
      fullName:
          (json['fullName'] ?? json['name'] ?? json['displayName'] ?? '')
              .toString(),
      jobTitle: parsedTitle.trim().isNotEmpty ? parsedTitle : parsedRole,
      avatar: (json['avatar'] ?? json['photo'] ?? json['image'] ?? '')
          .toString(),
      bio: json['bio']?.toString() ?? '',
      specialties: specialties,
      stats: DirectoryAgentStats(
        rating: _asNum(statsMap['rating']),
        dealsClosed: _asInt(statsMap['dealsClosed']),
        activeListings: _asInt(statsMap['activeListings']),
        yearsExperience: _asInt(statsMap['yearsExperience']),
      ),
      instagram: json['instagram']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      officeName: officeName.isNotEmpty
          ? officeName
          : (json['officeName'] ?? '').toString(),
      email: (json['email'] ?? json['workEmail'] ?? '').toString(),
      phone: (json['phone'] ?? json['phoneNumber'] ?? json['mobile'] ?? '')
          .toString(),
      role: parsedRole,
      department: (json['department'] ?? json['dept'] ?? '').toString(),
    );
  }

  final int id;
  final String fullName;
  final String jobTitle;
  final String avatar;
  final String bio;
  final List<String> specialties;
  final DirectoryAgentStats stats;
  final String instagram;
  final String website;
  final String officeName;
  final String email;
  final String phone;
  final String role;
  final String department;

  DirectoryAgent toEntity() {
    return DirectoryAgent(
      id: id,
      fullName: fullName,
      jobTitle: jobTitle,
      avatar: avatar,
      bio: bio,
      specialties: specialties,
      stats: stats,
      instagram: instagram,
      website: website,
      officeName: officeName,
      email: email,
      phone: phone,
      role: role,
      department: department,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static num _asNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse('$value') ?? 0;
  }
}

class DirectoryAgentsPageModel {
  const DirectoryAgentsPageModel({
    required this.agents,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory DirectoryAgentsPageModel.fromEnvelope(
    dynamic data, {
    bool teamFirst = false,
  }) {
    final Map<String, dynamic> map = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};

    // agents endpoint prefers `agents`; team endpoint prefers `team`.
    final Object? agentsRaw = teamFirst
        ? (map['team'] ??
              map['members'] ??
              map['agents'] ??
              map['users'] ??
              map['items'])
        : (map['agents'] ??
              map['team'] ??
              map['members'] ??
              map['users'] ??
              map['items']);
    final List<DirectoryAgentModel> agents = agentsRaw is List
        ? agentsRaw
              .whereType<Map>()
              .map(
                (Map item) => DirectoryAgentModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : const <DirectoryAgentModel>[];

    final int total = DirectoryAgentModel._asInt(
      map['total'] ?? map['count'] ?? agents.length,
    );
    final int page = DirectoryAgentModel._asInt(map['page'] ?? 1);
    final int pages = DirectoryAgentModel._asInt(
      map['pages'] ?? (agents.isEmpty ? 0 : 1),
    );

    return DirectoryAgentsPageModel(
      agents: agents,
      total: total,
      page: page,
      pages: pages,
    );
  }

  final List<DirectoryAgentModel> agents;
  final int total;
  final int page;
  final int pages;

  DirectoryAgentsPage toEntity() {
    return DirectoryAgentsPage(
      agents: agents.map((DirectoryAgentModel e) => e.toEntity()).toList(),
      total: total,
      page: page,
      pages: pages,
    );
  }
}

class AgentProfile {
  const AgentProfile({
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

  /// Admin-assigned role: agent | manager | marketing | support
  final String role;
  final int officeId;
  final String officeName;
  final List<String> specialties;

  /// Query value for `GET /api/directory/agents?office=`.
  String get directoryOfficeQuery {
    if (officeId > 0) return '$officeId';
    return officeName.trim();
  }

  /// e.g. agent → Agent, office_manager → Office Manager
  String get roleLabel {
    final String raw = role.trim();
    if (raw.isEmpty) return '';
    return raw
        .split(RegExp(r'[_\s-]+'))
        .where((String part) => part.isNotEmpty)
        .map(
          (String part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

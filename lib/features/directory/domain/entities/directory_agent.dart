class DirectoryAgentStats {
  const DirectoryAgentStats({
    this.rating = 0,
    this.dealsClosed = 0,
    this.activeListings = 0,
    this.yearsExperience = 0,
  });

  final num rating;
  final int dealsClosed;
  final int activeListings;
  final int yearsExperience;
}

class DirectoryAgent {
  const DirectoryAgent({
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

  /// Short gold pill, e.g. CEO / Agent / Support.
  String get roleBadge {
    final String raw = role.trim();
    if (raw.isEmpty) return '';
    if (raw == raw.toUpperCase() && raw.length <= 5) return raw;
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

class DirectoryAgentsPage {
  const DirectoryAgentsPage({
    required this.agents,
    required this.total,
    required this.page,
    required this.pages,
  });

  final List<DirectoryAgent> agents;
  final int total;
  final int page;
  final int pages;
}

class LoginResult {
  const LoginResult({
    required this.token,
    required this.message,
    required this.status,
    this.fullName = '',
    this.email = '',
  });

  final String token;
  final String message;
  final String status;
  final String fullName;
  final String email;

  bool get needsProfileCompletion {
    final String normalized = status.toLowerCase().trim();
    return normalized == 'profile_incomplete';
  }

  bool get canEnterApp {
    final String normalized = status.toLowerCase().trim();
    return normalized == 'active' ||
        normalized == 'profile_pending_review' ||
        normalized == 'approved';
  }
}

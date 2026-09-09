/// All REST paths. Keep base URL in env; keep paths here.
class ApiEndpoints {
  const ApiEndpoints._();

  static const String accessRequests = '/api/access-requests';

  static String accessRequestStatus(int requestId) {
    return '$accessRequests/$requestId/status';
  }

  static String activateAccount(String activationToken) {
    return '/api/auth/activate/$activationToken';
  }

  static const String login = '/api/auth/login';
  static const String forgotPassword = '/api/auth/forgot-password';

  static String resetPassword(String resetToken) {
    return '/api/auth/reset-password/$resetToken';
  }

  static const String agentMe = '/api/agents/me';
  static const String agentMeAvatar = '/api/agents/me/avatar';

  static const String directoryAgents = '/api/directory/agents';
  static const String directoryTeam = '/api/directory/team';

  static String directoryAgentById(int agentId) =>
      '$directoryAgents/$agentId';

  static const String offices = '/api/offices';

  static String officeById(int officeId) => '$offices/$officeId';

  static const String marketingRequests = '/api/marketing-requests';
  static const String marketingRequestsMine = '/api/marketing-requests/mine';

  static String marketingRequestById(int id) => '$marketingRequests/$id';

  static const String contentGeneratorTemplates =
      '/api/content-generator/templates';
  static const String contentGeneratorGenerate =
      '/api/content-generator/generate';

  static const String feed = '/api/feed';

  static String feedById(int postId) => '$feed/$postId';

  static String feedLike(int postId) => '$feed/$postId/like';

  static String feedComments(int postId) => '$feed/$postId/comments';

  static const String supportTickets = '/api/support/tickets';
  static const String supportTicketsMine = '/api/support/tickets/mine';

  static String supportTicketById(int ticketId) =>
      '$supportTickets/$ticketId';

  static String supportTicketReply(int ticketId) =>
      '$supportTickets/$ticketId/reply';

  // Chat (Node + Firebase Admin) — create rooms / seed demo
  static const String chatAnnouncements = '/api/chat/announcements';
  static const String chatDms = '/api/chat/dms';
  static const String chatSeedDemo = '/api/chat/seed-demo';
}

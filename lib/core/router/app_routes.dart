class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String requestAccess = '/request-access';
  static const String requestPending = '/request-pending';
  static const String checkYourEmail = '/check-your-email';
  static const String createPassword = '/create-password';
  static const String activate = '/activate';
  static const String resetPassword = '/reset-password';

  static String createPasswordWithToken(String activationToken) {
    return '$createPassword/$activationToken';
  }

  static String resetPasswordWithToken(String resetToken) {
    return '$resetPassword/$resetToken';
  }
  static const String completeProfile = '/complete-profile';
  static const String home = '/home';
  static const String more = '/more';
  static const String moreInfo = '/more/info';
  static const String moreOffice = '/more/office';
  static const String moreNotifications = '/more/notifications';
  static const String moreAccount = '/more/account';
  static const String morePrivacy = '/more/privacy';
  static const String moreSecurity = '/more/security';
  static const String morePushNotifications = '/more/push-notifications';
  static const String moreHelpSupport = '/more/help-support';
  static const String moreTerms = '/more/terms';
  static const String moreAbout = '/more/about';
  static const String support = '/support';
  static const String ticketSupport = '/support/tickets';
  static const String newSupportTicket = '/support/tickets/new';
  static const String ticketDetails = '/support/tickets/details';
  static const String ticketConversation = '/support/tickets/conversation';
  static const String createPost = '/create-post';
  static const String tagOffice = '/create-post/tag-office';
  static const String addLocation = '/create-post/add-location';
  static const String chat = '/chat';
  static const String conversation = '/chat/conversation';

  static String conversationWithId(String chatId) => '$conversation/$chatId';

  static const String feed = '/feed';
  static const String profile = '/profile';
  static const String signIn = '/sign-in';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordSent = '/forgot-password/sent';
  static const String directory = '/directory';
  static const String officeDirectory = '/office-directory';
  static const String trainingHub = '/home/training-hub';
  static const String contentGenerator = '/content-generator';
  static const String contentGeneratorDetails = '/content-generator/details';
  static const String contentGeneratorGenerating =
      '/content-generator/generating';
  static const String contentGeneratorPreview = '/content-generator/preview';
  static const String contentGeneratorEdit = '/content-generator/edit';
  static const String contentGeneratorSave = '/content-generator/save';
  static const String marketingRequest = '/marketing-request';
  static const String myRequests = '/my-requests';
  static const String marketingRequestDetail = '/marketing-request/detail';
  static const String editProfile = '/edit-profile';
}

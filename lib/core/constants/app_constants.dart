class AppConstants {
  const AppConstants._();

  static const String appName = 'NewLane Brokers';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Saved after POST /api/access-requests so we can poll status.
  static const String accessRequestIdKey = 'access_request_id';
  static const String accessRequestFullNameKey = 'access_request_full_name';
  static const String accessRequestWorkEmailKey = 'access_request_work_email';
  static const String accessRequestBrokerageKey = 'access_request_brokerage';
  static const String accessRequestPhoneKey = 'access_request_phone';

  /// Saved after POST /api/auth/activate/:token or login.
  static const String authTokenKey = 'auth_token';
  static const String rememberMeKey = 'remember_me';
  static const String rememberedEmailKey = 'remembered_email';

  /// Set once when onboarding is finished/skipped. Survives logout.
  static const String onboardingCompletedKey = 'onboarding_completed';
}

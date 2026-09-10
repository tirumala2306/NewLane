/// Public legal / support URLs for App Store and in-app links.
///
/// After deploying `legal/` to your web host, update [baseUrl] if needed.
class LegalUrls {
  const LegalUrls._();

  /// Public site root that serves the `legal/` folder.
  /// Prefer HTTPS for App Store Connect.
  static const String baseUrl = 'https://api.newlanebrokers.com/legal';

  static const String index = '$baseUrl/index.html';
  static const String privacy = '$baseUrl/privacy.html';
  static const String terms = '$baseUrl/terms.html';
  static const String security = '$baseUrl/security.html';
  static const String support = '$baseUrl/support.html';
  static const String about = '$baseUrl/about.html';

  static const String supportEmail = 'gabrielr@marsblue.co';
  static const String supportMailto = 'mailto:$supportEmail';
}

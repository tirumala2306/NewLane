import 'package:newlane/core/utils/app_log.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the device mail client so the user can tap the activation link.
Future<bool> openMailApp() async {
  return openEmailComposer(null);
}

/// Opens the device mail client. Pass [email] to start a new message.
Future<bool> openEmailComposer(String? email) async {
  final String trimmed = (email ?? '').trim();
  final Uri uri = trimmed.isEmpty
      ? Uri(scheme: 'mailto')
      : Uri(scheme: 'mailto', path: trimmed);

  try {
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } catch (error) {
    AppLog.line('[MAIL] failed to open mail app: $error');
  }

  return false;
}

import 'package:newlane/core/utils/app_log.dart';
import 'package:url_launcher/url_launcher.dart';

/// Digits (and leading +) only — for `tel:` URIs.
String? sanitizePhoneNumber(String? raw) {
  if (raw == null) return null;
  final String trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < trimmed.length; i++) {
    final String ch = trimmed[i];
    if (i == 0 && ch == '+') {
      buffer.write(ch);
      continue;
    }
    if (RegExp(r'\d').hasMatch(ch)) {
      buffer.write(ch);
    }
  }

  final String cleaned = buffer.toString();
  if (cleaned.isEmpty || cleaned == '+') return null;
  return cleaned;
}

/// Opens the device dialer with [phone].
Future<bool> openPhoneDialer(String? phone) async {
  final String? number = sanitizePhoneNumber(phone);
  if (number == null) {
    AppLog.line('[PHONE] no valid number to dial');
    return false;
  }

  final Uri uri = Uri(scheme: 'tel', path: number);
  try {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (error) {
    AppLog.line('[PHONE] failed to open dialer: $error');
    return false;
  }
}

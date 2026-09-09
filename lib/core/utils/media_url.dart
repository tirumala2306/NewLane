import 'package:newlane/core/config/app_environment.dart';

/// Turns API-relative media paths into absolute URLs.
///
/// Examples:
/// - `https://cdn.../a.jpg` → unchanged
/// - `/uploads/avatars/x.jpg` → `{baseUrl}/uploads/avatars/x.jpg`
/// - `uploads/avatars/x.jpg` → `{baseUrl}/uploads/avatars/x.jpg`
String? resolveMediaUrl(String? raw) {
  final String value = (raw ?? '').trim();
  if (value.isEmpty) return null;
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  // Avoid treating bare relative paths as file:// on some platforms.
  if (value.startsWith('file://')) {
    final String path = value.replaceFirst(RegExp(r'^file://'), '');
    return resolveMediaUrl(path);
  }

  final String base = AppEnvironment.baseUrl.replaceAll(RegExp(r'/$'), '');
  if (base.isEmpty) return null;
  final String path = value.startsWith('/') ? value : '/$value';
  return '$base$path';
}

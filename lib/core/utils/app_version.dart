import 'package:package_info_plus/package_info_plus.dart';

/// Reads the real app version from the platform build
/// (`pubspec.yaml` → `version: x.y.z+build`).
class AppVersion {
  const AppVersion._();

  static PackageInfo? _cached;

  static Future<PackageInfo> load() async {
    return _cached ??= await PackageInfo.fromPlatform();
  }

  /// e.g. `Version 1.0.0`
  static Future<String> shortLabel() async {
    final PackageInfo info = await load();
    return 'Version ${info.version}';
  }

  /// e.g. `Version 1.0.0 (Build 1)`
  static Future<String> fullLabel() async {
    final PackageInfo info = await load();
    final String build = info.buildNumber.trim();
    if (build.isEmpty) return 'Version ${info.version}';
    return 'Version ${info.version} (Build $build)';
  }
}

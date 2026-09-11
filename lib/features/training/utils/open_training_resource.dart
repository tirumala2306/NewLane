import 'dart:io';

import 'package:dio/dio.dart';
import 'package:newlane/core/utils/app_log.dart';
import 'package:newlane/core/utils/media_url.dart';
import 'package:newlane/features/training/domain/entities/training_resource.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> openTrainingResource(TrainingResource resource) async {
  final String? url = resolveMediaUrl(resource.fileUrl);
  AppLog.line(
    '[TRAINING] open raw="${resource.fileUrl}" resolved="$url" '
    'video=${resource.isVideo}',
  );
  if (url == null || url.isEmpty) {
    AppLog.line('[TRAINING] open failed: empty url');
    return false;
  }

  final Uri? uri = Uri.tryParse(url);
  if (uri == null || !(uri.hasScheme && uri.host.isNotEmpty)) {
    AppLog.line('[TRAINING] open failed: bad uri');
    return false;
  }

  // Try several launch modes — Android 11+ / some OEMs reject one mode but
  // accept another. Do not bail only because canLaunchUrl is false.
  const List<LaunchMode> modes = <LaunchMode>[
    LaunchMode.externalApplication,
    LaunchMode.platformDefault,
    LaunchMode.inAppBrowserView,
    LaunchMode.externalNonBrowserApplication,
  ];

  for (final LaunchMode mode in modes) {
    try {
      final bool ok = await launchUrl(uri, mode: mode);
      AppLog.line('[TRAINING] launch mode=$mode ok=$ok');
      if (ok) return true;
    } catch (e) {
      AppLog.line('[TRAINING] launch mode=$mode error=$e');
    }
  }
  return false;
}

/// Plays / opens the resource for viewing (not downloading).
Future<bool> playTrainingResource(TrainingResource resource) {
  return openTrainingResource(resource);
}

/// Saves the file locally. Returns the saved path, or null on failure.
Future<String?> downloadTrainingResource(TrainingResource resource) async {
  final String? url = resolveMediaUrl(resource.fileUrl);
  AppLog.line('[TRAINING] download raw="${resource.fileUrl}" resolved="$url"');
  if (url == null || url.isEmpty) return null;

  try {
    final Directory base = await getApplicationDocumentsDirectory();
    final Directory folder = Directory('${base.path}/training_downloads');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    String name = resource.displayName.trim();
    if (name.isEmpty) name = 'training_${resource.id}';
    name = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

    // Keep extension from URL if filename has none.
    if (!name.contains('.')) {
      final String path = Uri.tryParse(url)?.path ?? '';
      final String ext = path.contains('.')
          ? path.substring(path.lastIndexOf('.'))
          : '';
      if (ext.isNotEmpty && ext.length <= 8) name = '$name$ext';
    }

    final String savePath = '${folder.path}/$name';
    AppLog.line('[TRAINING] download $url -> $savePath');
    await Dio().download(url, savePath);
    return savePath;
  } catch (e) {
    AppLog.line('[TRAINING] download failed: $e');
    return null;
  }
}

import 'package:flutter/material.dart';
import 'package:newlane/core/utils/media_url.dart';
import 'package:newlane/features/training/domain/entities/training_resource.dart';
import 'package:newlane/features/training/utils/open_training_resource.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';

Future<void> handleTrainingPlay(
  BuildContext context,
  TrainingResource resource,
) async {
  final String action = resource.isVideo ? 'Play' : 'View';
  final String? resolved = resolveMediaUrl(resource.fileUrl);
  if (resolved == null || resolved.isEmpty) {
    if (!context.mounted) return;
    AppSnackBar.showError(
      context,
      title: action,
      message: 'No file URL on this resource yet.',
    );
    return;
  }

  final bool ok = await playTrainingResource(resource);
  if (!context.mounted) return;
  if (!ok) {
    AppSnackBar.showError(
      context,
      title: action,
      message: 'Could not open this file. Try Download, then open from Files.',
    );
  }
}

Future<void> handleTrainingDownload(
  BuildContext context,
  TrainingResource resource,
) async {
  final String? resolved = resolveMediaUrl(resource.fileUrl);
  if (resolved == null || resolved.isEmpty) {
    if (!context.mounted) return;
    AppSnackBar.showError(
      context,
      title: 'Download',
      message: 'No file URL on this resource yet.',
    );
    return;
  }

  final String? path = await downloadTrainingResource(resource);
  if (!context.mounted) return;
  if (path == null) {
    AppSnackBar.showError(
      context,
      title: 'Download',
      message: 'Download failed. Please try again.',
    );
    return;
  }
  AppSnackBar.showSuccess(
    context,
    title: 'Downloaded',
    message: resource.displayName,
  );
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';

/// Kept for route compatibility; download/share lives on preview.
class ContentSaveScreen extends StatelessWidget {
  const ContentSaveScreen({required this.draft, super.key});

  final ContentGeneratorDraft draft;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => context.pop(),
          child: const Text('Back'),
        ),
      ),
    );
  }
}

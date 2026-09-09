import 'package:flutter/material.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/features/content_generator/screens/content_generator_details_screen.dart';

/// Entry point — opens the listing details form directly.
class ContentGeneratorScreen extends StatelessWidget {
  const ContentGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentGeneratorDetailsScreen(
      draft: ContentGeneratorDraft(),
    );
  }
}

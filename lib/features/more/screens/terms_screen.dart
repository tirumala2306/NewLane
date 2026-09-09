import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/more/widgets/more_card.dart';
import 'package:newlane/features/more/widgets/more_settings_widgets.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const List<_TermsSection> _sections = <_TermsSection>[
    _TermsSection(
      title: 'Acceptance of Terms',
      body:
          'By accessing or using the NewLane app, you agree to be bound by these Terms & Conditions and all applicable laws and regulations.',
    ),
    _TermsSection(
      title: 'Use of the App',
      body:
          'You may use the app only for lawful professional purposes related to your role at NewLane. Unauthorized access, scraping, or redistribution of content is prohibited.',
    ),
    _TermsSection(
      title: 'User Responsibilities',
      body:
          'You are responsible for maintaining accurate account information, protecting your login credentials, and using the platform respectfully with other agents and staff.',
    ),
    _TermsSection(
      title: 'Privacy',
      body:
          'Your use of the app is also governed by our Privacy Policy. Please review it to understand how we collect and use your information.',
    ),
    _TermsSection(
      title: 'Changes to Terms',
      body:
          'NewLane may update these terms at any time. Continued use of the app after changes are posted constitutes acceptance of the revised terms.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        onPrefixPressed: () => context.pop(),
        title: 'TERMS & CONDITIONS',
        titleFontSize: 16,
        height: ScreenUtils.h(56),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(16),
          ScreenUtils.h(8),
          ScreenUtils.w(16),
          ScreenUtils.h(32),
        ),
        children: <Widget>[
          Text(
            'Last updated May 1, 2025',
            style: AppTypography.regular(
              fontSize: 11,
              color: AppColors.white.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: ScreenUtils.h(12)),
          MoreCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ...List<Widget>.generate(_sections.length, (int index) {
                  final _TermsSection section = _sections[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        section.title,
                        style: AppTypography.semiBold(fontSize: 14),
                      ),
                      SizedBox(height: ScreenUtils.h(8)),
                      Text(
                        section.body,
                        style: AppTypography.regular(
                          fontSize: 12,
                          height: 1.45,
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      if (index < _sections.length - 1) moreDivider(),
                    ],
                  );
                }),
                SizedBox(height: ScreenUtils.h(16)),
                UnifiedButton(
                  label: 'Close',
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsSection {
  const _TermsSection({required this.title, required this.body});

  final String title;
  final String body;
}

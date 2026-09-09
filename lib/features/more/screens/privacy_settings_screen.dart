import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/more/data/more_info_content.dart';
import 'package:newlane/features/more/widgets/more_card.dart';
import 'package:newlane/features/more/widgets/more_settings_widgets.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _profileVisibility = true;
  bool _showContact = false;
  bool _activityStatus = true;
  bool _dataCollection = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        onPrefixPressed: () => context.pop(),
        title: 'PRIVACY',
        titleFontSize: 16,
        height: ScreenUtils.h(56),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(16),
          ScreenUtils.h(12),
          ScreenUtils.w(16),
          ScreenUtils.h(32),
        ),
        children: <Widget>[
          const MoreSectionTitle('Privacy Settings'),
          SizedBox(height: ScreenUtils.h(10)),
          MoreCard(
            child: Column(
              children: <Widget>[
                MoreToggleRow(
                  title: 'Profile Visibility',
                  subtitle: 'Allow others to view your profile in the directory',
                  value: _profileVisibility,
                  onChanged: (bool v) => setState(() => _profileVisibility = v),
                ),
                moreDivider(),
                MoreToggleRow(
                  title: 'Show Contact Information',
                  subtitle: 'Allow others to view your contact information',
                  value: _showContact,
                  onChanged: (bool v) => setState(() => _showContact = v),
                ),
                moreDivider(),
                MoreToggleRow(
                  title: 'Activity Status',
                  subtitle: "Show when you're active in the app",
                  value: _activityStatus,
                  onChanged: (bool v) => setState(() => _activityStatus = v),
                ),
                moreDivider(),
                MoreToggleRow(
                  title: 'Data Collection',
                  subtitle:
                      'Allow us to collect app usage data to improve your experience',
                  value: _dataCollection,
                  onChanged: (bool v) => setState(() => _dataCollection = v),
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenUtils.h(12)),
          MoreCard(
            child: Column(
              children: <Widget>[
                MoreNavRow(
                  title: 'Privacy Policy',
                  onTap: () => context.push(
                    AppRoutes.moreInfo,
                    extra: MoreInfoContent.privacy,
                  ),
                ),
                moreDivider(),
                MoreNavRow(title: 'Manage My Data', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/more/widgets/more_card.dart';
import 'package:newlane/features/more/widgets/more_settings_widgets.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class PushNotificationsScreen extends StatefulWidget {
  const PushNotificationsScreen({super.key});

  @override
  State<PushNotificationsScreen> createState() =>
      _PushNotificationsScreenState();
}

class _PushNotificationsScreenState extends State<PushNotificationsScreen> {
  bool _enabled = true;
  bool _messages = true;
  bool _leads = false;
  bool _listings = true;
  bool _price = true;
  bool _openHouse = true;
  bool _marketing = false;
  bool _system = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        onPrefixPressed: () => context.pop(),
        title: 'PUSH NOTIFICATIONS',
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
          MoreCard(
            child: MoreToggleRow(
              title: 'Enable Push Notifications',
              subtitle: 'Receive push notifications on your device',
              value: _enabled,
              onChanged: (bool v) => setState(() => _enabled = v),
            ),
          ),
          SizedBox(height: ScreenUtils.h(20)),
          const MoreSectionTitle('NOTIFICATION PREFERENCES', gold: true),
          SizedBox(height: ScreenUtils.h(10)),
          MoreCard(
            child: Column(
              children: <Widget>[
                MoreToggleRow(
                  title: 'New Messages',
                  subtitle: 'Get notified when you receive new messages',
                  value: _messages && _enabled,
                  onChanged: _enabled
                      ? (bool v) => setState(() => _messages = v)
                      : (_) {},
                ),
                moreDivider(),
                MoreToggleRow(
                  title: 'New Leads',
                  subtitle: 'Get notified for new leads',
                  value: _leads && _enabled,
                  onChanged:
                      _enabled ? (bool v) => setState(() => _leads = v) : (_) {},
                ),
                moreDivider(),
                MoreToggleRow(
                  title: 'Listing Updates',
                  subtitle: 'Get notified about listing updates',
                  value: _listings && _enabled,
                  onChanged: _enabled
                      ? (bool v) => setState(() => _listings = v)
                      : (_) {},
                ),
                moreDivider(),
                MoreToggleRow(
                  title: 'Price Changes',
                  subtitle: 'Get notified about price changes',
                  value: _price && _enabled,
                  onChanged:
                      _enabled ? (bool v) => setState(() => _price = v) : (_) {},
                ),
                moreDivider(),
                MoreToggleRow(
                  title: 'Open House Reminders',
                  subtitle: 'Get reminders for open houses',
                  value: _openHouse && _enabled,
                  onChanged: _enabled
                      ? (bool v) => setState(() => _openHouse = v)
                      : (_) {},
                ),
                moreDivider(),
                MoreToggleRow(
                  title: 'Marketing Updates',
                  subtitle: 'Get notified about marketing and promotions',
                  value: _marketing && _enabled,
                  onChanged: _enabled
                      ? (bool v) => setState(() => _marketing = v)
                      : (_) {},
                ),
                moreDivider(),
                MoreToggleRow(
                  title: 'System Updates',
                  subtitle: 'Important system notifications',
                  value: _system && _enabled,
                  onChanged: _enabled
                      ? (bool v) => setState(() => _system = v)
                      : (_) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

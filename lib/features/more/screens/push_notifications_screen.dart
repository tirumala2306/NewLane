import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/more/widgets/more_card.dart';
import 'package:newlane/features/more/widgets/more_settings_widgets.dart';
import 'package:newlane/features/notifications/data/push_notification_prefs.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class PushNotificationsScreen extends StatefulWidget {
  const PushNotificationsScreen({super.key});

  @override
  State<PushNotificationsScreen> createState() =>
      _PushNotificationsScreenState();
}

class _PushNotificationsScreenState extends State<PushNotificationsScreen> {
  late PushNotificationPrefs _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = InjectionContainer.instance.pushPrefsStore.read();
  }

  Future<void> _update(PushNotificationPrefs next) async {
    setState(() => _prefs = next);
    await InjectionContainer.instance.pushNotificationService.applyPrefs(next);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = _prefs.enabled;

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
              value: enabled,
              onChanged: (bool v) => unawaited(_update(_prefs.copyWith(enabled: v))),
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
                  subtitle: 'Get notified when you receive new chat messages',
                  value: _prefs.messages && enabled,
                  onChanged: enabled
                      ? (bool v) =>
                          unawaited(_update(_prefs.copyWith(messages: v)))
                      : (_) {},
                ),
                moreDivider(),
                MoreToggleRow(
                  title: 'Support Tickets',
                  subtitle: 'Updates and replies on your support tickets',
                  value: _prefs.tickets && enabled,
                  onChanged: enabled
                      ? (bool v) =>
                          unawaited(_update(_prefs.copyWith(tickets: v)))
                      : (_) {},
                ),
                moreDivider(),
                MoreToggleRow(
                  title: 'Announcements',
                  subtitle: 'Office and company announcements',
                  value: _prefs.announcements && enabled,
                  onChanged: enabled
                      ? (bool v) => unawaited(
                            _update(_prefs.copyWith(announcements: v)),
                          )
                      : (_) {},
                ),
                moreDivider(),
                MoreToggleRow(
                  title: 'Marketing Updates',
                  subtitle: 'Marketing request status and promotions',
                  value: _prefs.marketing && enabled,
                  onChanged: enabled
                      ? (bool v) =>
                          unawaited(_update(_prefs.copyWith(marketing: v)))
                      : (_) {},
                ),
                moreDivider(),
                MoreToggleRow(
                  title: 'System Updates',
                  subtitle: 'Important system notifications',
                  value: _prefs.system && enabled,
                  onChanged: enabled
                      ? (bool v) =>
                          unawaited(_update(_prefs.copyWith(system: v)))
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

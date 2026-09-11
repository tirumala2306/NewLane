import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/more/widgets/more_card.dart';
import 'package:newlane/features/notifications/domain/entities/app_notification.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

enum _NotifFilter { all, unread }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    this.announcementsOnly = false,
  });

  /// When true (from Home → View all), hide tickets/marketing/messages.
  final bool announcementsOnly;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _items = <AppNotification>[];
  bool _loading = true;
  String? _error;
  _NotifFilter _filter = _NotifFilter.all;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final Result<List<AppNotification>> result =
        await InjectionContainer.instance.fetchMyNotifications();
    if (!mounted) return;
    result.when(
      ok: (List<AppNotification> items) {
        setState(() {
          _items = items;
          _loading = false;
        });
      },
      err: (failure) {
        setState(() {
          _error = failure.message;
          _loading = false;
        });
      },
    );
  }

  List<AppNotification> get _visible {
    Iterable<AppNotification> list = _items;
    if (widget.announcementsOnly) {
      list = list.where((AppNotification n) => n.showOnHomeAnnouncements);
    }
    if (_filter == _NotifFilter.unread) {
      list = list.where((AppNotification n) => n.isUnread);
    }
    return list.toList();
  }

  @override
  Widget build(BuildContext context) {
    const office = 'NEWLANE';
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        prefixIconColor: AppColors.primaryButtonBg,
        onPrefixPressed: () => context.pop(),
        title: 'NOTIFICATIONS',
        titleFontSize: 16,
        description: office,
        descriptionFontSize: 10,
        suffix: IconButton(
          onPressed: () => context.push(AppRoutes.morePushNotifications),
          icon: Icon(
            CupertinoIcons.gear,
            size: ScreenUtils.sp(22),
            color: AppColors.primaryButtonBg,
          ),
        ),
        height: ScreenUtils.h(56),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              ScreenUtils.w(16),
              ScreenUtils.h(8),
              ScreenUtils.w(16),
              ScreenUtils.h(8),
            ),
            child: Row(
              children: <Widget>[
                _FilterChip(
                  label: 'All',
                  selected: _filter == _NotifFilter.all,
                  onTap: () => setState(() => _filter = _NotifFilter.all),
                ),
                SizedBox(width: ScreenUtils.w(8)),
                _FilterChip(
                  label: 'Unread',
                  selected: _filter == _NotifFilter.unread,
                  onTap: () => setState(() => _filter = _NotifFilter.unread),
                ),
              ],
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryButtonBg),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(ScreenUtils.w(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTypography.regular(
                  fontSize: 13,
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
              TextButton(
                onPressed: _load,
                child: Text(
                  'Retry',
                  style: AppTypography.semiBold(
                    fontSize: 13,
                    color: AppColors.primaryButtonBg,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<AppNotification> items = _visible;
    if (items.isEmpty) {
      return Center(
        child: Text(
          widget.announcementsOnly
              ? 'No announcements yet'
              : 'No notifications yet',
          style: AppTypography.regular(
            fontSize: 13,
            color: AppColors.white.withValues(alpha: 0.55),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryButtonBg,
      backgroundColor: AppColors.black,
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          ScreenUtils.w(16),
          ScreenUtils.h(4),
          ScreenUtils.w(16),
          ScreenUtils.h(32),
        ),
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(height: ScreenUtils.h(10)),
        itemBuilder: (BuildContext context, int index) {
          final AppNotification item = items[index];
          return MoreCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: ScreenUtils.w(40),
                  height: ScreenUtils.w(40),
                  decoration: BoxDecoration(
                    color: AppColors.primaryButtonBg.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
                  ),
                  child: Icon(
                    item.icon,
                    color: AppColors.primaryButtonBg,
                    size: ScreenUtils.sp(18),
                  ),
                ),
                SizedBox(width: ScreenUtils.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item.title,
                              style: AppTypography.semiBold(fontSize: 13),
                            ),
                          ),
                          Text(
                            item.timeLabel,
                            style: AppTypography.regular(
                              fontSize: 10,
                              color: AppColors.primaryButtonBg,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ScreenUtils.h(6)),
                      Text(
                        item.body,
                        style: AppTypography.regular(
                          fontSize: 12,
                          height: 1.35,
                          color: AppColors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      if (item.isUnread) ...<Widget>[
                        SizedBox(height: ScreenUtils.h(8)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: ScreenUtils.w(8),
                            height: ScreenUtils.w(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryButtonBg,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtils.w(14),
          vertical: ScreenUtils.h(8),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
          border: Border.all(
            color: selected
                ? AppColors.primaryButtonBg
                : AppColors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.medium(
            fontSize: 12,
            color: selected
                ? AppColors.primaryButtonBg
                : AppColors.white.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }
}

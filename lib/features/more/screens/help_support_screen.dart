import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/phone_launcher.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/more/data/mock/more_mock_data.dart';
import 'package:newlane/features/more/widgets/more_card.dart';
import 'package:newlane/shared/widgets/app_snackbar.dart';
import 'package:newlane/shared/widgets/newlane_app_bar.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _call(BuildContext context) async {
    final bool opened = await openPhoneDialer(MoreMockData.supportPhone);
    if (!context.mounted) return;
    if (!opened) {
      AppSnackBar.showInfo(
        context,
        title: 'Call',
        message: 'Could not open the phone app.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<_HelpItem> items = <_HelpItem>[
      _HelpItem(
        title: 'Contact Support',
        subtitle: 'Get help from our support team',
        icon: Icons.chat_bubble_outline,
        onTap: () => context.push(AppRoutes.ticketSupport),
      ),
      const _HelpItem(
        title: 'FAQs',
        subtitle: 'Find answers to common questions',
        icon: Icons.help_outline,
      ),
      _HelpItem(
        title: 'Submit a Ticket',
        subtitle: 'Send us a message',
        icon: Icons.confirmation_number_outlined,
        onTap: () => context.push(AppRoutes.newSupportTicket),
      ),
      _HelpItem(
        title: 'Ticket Support',
        subtitle: 'Track and manage your tickets',
        icon: Icons.description_outlined,
        onTap: () => context.push(AppRoutes.ticketSupport),
      ),
      _HelpItem(
        title: 'Call Us',
        subtitle: MoreMockData.supportPhone,
        icon: Icons.phone_outlined,
        onTap: () => _call(context),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: NewLaneAppBar(
        prefixIcon: Icons.arrow_back_ios_new,
        onPrefixPressed: () => context.pop(),
        title: 'HELP & SUPPORT',
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
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtils.r(8)),
              child: SizedBox(
                height: ScreenUtils.h(120),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.network(
                      'https://images.unsplash.com/photo-1512453979798-5ea9204c5c1b?w=1200&q=80',
                      fit: BoxFit.cover,
                      errorBuilder:
                          (BuildContext context, Object error, StackTrace? stack) {
                        return const ColoredBox(color: Color(0xFF1A1A1A));
                      },
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: <Color>[
                            Color(0xEE000000),
                            Color(0x66000000),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(ScreenUtils.w(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'How can we help you?',
                            style: AppTypography.semiBold(fontSize: 16),
                          ),
                          SizedBox(height: ScreenUtils.h(6)),
                          Text(
                            "We're here to support you",
                            style: AppTypography.regular(
                              fontSize: 12,
                              color: AppColors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: ScreenUtils.h(12)),
          ...items.map(
            (_HelpItem item) => Padding(
              padding: EdgeInsets.only(bottom: ScreenUtils.h(10)),
              child: MoreCard(
                height: ScreenUtils.h(63),
                onTap: item.onTap ?? () {},
                child: Row(
                  children: <Widget>[
                    Icon(
                      item.icon,
                      color: AppColors.primaryButtonBg,
                      size: ScreenUtils.sp(22),
                    ),
                    SizedBox(width: ScreenUtils.w(10)),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.title,
                            style: AppTypography.semiBold(fontSize: 13),
                          ),
                          SizedBox(height: ScreenUtils.h(2)),
                          Text(
                            item.subtitle,
                            style: AppTypography.regular(
                              fontSize: 10,
                              color: AppColors.white.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.primaryButtonBg,
                      size: ScreenUtils.sp(20),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: ScreenUtils.h(16)),
          Text(
            'Support Hours',
            textAlign: TextAlign.center,
            style: AppTypography.semiBold(fontSize: 13),
          ),
          SizedBox(height: ScreenUtils.h(6)),
          Text(
            MoreMockData.supportHours,
            textAlign: TextAlign.center,
            style: AppTypography.regular(
              fontSize: 12,
              color: AppColors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpItem {
  const _HelpItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
}

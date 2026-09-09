import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/shared/widgets/app_svg.dart';

/// Shared chrome for every auth screen.
///
/// Handles status bar, keyboard dismiss, optional login background,
/// back button, scrolling, and a pinned footer (Continue / Save).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.body,
    super.key,
    this.onBack,
    this.footer,
    this.showBackground = false,
    this.dimAmount,
    this.footerTopGap,
  });

  /// Scrollable page content (title, fields, cards).
  final Widget body;

  /// When set, shows the back chevron. When null, adds top spacing instead.
  final VoidCallback? onBack;

  /// Pinned above the home indicator (e.g. Continue).
  final Widget? footer;

  /// Login photo behind the content.
  final bool showBackground;

  /// Black overlay on the photo. Null = no overlay.
  final double? dimAmount;

  /// Extra space above [footer]. Defaults to 8.
  final double? footerTopGap;

  @override
  Widget build(BuildContext context) {
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        // Dismiss keyboard on blank taps without stealing button presses.
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.deferToChild,
        child: Scaffold(
          backgroundColor: AppColors.black,
          resizeToAvoidBottomInset: false,
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (showBackground)
                const AppSvg(AssetConstants.loginBg, fit: BoxFit.cover),
              if (showBackground && dimAmount != null)
                Container(color: AppColors.black.withValues(alpha: dimAmount!)),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (onBack != null)
                      AuthBackButton(onPressed: onBack!)
                    else
                      SizedBox(height: ScreenUtils.h(50)),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          ScreenUtils.w(24),
                          ScreenUtils.h(8),
                          ScreenUtils.w(24),
                          ScreenUtils.h(16) + keyboard,
                        ),
                        child: body,
                      ),
                    ),
                    if (footer != null)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          ScreenUtils.w(24),
                          footerTopGap ?? ScreenUtils.h(8),
                          ScreenUtils.w(24),
                          ScreenUtils.h(24),
                        ),
                        child: footer,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// iOS-style back chevron used on auth screens.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.w(16),
        vertical: ScreenUtils.h(16),
      ),
      child: IconButton(
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          onPressed();
        },
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: ScreenUtils.r(18),
          color: AppColors.white,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/constants/asset_constants.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/core/theme/app_colors.dart';
import 'package:newlane/core/theme/app_typography.dart';
import 'package:newlane/core/utils/screen_utils.dart';
import 'package:newlane/features/onboarding/widgets/onboarding_page1.dart';
import 'package:newlane/features/onboarding/widgets/onboarding_page2.dart';
import 'package:newlane/features/onboarding/widgets/onboarding_page3.dart';
import 'package:newlane/features/onboarding/widgets/page_indicator.dart';
import 'package:newlane/shared/widgets/app_svg.dart';
import 'package:newlane/shared/widgets/unified_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _totalPages = 3;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Page 3 draws its shield inside the slide (top-right), so use black here.
  String? get _backgroundAsset {
    switch (_currentPage) {
      case 1:
        return AssetConstants.loginBg;
      case 2:
        return null;
      case 0:
      default:
        return AssetConstants.onboardingBg;
    }
  }

  Future<void> _finishOnboarding() async {
    await InjectionContainer.instance.appStorage.setOnboardingCompleted();
    if (!mounted) return;
    context.go(AppRoutes.requestAccess);
  }

  void _onSkip() {
    _finishOnboarding();
  }

  void _onBack() {
    if (_currentPage == 0) {
      return;
    }
    _pageController.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    _finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final bool showBack = _currentPage > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              child: _backgroundAsset == null
                  ? const ColoredBox(
                      key: ValueKey<String>('page3-bg'),
                      color: AppColors.black,
                    )
                  : AppSvg(
                      _backgroundAsset!,
                      key: ValueKey<String>(_backgroundAsset!),
                      fit: BoxFit.cover,
                    ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(24)),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: ScreenUtils.h(48),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          if (showBack)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: _onBack,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  Icons.arrow_back_ios_new,
                                  size: ScreenUtils.r(18),
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: _onSkip,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtils.h(8),
                                  horizontal: ScreenUtils.w(4),
                                ),
                                child: Text(
                                  'skip >',
                                  style: AppTypography.medium(
                                    color: AppColors.primaryButtonBg,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (int index) {
                          setState(() => _currentPage = index);
                        },
                        children: const <Widget>[
                          OnboardingSlideOne(),
                          OnboardingSlideTwo(),
                          OnboardingSlideThree(),
                        ],
                      ),
                    ),  
                    PageIndicator(count: _totalPages, index: _currentPage),
                    SizedBox(height: ScreenUtils.h(12)),
                    UnifiedButton(
                      label: _currentPage == _totalPages - 1
                          ? 'Get Started'
                          : 'Next',
                      onPressed: _onNext,
                    ),
                    SizedBox(height: ScreenUtils.h(12)),
                    Text.rich(
                      TextSpan(
                        style: AppTypography.medium(fontSize: 10),
                        children: <TextSpan>[
                          const TextSpan(
                            text: 'Exclusive. Modern. Powered by ',
                          ),
                          TextSpan(
                            text: 'NEWLANE.',
                            style: AppTypography.medium(
                              fontSize: 10,
                              color: AppColors.primaryButtonBg,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ScreenUtils.h(30)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

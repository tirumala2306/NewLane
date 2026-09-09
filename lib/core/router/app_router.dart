import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newlane/core/deep_links/deep_link_handler.dart';
import 'package:newlane/core/di/injection_container.dart';
import 'package:newlane/core/router/app_routes.dart';
import 'package:newlane/features/auth/bloc/request_status/request_status_bloc.dart';
import 'package:newlane/features/auth/screens/check_your_email_screen.dart';
import 'package:newlane/features/auth/screens/complete_profile_screen.dart';
import 'package:newlane/features/auth/screens/create_password_screen.dart';
import 'package:newlane/features/auth/screens/forgot_password_screen.dart';
import 'package:newlane/features/auth/screens/request_access_screen.dart';
import 'package:newlane/features/auth/screens/request_pending_screen.dart';
import 'package:newlane/features/auth/screens/reset_password_screen.dart';
import 'package:newlane/features/auth/screens/sign_in_screen.dart';
import 'package:newlane/features/chats/screens/chat_screen.dart';
import 'package:newlane/features/chats/screens/conversation_screen.dart';
import 'package:newlane/features/content_generator/domain/content_generator_draft.dart';
import 'package:newlane/features/content_generator/screens/content_generating_screen.dart';
import 'package:newlane/features/content_generator/screens/content_generator_details_screen.dart';
import 'package:newlane/features/content_generator/screens/content_generator_screen.dart';
import 'package:newlane/features/content_generator/screens/content_preview_screen.dart';
import 'package:newlane/features/create_post/domain/entities/post_location.dart';
import 'package:newlane/features/create_post/screens/add_location_screen.dart';
import 'package:newlane/features/create_post/screens/create_post_screen.dart';
import 'package:newlane/features/create_post/screens/tag_office_screen.dart';
import 'package:newlane/features/directory/screens/agent_detail_screen.dart';
import 'package:newlane/features/directory/screens/directory_screen.dart';
import 'package:newlane/features/directory/screens/office_directory_screen.dart';
import 'package:newlane/features/directory/domain/entities/directory_agent.dart';
import 'package:newlane/features/feed/screens/feed_screen.dart';
import 'package:newlane/features/home/screens/home_screen.dart';
import 'package:newlane/features/home/screens/main_shell.dart';
import 'package:newlane/features/marketing_request/domain/entities/marketing_request.dart';
import 'package:newlane/features/marketing_request/screens/marketing_request_detail_screen.dart';
import 'package:newlane/features/marketing_request/screens/marketing_request_screen.dart';
import 'package:newlane/features/marketing_request/screens/my_requests_screen.dart';
import 'package:newlane/features/more/data/more_info_content.dart';
import 'package:newlane/features/more/screens/about_screen.dart';
import 'package:newlane/features/more/screens/account_screen.dart';
import 'package:newlane/features/more/screens/help_support_screen.dart';
import 'package:newlane/features/more/screens/more_info_screen.dart';
import 'package:newlane/features/more/screens/more_screen.dart';
import 'package:newlane/features/more/screens/notifications_screen.dart';
import 'package:newlane/features/more/screens/office_screen.dart';
import 'package:newlane/features/more/screens/privacy_settings_screen.dart';
import 'package:newlane/features/more/screens/push_notifications_screen.dart';
import 'package:newlane/features/more/screens/security_settings_screen.dart';
import 'package:newlane/features/more/screens/terms_screen.dart';
import 'package:newlane/features/onboarding/screens/onboarding_page.dart';
import 'package:newlane/features/profile/screens/profile_screen.dart';
import 'package:newlane/features/support/data/mock/support_mock_data.dart';
import 'package:newlane/features/support/screens/new_support_ticket_screen.dart';
import 'package:newlane/features/support/screens/support_screen.dart';
import 'package:newlane/features/support/screens/ticket_conversation_screen.dart';
import 'package:newlane/features/support/screens/ticket_details_screen.dart';
import 'package:newlane/features/support/screens/ticket_support_screen.dart';
import 'package:newlane/features/training/screens/training_hub_screen.dart';
import 'package:newlane/shared/widgets/splash_screen.dart';

class AppRouter {
  const AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'home');
  static final GlobalKey<NavigatorState> _chatNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'chat');
  static final GlobalKey<NavigatorState> _feedNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'feed');
  static final GlobalKey<NavigatorState> _profileNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'profile');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    // Prevent GoRouter from treating newlane://… as a route path.
    // DeepLinkHandler converts those links to /create-password/:token.
    overridePlatformDefaultLocation: true,
    redirect: (BuildContext context, GoRouterState state) {
      return DeepLinkHandler.redirectForActivation(state.uri);
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.requestAccess,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) => InjectionContainer.instance.createRequestAccessBloc(),
            child: const RequestAccessScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.requestPending,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) => InjectionContainer.instance.createRequestStatusBloc()
              ..add(const RequestStatusStarted()),
            child: const RequestPendingScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.checkYourEmail,
        builder: (BuildContext context, GoRouterState state) {
          return const CheckYourEmailScreen();
        },
      ),
      GoRoute(
        path: '${AppRoutes.activate}/:token',
        redirect: (BuildContext context, GoRouterState state) {
          final String? token = state.pathParameters['token'];
          if (token == null || token.isEmpty) {
            return AppRoutes.checkYourEmail;
          }
          return AppRoutes.createPasswordWithToken(token);
        },
      ),
      GoRoute(
        path: '${AppRoutes.createPassword}/:token',
        builder: (BuildContext context, GoRouterState state) {
          final String token = state.pathParameters['token'] ?? '';
          return BlocProvider(
            create: (_) => InjectionContainer.instance.createActivateAccountBloc(),
            child: CreatePasswordScreen(activationToken: token),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.createPassword,
        redirect: (BuildContext context, GoRouterState state) {
          return AppRoutes.checkYourEmail;
        },
      ),
      GoRoute(
        path: '${AppRoutes.resetPassword}/:token',
        builder: (BuildContext context, GoRouterState state) {
          final String token = state.pathParameters['token'] ?? '';
          return BlocProvider(
            create: (_) =>
                InjectionContainer.instance.createResetPasswordBloc(),
            child: ResetPasswordScreen(resetToken: token),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        redirect: (BuildContext context, GoRouterState state) {
          return AppRoutes.forgotPassword;
        },
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) =>
                InjectionContainer.instance.createCompleteProfileBloc(),
            child: const CompleteProfileScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) => InjectionContainer.instance.createSignInBloc(),
            child: const SignInScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          final String initialEmail = extra is String ? extra : '';
          return BlocProvider(
            create: (_) =>
                InjectionContainer.instance.createForgotPasswordBloc(),
            child: ForgotPasswordScreen(initialEmail: initialEmail),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordSent,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          String email = '';
          String message =
              'If that email exists, a reset link has been sent.';
          if (extra is Map) {
            email = (extra['email'] as String?)?.trim() ?? '';
            final String? msg = (extra['message'] as String?)?.trim();
            if (msg != null && msg.isNotEmpty) message = msg;
          }
          return ForgotPasswordSentScreen(email: email, message: message);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.more,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider.value(
            value: InjectionContainer.instance.createProfileBloc(),
            child: const MoreScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.editProfile,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) =>
                InjectionContainer.instance.createCompleteProfileBloc(),
            child: const CompleteProfileScreen(isEditMode: true),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.moreInfo,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          final MoreInfoContent content = extra is MoreInfoContent
              ? extra
              : MoreInfoContent.about;
          return MoreInfoScreen(content: content);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.moreOffice,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider.value(
            value: InjectionContainer.instance.createProfileBloc(),
            child: const OfficeScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.moreNotifications,
        builder: (BuildContext context, GoRouterState state) {
          return const NotificationsScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.moreAccount,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider.value(
            value: InjectionContainer.instance.createProfileBloc(),
            child: const AccountScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.morePrivacy,
        builder: (BuildContext context, GoRouterState state) {
          return const PrivacySettingsScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.moreSecurity,
        builder: (BuildContext context, GoRouterState state) {
          return const SecuritySettingsScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.morePushNotifications,
        builder: (BuildContext context, GoRouterState state) {
          return const PushNotificationsScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.moreHelpSupport,
        builder: (BuildContext context, GoRouterState state) {
          return const HelpSupportScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.moreTerms,
        builder: (BuildContext context, GoRouterState state) {
          return const TermsScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.moreAbout,
        builder: (BuildContext context, GoRouterState state) {
          return const AboutScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.support,
        builder: (BuildContext context, GoRouterState state) {
          return const SupportScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.ticketSupport,
        builder: (BuildContext context, GoRouterState state) {
          return const TicketSupportScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.newSupportTicket,
        builder: (BuildContext context, GoRouterState state) {
          final String? category =
              state.extra is String ? state.extra as String : null;
          return NewSupportTicketScreen(initialCategory: category);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.ticketDetails,
        builder: (BuildContext context, GoRouterState state) {
          final SupportTicket? ticket = state.extra is SupportTicket
              ? state.extra as SupportTicket
              : null;
          if (ticket == null) {
            return const Scaffold(
              body: Center(child: Text('Ticket not found')),
            );
          }
          return TicketDetailsScreen(ticket: ticket);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.ticketConversation,
        builder: (BuildContext context, GoRouterState state) {
          final SupportTicket? ticket = state.extra is SupportTicket
              ? state.extra as SupportTicket
              : null;
          if (ticket == null) {
            return const Scaffold(
              body: Center(child: Text('Ticket not found')),
            );
          }
          return TicketConversationScreen(ticket: ticket);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.createPost,
        builder: (BuildContext context, GoRouterState state) {
          return const CreatePostScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.tagOffice,
        builder: (BuildContext context, GoRouterState state) {
          final int? selectedId = state.extra is int
              ? state.extra as int
              : null;
          return BlocProvider(
            create: (_) => InjectionContainer.instance.createTagOfficeBloc(
              selectedOfficeId: selectedId,
            ),
            child: TagOfficeScreen(selectedOfficeId: selectedId),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.addLocation,
        builder: (BuildContext context, GoRouterState state) {
          final PostLocation? initial = state.extra is PostLocation
              ? state.extra as PostLocation
              : null;
          return AddLocationScreen(initial: initial);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '${AppRoutes.conversation}/:chatId',
        builder: (BuildContext context, GoRouterState state) {
          final String chatId = state.pathParameters['chatId'] ?? '';
          final Object? extra = state.extra;
          String title = 'Chat';
          String avatarUrl = '';
          bool isAnnouncement = false;
          if (extra is Map) {
            title = (extra['title'] as String?)?.trim().isNotEmpty == true
                ? extra['title'] as String
                : title;
            avatarUrl = (extra['avatarUrl'] as String?) ?? '';
            isAnnouncement = extra['isAnnouncement'] == true;
          }
          return BlocProvider.value(
            value: InjectionContainer.instance.createProfileBloc(),
            child: ConversationScreen(
              chatId: chatId,
              title: title,
              avatarUrl: avatarUrl,
              isAnnouncement: isAnnouncement,
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.directory,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) => InjectionContainer.instance.createDirectoryBloc(),
            child: const DirectoryScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '${AppRoutes.directoryAgent}/:agentId',
        builder: (BuildContext context, GoRouterState state) {
          final int agentId =
              int.tryParse(state.pathParameters['agentId'] ?? '') ?? 0;
          final DirectoryAgent? initial = state.extra is DirectoryAgent
              ? state.extra as DirectoryAgent
              : null;
          return BlocProvider(
            create: (_) => InjectionContainer.instance.createAgentDetailBloc(
              agentId: agentId,
              initial: initial,
            ),
            child: AgentDetailScreen(agentId: agentId, initial: initial),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.officeDirectory,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) =>
                InjectionContainer.instance.createOfficeDirectoryBloc(),
            child: const OfficeDirectoryScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.contentGenerator,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider.value(
            value: InjectionContainer.instance.createProfileBloc(),
            child: const ContentGeneratorScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.contentGeneratorDetails,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider.value(
            value: InjectionContainer.instance.createProfileBloc(),
            child: ContentGeneratorDetailsScreen(
              draft: ContentGeneratorDraft.fromExtra(state.extra),
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.contentGeneratorGenerating,
        builder: (BuildContext context, GoRouterState state) {
          return ContentGeneratingScreen(
            draft: ContentGeneratorDraft.fromExtra(state.extra),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.contentGeneratorPreview,
        builder: (BuildContext context, GoRouterState state) {
          return ContentPreviewScreen(
            draft: ContentGeneratorDraft.fromExtra(state.extra),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.marketingRequest,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) =>
                InjectionContainer.instance.createMarketingRequestBloc(),
            child: const MarketingRequestScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.myRequests,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) => InjectionContainer.instance.createMyRequestsBloc(),
            child: const MyRequestsScreen(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.marketingRequestDetail,
        builder: (BuildContext context, GoRouterState state) {
          final MarketingRequest? initial = state.extra is MarketingRequest
              ? state.extra as MarketingRequest
              : null;
          return MarketingRequestDetailScreen(initial: initial);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return BlocProvider(
            create: (_) => InjectionContainer.instance.createProfileBloc(),
            child: MainShell(navigationShell: navigationShell),
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return const NoTransitionPage<void>(
                    child: HomeScreen(),
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'training-hub',
                    builder: (BuildContext context, GoRouterState state) {
                      return const TrainingHubScreen();
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _chatNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.chat,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return const NoTransitionPage<void>(
                    child: ChatScreen(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _feedNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.feed,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return NoTransitionPage<void>(
                    child: BlocProvider(
                      create: (_) =>
                          InjectionContainer.instance.createFeedBloc(),
                      child: const FeedScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return const NoTransitionPage<void>(
                    child: ProfileScreen(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

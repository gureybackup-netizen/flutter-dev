import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/providers.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/chat/screens/conversations_screen.dart';
import '../features/chat/screens/message_screen.dart';
import '../features/users/screens/search_screen.dart';
import '../features/calls/screens/outgoing_call_screen.dart';
import '../features/calls/screens/incoming_call_screen.dart';
import '../features/calls/screens/active_call_screen.dart';
import '../features/calls/screens/call_history_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/profile_settings_screen.dart';
import '../features/settings/screens/notification_settings_screen.dart';
import '../features/settings/screens/security_settings_screen.dart';
import 'constants.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: RouteConstants.splash,
    redirect: (context, state) {
      final isAuthenticated = authState.whenOrNull(
        data: (auth) => auth.session != null,
      ) ?? false;
      
      final isLoading = authState.isLoading;
      final currentPath = state.uri.path;
      
      final publicRoutes = [
        RouteConstants.splash,
        RouteConstants.welcome,
        RouteConstants.login,
        RouteConstants.register,
      ];
      
      final isPublicRoute = publicRoutes.contains(currentPath);
      
      if (isLoading) return null;
      
      if (!isAuthenticated && !isPublicRoute) {
        return RouteConstants.welcome;
      }
      
      if (isAuthenticated && isPublicRoute) {
        return RouteConstants.conversations;
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteConstants.conversations,
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: RouteConstants.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return MessageScreen(conversationId: conversationId);
        },
      ),
      GoRoute(
        path: '/call/outgoing/:callId',
        builder: (context, state) {
          final callId = state.pathParameters['callId']!;
          return OutgoingCallScreen(callId: callId);
        },
      ),
      GoRoute(
        path: '/call/incoming/:callId',
        builder: (context, state) {
          final callId = state.pathParameters['callId']!;
          return IncomingCallScreen(callId: callId);
        },
      ),
      GoRoute(
        path: '/call/active/:callId',
        builder: (context, state) {
          final callId = state.pathParameters['callId']!;
          return ActiveCallScreen(callId: callId);
        },
      ),
      GoRoute(
        path: RouteConstants.callHistory,
        builder: (context, state) => const CallHistoryScreen(),
      ),
      GoRoute(
        path: RouteConstants.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteConstants.profileSettings,
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
      GoRoute(
        path: RouteConstants.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: RouteConstants.securitySettings,
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
    ],
  );
});
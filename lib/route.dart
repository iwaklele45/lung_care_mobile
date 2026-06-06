import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/src/presentation/pages/auth/complete_profile_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/auth/forgot_password_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/auth/login_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/auth/password_reset_route_data.dart';
import 'package:lung_care_mobile/src/presentation/pages/auth/register_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/auth/reset_password_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/auth/verify_code_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/chatbot/chatbot_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/facilities/care_finder_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/history/full_history_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/history/history_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/home_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/meds/medication_tracker_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/profile/help_support_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/profile/settings_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/schedule/medication_schedule_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/splash_page.dart';

/// Application router configuration.
///
/// All GoRouter routes are defined here so that [main.dart] stays focused
/// on app bootstrap (Firebase init, providers, BLoC wiring).
GoRouter createRouter(GlobalKey<NavigatorState> navigatorKey) => GoRouter(
  navigatorKey: navigatorKey,
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/schedule',
      builder: (context, state) => MedicationSchedulePage(),
    ),
    GoRoute(
      path: '/medication-tracker',
      builder: (context, state) => const MedicationTrackerPage(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryPage(),
    ),
    GoRoute(
      path: '/history/full',
      builder: (context, state) => const FullHistoryPage(),
    ),
    GoRoute(
      path: '/chatbot',
      builder: (context, state) => const ChatbotPage(),
    ),
    GoRoute(
      path: '/facilities',
      builder: (context, state) => const CareFinderPage(),
    ),
    GoRoute(
      path: '/password_reset',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/verify_code',
      builder: (context, state) {
        final data = state.extra;
        if (data is! VerifyCodeRouteData) {
          return const ForgotPasswordPage();
        }
        return VerifyCodePage(data: data);
      },
    ),
    GoRoute(
      path: '/reset_password',
      builder: (context, state) {
        final data = state.extra;
        if (data is! ResetPasswordRouteData) {
          return const ForgotPasswordPage();
        }
        return ResetPasswordPage(data: data);
      },
    ),
    GoRoute(
      path: '/complete-profile',
      builder: (context, state) => const CompleteProfilePage(),
    ),
    GoRoute(
      path: '/help-support',
      builder: (context, state) => const HelpSupportPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);

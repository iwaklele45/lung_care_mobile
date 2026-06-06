import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/l10n/app_localizations.dart';
import 'package:lung_care_mobile/src/core/locale/locale_provider.dart';
import 'package:lung_care_mobile/src/core/notifications/notification_service.dart';

import 'package:lung_care_mobile/firebase_options.dart';
import 'package:lung_care_mobile/src/data/datasource/auth_remote_data_source.dart';
import 'package:lung_care_mobile/src/data/repositories/auth_repository_impl.dart';
import 'package:lung_care_mobile/src/domain/repositories/auth_repository.dart';
import 'package:lung_care_mobile/src/domain/usecases/check_user_profile.dart';
import 'package:lung_care_mobile/src/domain/usecases/confirm_password_reset.dart';
import 'package:lung_care_mobile/src/domain/usecases/create_user_with_email.dart';
import 'package:lung_care_mobile/src/domain/usecases/observe_auth_state.dart';
import 'package:lung_care_mobile/src/domain/usecases/request_password_reset_otp.dart';
import 'package:lung_care_mobile/src/domain/usecases/resend_password_reset_otp.dart';
import 'package:lung_care_mobile/src/domain/usecases/save_user_profile.dart';
import 'package:lung_care_mobile/src/domain/usecases/send_password_reset.dart';
import 'package:lung_care_mobile/src/domain/usecases/sign_in_with_email.dart';
import 'package:lung_care_mobile/src/domain/usecases/sign_in_with_google.dart';
import 'package:lung_care_mobile/src/domain/usecases/sign_out.dart';
import 'package:lung_care_mobile/src/domain/usecases/verify_password_reset_otp.dart';
import 'package:lung_care_mobile/src/presentation/bloc/auth/auth_bloc.dart';
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
import 'package:lung_care_mobile/src/presentation/pages/schedule/medication_schedule_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/splash_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/profile/help_support_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/notifications/medication_reminder_dialog.dart';
import 'package:lung_care_mobile/src/presentation/pages/profile/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.instance.initialize(
    onMedicationReminderSelected: (payload) {
      void showWhenReady([int attempts = 0]) {
        final context = MyApp.navigatorKey.currentContext;
        if (context != null) {
          MedicationReminderDialog.show(context, payload);
          return;
        }
        if (attempts >= 20) return;
        Future<void>.delayed(
          const Duration(milliseconds: 250),
          () => showWhenReady(attempts + 1),
        );
      }

      showWhenReady();
    },
  );
  // App Check DINONAKTIFKAN untuk sideloaded APK (Tugas Akhir).
  // - DebugProvider → butuh daftarkan token per device (tidak scalable).
  // - PlayIntegrity → hanya untuk app dari Play Store.
  // Pastikan App Check enforcement juga DIMATIKAN di Firebase Console.
  // TODO: Aktifkan kembali dengan PlayIntegrityProvider saat publish ke Play Store.
  final localeProvider = LocaleProvider();
  runApp(MyApp(localeProvider: localeProvider));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.localeProvider});

  final LocaleProvider localeProvider;

  static final navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter _router = GoRouter(
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocaleProvider>.value(
      value: localeProvider,
      child: RepositoryProvider<AuthRepository>(
        create: (_) =>
            AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSource()),
        child: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            observeAuthState: ObserveAuthState(
              repository: context.read<AuthRepository>(),
            ),
            signInWithEmail: SignInWithEmail(
              repository: context.read<AuthRepository>(),
            ),
            createUserWithEmail: CreateUserWithEmail(
              repository: context.read<AuthRepository>(),
            ),
            sendPasswordReset: SendPasswordReset(
              repository: context.read<AuthRepository>(),
            ),
            requestPasswordResetOtp: RequestPasswordResetOtp(
              repository: context.read<AuthRepository>(),
            ),
            verifyPasswordResetOtp: VerifyPasswordResetOtp(
              repository: context.read<AuthRepository>(),
            ),
            resendPasswordResetOtp: ResendPasswordResetOtp(
              repository: context.read<AuthRepository>(),
            ),
            confirmPasswordReset: ConfirmPasswordReset(
              repository: context.read<AuthRepository>(),
            ),
            signOut: SignOut(repository: context.read<AuthRepository>()),
            signInWithGoogle: SignInWithGoogle(
              repository: context.read<AuthRepository>(),
            ),
            checkUserProfile: CheckUserProfile(
              repository: context.read<AuthRepository>(),
            ),
            saveUserProfile: SaveUserProfile(
              repository: context.read<AuthRepository>(),
            ),
          )..add(CheckAuthStatusEvent()),
          child: ListenableBuilder(
            listenable: localeProvider,
            builder: (context, _) => MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'LungCare+',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              ),
              locale: localeProvider.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              routerConfig: _router,
            ),
          ),
        ),
      ),
    );
  }
}

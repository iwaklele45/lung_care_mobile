import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:lung_care_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lung_care_mobile/features/auth/domain/usecases/create_user_with_email.dart';
import 'package:lung_care_mobile/features/auth/domain/usecases/observe_auth_state.dart';
import 'package:lung_care_mobile/features/auth/domain/usecases/send_password_reset.dart';
import 'package:lung_care_mobile/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:lung_care_mobile/features/auth/domain/usecases/sign_out.dart';
import 'package:lung_care_mobile/firebase_options.dart';
import 'package:lung_care_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:lung_care_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:lung_care_mobile/src/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSource(),
    );
    final observeAuthState = ObserveAuthState(repository: authRepository);
    final signInWithEmail = SignInWithEmail(repository: authRepository);
    final createUserWithEmail = CreateUserWithEmail(repository: authRepository);
    final sendPasswordReset = SendPasswordReset(repository: authRepository);
    final signOut = SignOut(repository: authRepository);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Register page')),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Home')),
          ),
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            observeAuthState: observeAuthState,
            signInWithEmail: signInWithEmail,
            createUserWithEmail: createUserWithEmail,
            sendPasswordReset: sendPasswordReset,
            signOut: signOut,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'LungCare+',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          scaffoldBackgroundColor: const Color(0xFFF4F8FF),
        ),
        routerConfig: router,
      ),
    );
  }
}

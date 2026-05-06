import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/gen/assets.gen.dart';
import 'package:lung_care_mobile/src/presentation/bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
    });
  }

  Future<void> _navigateAfterDelay(String route) async {
    if (_hasNavigated) {
      return;
    }
    _hasNavigated = true;
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }
    context.go(route);
  }

  Future<void> _handleAuthError(String message) async {
    if (_hasNavigated) {
      return;
    }
    _hasNavigated = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _navigateAfterDelay('/home');
        } else if (state is AuthUnauthenticated) {
          _navigateAfterDelay('/login');
        } else if (state is AuthError) {
          _handleAuthError(state.message);
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF63A8FF), Color(0xFFEAF3FF)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Assets.icons.spashScreenIcon.image(width: 120, height: 120),
                const SizedBox(height: 24),
                const Text(
                  'LungCare+',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitoring pendampingan obat'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.5,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

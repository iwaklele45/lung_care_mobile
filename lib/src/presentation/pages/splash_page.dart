import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/gen/assets.gen.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  bool _hasNavigated = false;
  late final AnimationController _loadingController;
  late final Animation<double> _loadingProgress;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _loadingProgress = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLoadingAndNavigate('/password_reset');
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _startLoadingAndNavigate(String route) async {
    if (_hasNavigated) {
      return;
    }
    _hasNavigated = true;
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }
    await _loadingController.forward();
    if (!mounted) {
      return;
    }
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.linear],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.icons.spashScreenIcon.image(),
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
                      fontSize: 15,
                      letterSpacing: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 70,
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedBuilder(
                      animation: _loadingProgress,
                      builder: (context, child) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(color: Colors.white.withOpacity(0.65)),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: _loadingProgress.value,
                                child: Container(color: AppColors.secondary),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

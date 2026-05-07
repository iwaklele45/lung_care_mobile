import 'package:flutter/material.dart';
import 'package:lung_care_mobile/gen/assets.gen.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';

/// Motivational banner at the bottom of the home page.
class MotivationBanner extends StatelessWidget {
  const MotivationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.only(top: 48, bottom: 32),
        width: double.infinity,
        // height: 296.0,
        decoration: BoxDecoration(
          color: AppColors.ternary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Assets.icons.mainIcon.image(
            //   width: 64,
            //   height: 64,
            //   fit: BoxFit.contain,
            // ),
            Assets.icons.profileMotivationImg.image(),
            const SizedBox(height: 12),
            const Text(
              'Keep it up!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Consistency is the key to a\nhealthy recovery. You\'re doing\ngreat!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.nautral,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

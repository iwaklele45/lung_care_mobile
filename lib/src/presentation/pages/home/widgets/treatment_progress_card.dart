import 'package:flutter/material.dart';
import 'package:lung_care_mobile/gen/assets.gen.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';

/// Redesigned treatment progress card matching the Figma spec:
/// - "Treatment Progress" | "25% Complete" header row
/// - Thick, fully-rounded progress bar (dark-blue fill / light-blue track)
/// - "Day 45 of 180" | overlapping check-circle avatars + "+N" badge
class TreatmentProgressCard extends StatelessWidget {
  const TreatmentProgressCard({
    super.key,
    required this.treatmentDay,
    required this.totalDays,
    required this.progressPercent,
  });

  final int treatmentDay;
  final int totalDays;
  final double progressPercent;

  @override
  Widget build(BuildContext context) {
    final remaining = totalDays - treatmentDay;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Title + Percent ─────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Treatment Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${(progressPercent * 100).round()}% Complete',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Row 2: Thick progress bar ──────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final fillWidth = (totalWidth * progressPercent).clamp(
                0.0,
                totalWidth,
              );
              return Stack(
                children: [
                  // Track
                  Container(
                    height: 14,
                    width: totalWidth,
                    decoration: BoxDecoration(
                      color: AppColors.ternary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  // Fill with gradient
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    height: 14,
                    width: fillWidth,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563C8), AppColors.primary],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // ── Row 3: Day counter + overlapping badge circles ─────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Day $treatmentDay of $totalDays',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.nautral,
                ),
              ),
              _OverlappingBadges(remaining: remaining),
            ],
          ),
        ],
      ),
    );
  }
}

/// Three overlapping circles: two teal check-mark circles + a "+N" pill badge.
class _OverlappingBadges extends StatelessWidget {
  const _OverlappingBadges({required this.remaining});

  final int remaining;

  @override
  Widget build(BuildContext context) {
    const double size = 32.0;
    const double overlap = 10.0;

    return Row(
      children: [
        // Overlapping check circles
        SizedBox(
          width: size + (size - overlap),
          height: size,
          child: Stack(
            children: [
              // Second circle (behind, lighter)
              Positioned(child: Assets.icons.checkRoundedIconSvg.svg()),
              // First circle (front, darker)
              Positioned(
                left: size - overlap,
                child: Assets.icons.checkRoundedIconSvg.svg(),
              ),
            ],
          ),
        ),

        // "+N" pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.ternary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '+$remaining',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.nautral,
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 2),
      ),
      child: Icon(Icons.check_rounded, size: 16, color: color),
    );
  }
}

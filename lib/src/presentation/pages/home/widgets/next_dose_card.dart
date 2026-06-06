import 'package:flutter/material.dart';
import 'package:lung_care_mobile/l10n/app_localizations.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';

/// Hero card showing the next upcoming dose with a "Check-in" CTA.
/// The button is only enabled when the current time is within ±15 minutes
/// of the scheduled dose time.
class NextDoseCard extends StatelessWidget {
  const NextDoseCard({
    super.key,
    required this.time,
    required this.medicineName,
    required this.onCheckIn,
    this.isLoading = false,
  });

  final String time;
  final String medicineName;
  final VoidCallback onCheckIn;
  final bool isLoading;

  /// Returns `true` if [time] (e.g. "7:00 AM") is within ±15 minutes of now.
  bool _isNearScheduledTime() {
    try {
      final parts = time.split(' ');
      if (parts.length != 2) return false;
      final digits = parts[0].split(':');
      if (digits.length != 2) return false;
      int? h = int.tryParse(digits[0]);
      int? m = int.tryParse(digits[1]);
      if (h == null || m == null) return false;
      final isPM = parts[1].toUpperCase() == 'PM';
      if (isPM && h != 12) h += 12;
      if (!isPM && h == 12) h = 0;

      final now = TimeOfDay.now();
      final scheduledMin = h * 60 + m;
      final nowMin = now.hour * 60 + now.minute;
      return (nowMin - scheduledMin).abs() <= 15;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final canCheckIn = _isNearScheduledTime();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B80D9), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // "NEXT DOSE" label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l.nextDose,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Time
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Medicine name
          Text(
            medicineName,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 20),
          // Check-in button — disabled when not near scheduled time
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: (isLoading || !canCheckIn) ? null : onCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                disabledForegroundColor: Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      canCheckIn
                          ? Icons.check_circle_outline_rounded
                          : Icons.lock_clock_rounded,
                      size: 20,
                    ),
              label: Text(
                isLoading
                    ? l.checkingIn
                    : canCheckIn
                        ? l.checkInDose
                        : l.notYetTime,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

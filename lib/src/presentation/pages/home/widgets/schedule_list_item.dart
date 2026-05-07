import 'package:flutter/material.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/presentation/bloc/home/home_bloc.dart';

/// A single row in the schedule list showing medicine name, time, dosage, and
/// a status badge (Pending / Taken / Missed).
class ScheduleListItem extends StatelessWidget {
  const ScheduleListItem({super.key, required this.item});

  final MedicationScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final isTaken = item.status == 'taken';

    return Opacity(
      opacity: isTaken ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isTaken
                ? AppColors.secondary.withValues(alpha: 0.3)
                : AppColors.ternary,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Medicine icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isTaken
                    ? AppColors.ternary
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isTaken
                    ? Icons.check_circle_outline_rounded
                    : Icons.medication_liquid_rounded,
                color: isTaken ? AppColors.nautral : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Name + time + dosage
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isTaken ? AppColors.nautral : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.time} · ${item.dosage}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.nautral,
                    ),
                  ),
                ],
              ),
            ),
            // Status badge
            _StatusBadge(status: item.status),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final String label;

    switch (status) {
      case 'taken':
        bgColor = AppColors.ternary;
        textColor = AppColors.nautral;
        label = 'Taken';
      case 'missed':
        bgColor = const Color(0xFFFFEDED);
        textColor = const Color(0xFFD32F2F);
        label = 'Missed';
      default:
        bgColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFF57C00);
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

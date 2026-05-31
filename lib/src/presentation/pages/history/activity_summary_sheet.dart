import 'package:flutter/material.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';

/// Bottom sheet showing a day's medication status and check-in summary.
class ActivitySummarySheet extends StatelessWidget {
  const ActivitySummarySheet({super.key, this.date = '20 Mei 2024'});

  final String date;

  static Future<void> show(BuildContext context, {String? date}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ActivitySummarySheet(date: date ?? '20 Mei 2024'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD8E2F0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Aktivitas',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.nautral,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.ternary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: AppColors.nautral),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionLabel('STATUS OBAT'),
          const SizedBox(height: 10),
          const _MedStatusCard(name: 'Rifampicin', time: '07:30 AM'),
          const SizedBox(height: 10),
          const _MedStatusCard(name: 'Isoniazid', time: '07:30 AM'),
          const SizedBox(height: 20),
          const _SectionLabel('HASIL CHECK-IN'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bodyColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: const [
                Row(
                  children: [
                    Expanded(
                      child: _SymptomResult(emoji: '🤢', label: 'Mual', level: 'Sedang', color: Color(0xFFF59E0B)),
                    ),
                    Expanded(
                      child: _SymptomResult(emoji: '😵‍💫', label: 'Pusing', level: 'Ringan', color: Color(0xFFF59E0B)),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _SymptomResult(emoji: '😴', label: 'Lelah', level: 'Ringan', color: Color(0xFFF59E0B)),
                    ),
                    Expanded(
                      child: _SymptomResult(emoji: '🌡️', label: 'Demam', level: 'Tidak', color: Color(0xFF16A34A)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('CATATAN'),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD8E2F0)),
            ),
            child: const Text(
              '"Hari ini merasa agak mual setelah minum obat Rifampisin, '
              'tapi pusing sudah berkurang dibanding kemarin."',
              style: TextStyle(fontSize: 14, color: AppColors.black, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w600,
        color: AppColors.nautral,
      ),
    );
  }
}

class _MedStatusCard extends StatelessWidget {
  const _MedStatusCard({required this.name, required this.time});

  final String name;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bodyColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: AppColors.nautral),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 13, color: AppColors.nautral),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: Color(0xFF16A34A)),
                SizedBox(width: 4),
                Text(
                  'Diminum',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SymptomResult extends StatelessWidget {
  const _SymptomResult({
    required this.emoji,
    required this.label,
    required this.level,
    required this.color,
  });

  final String emoji;
  final String label;
  final String level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            Text(
              level,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';

class MedStatus {
  const MedStatus({
    required this.name,
    required this.time,
    required this.taken,
  });

  final String name;
  final String time;
  final bool taken;
}

/// Bottom sheet showing a day's medication status and check-in summary.
class ActivitySummarySheet extends StatelessWidget {
  const ActivitySummarySheet({
    super.key,
    required this.date,
    required this.medStatuses,
    this.symptoms,
    this.notes,
  });

  final String date;
  final List<MedStatus> medStatuses;
  final Map<String, int>? symptoms;
  final String? notes;

  static Future<void> show(
    BuildContext context, {
    required String date,
    required List<MedStatus> medStatuses,
    Map<String, int>? symptoms,
    String? notes,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ActivitySummarySheet(
        date: date,
        medStatuses: medStatuses,
        symptoms: symptoms,
        notes: notes,
      ),
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
          if (medStatuses.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bodyColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'Tidak ada data obat untuk hari ini.',
                  style: TextStyle(color: AppColors.nautral, fontSize: 13),
                ),
              ),
            )
          else
            ...medStatuses.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MedStatusCard(
                  name: m.name,
                  time: m.time,
                  taken: m.taken,
                ),
              ),
            ),
          if (symptoms != null && symptoms!.isNotEmpty) ...[
            const SizedBox(height: 10),
            const _SectionLabel('HASIL CHECK-IN'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bodyColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: _buildSymptomsGrid(),
            ),
          ],
          if (notes != null && notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
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
              child: Text(
                '"$notes"',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSymptomsGrid() {
    final labels = {
      'nausea': ('Mual', '🤢'),
      'dizziness': ('Pusing', '😵'),
      'fatigue': ('Lelah', '😴'),
      'fever': ('Demam', '🌡️'),
    };
    const levelNames = ['Tidak', 'Ringan', 'Sedang', 'Berat', 'Sangat Berat'];
    const levelColors = [
      Color(0xFF16A34A),
      Color(0xFFF59E0B),
      Color(0xFFF59E0B),
      Color(0xFFD32F2F),
      Color(0xFFD32F2F),
    ];

    final entries = symptoms!.entries.where(
      (e) => e.value > 0,
    ).toList();

    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada gejala.',
          style: TextStyle(color: AppColors.nautral, fontSize: 13),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: entries.map((e) {
        final info = labels[e.key] ?? (e.key, '📋');
        final level = e.value.clamp(0, 4);
        return SizedBox(
          width: 140,
          child: Row(
            children: [
              Text(info.$2, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.$1,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      levelNames[level],
                      style: TextStyle(
                        fontSize: 12,
                        color: levelColors[level],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
  const _MedStatusCard({
    required this.name,
    required this.time,
    required this.taken,
  });

  final String name;
  final String time;
  final bool taken;

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
              color: taken
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : const Color(0xFFFADCDC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medication,
              color: taken ? AppColors.primary : const Color(0xFFD32F2F),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: taken ? AppColors.black : AppColors.nautral,
                    decoration: taken ? null : TextDecoration.lineThrough,
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
              color: taken ? const Color(0xFFD1FAE5) : const Color(0xFFFADCDC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  taken ? Icons.check_circle : Icons.cancel,
                  size: 14,
                  color: taken ? const Color(0xFF16A34A) : const Color(0xFFD32F2F),
                ),
                const SizedBox(width: 4),
                Text(
                  taken ? 'Diminum' : 'Terlewat',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: taken ? const Color(0xFF16A34A) : const Color(0xFFD32F2F),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/presentation/pages/history/activity_summary_sheet.dart';

/// "Riwayat Lengkap": full medication history grouped by month.
class FullHistoryPage extends StatelessWidget {
  const FullHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyColor,
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Riwayat Lengkap',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          const _MonthLabel('BULAN INI'),
          const SizedBox(height: 12),
          _HistoryCard(
            dateTime: '22 April 2026, 08:00',
            name: 'Amlodipine 5mg',
            detail: '1 Tablet - Pagi Hari',
            taken: true,
            onTap: () => ActivitySummarySheet.show(context, date: '22 April 2026'),
          ),
          const SizedBox(height: 12),
          _HistoryCard(
            dateTime: '21 April 2026, 20:00',
            name: 'Atorvastatin 20mg',
            detail: '1 Tablet - Malam Hari',
            taken: false,
            onTap: () => ActivitySummarySheet.show(context, date: '21 April 2026'),
          ),
          const SizedBox(height: 12),
          _HistoryCard(
            dateTime: '21 April 2026, 08:00',
            name: 'Amlodipine 5mg',
            detail: '1 Tablet - Pagi Hari',
            taken: true,
            onTap: () => ActivitySummarySheet.show(context, date: '21 April 2026'),
          ),
          const SizedBox(height: 24),
          const _MonthLabel('BULAN LALU'),
          const SizedBox(height: 12),
          _HistoryCard(
            dateTime: '30 Maret 2026, 08:00',
            name: 'Amlodipine 5mg',
            detail: '1 Tablet - Pagi Hari',
            taken: true,
            onTap: () => ActivitySummarySheet.show(context, date: '30 Maret 2026'),
          ),
        ],
      ),
    );
  }
}

class _MonthLabel extends StatelessWidget {
  const _MonthLabel(this.text);

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

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.dateTime,
    required this.name,
    required this.detail,
    required this.taken,
    required this.onTap,
  });

  final String dateTime;
  final String name;
  final String detail;
  final bool taken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = taken ? const Color(0xFF16A34A) : const Color(0xFFD32F2F);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8EEF6)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(14),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateTime,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.nautral,
                            ),
                          ),
                          _StatusChip(taken: taken),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.nautral,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.taken});

  final bool taken;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: taken ? const Color(0xFFD1FAE5) : const Color(0xFFFADCDC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        taken ? 'Sudah Diminum' : 'Terlewat',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: taken ? const Color(0xFF16A34A) : const Color(0xFFD32F2F),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/presentation/pages/hamburger/hamburger_menu.dart';
import 'package:lung_care_mobile/src/presentation/pages/history/activity_summary_sheet.dart';

/// "History" page: adherence calendar + recent log details.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyColor,
      drawer: const HamburgerMenu(selectedIndex: 1),
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        elevation: 1,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'History',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          const Text(
            'History',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Review your daily medication adherence.',
            style: TextStyle(fontSize: 14, color: AppColors.nautral),
          ),
          const SizedBox(height: 18),
          const _CalendarCard(),
          const SizedBox(height: 24),
          const Text(
            'Log Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 14),
          _LogCard(
            date: '20 May 2024',
            time: '09:05 AM',
            status: _LogStatus.verified,
            onTap: () => ActivitySummarySheet.show(context, date: '20 Mei 2024'),
          ),
          const SizedBox(height: 12),
          _LogCard(
            date: '07 May 2024',
            time: '09:00 AM',
            status: _LogStatus.missed,
            onTap: () => ActivitySummarySheet.show(context, date: '07 Mei 2024'),
          ),
          const SizedBox(height: 12),
          _LogCard(
            date: '21 May 2024',
            time: '09:05 AM',
            status: _LogStatus.verified,
            onTap: () => ActivitySummarySheet.show(context, date: '21 Mei 2024'),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () => context.push('/history/full'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9BE8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Lihat semua riwayat',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatefulWidget {
  const _CalendarCard();

  @override
  State<_CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<_CalendarCard> {
  // Demo data: day -> status (taken/missed). Days beyond 21 are disabled.
  static const _taken = {
    1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
  };
  static const _missed = {7};
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  int _selectedDay = 20;

  void _onDayTap(int day) {
    setState(() => _selectedDay = day);
    ActivitySummarySheet.show(context, date: '$day ${_months[4]} 2024');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Icons.chevron_left, color: AppColors.nautral),
              Text(
                'May 2024',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.nautral),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.nautral,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          // May 2024 starts on Wednesday (offset 3).
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.9,
            children: List.generate(35, (i) {
              final day = i - 2; // offset so day 1 lands on Wednesday
              if (day < 1 || day > 25) return const SizedBox.shrink();
              final disabled = day > 21;
              return _DayCell(
                day: day,
                taken: _taken.contains(day),
                missed: _missed.contains(day),
                selected: day == _selectedDay,
                disabled: disabled,
                onTap: disabled ? null : () => _onDayTap(day),
              );
            }),
          ),
          const Divider(height: 24, color: Color(0xFFE8EEF6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _Legend(color: AppColors.primary, label: 'Taken'),
              SizedBox(width: 24),
              _Legend(color: Color(0xFFD32F2F), label: 'Missed'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.taken,
    required this.missed,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final int day;
  final bool taken;
  final bool missed;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? Colors.white
                  : disabled
                  ? const Color(0xFFC2CCDA)
                  : AppColors.black,
            ),
          ),
        ),
        const SizedBox(height: 2),
        if (!selected && (taken || missed))
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: missed ? const Color(0xFFD32F2F) : AppColors.primary,
              shape: BoxShape.circle,
            ),
          )
        else
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.black),
        ),
      ],
    );
  }
}

enum _LogStatus { verified, missed }

class _LogCard extends StatelessWidget {
  const _LogCard({
    required this.date,
    required this.time,
    required this.status,
    required this.onTap,
  });

  final String date;
  final String time;
  final _LogStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isMissed = status == _LogStatus.missed;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isMissed ? const Color(0xFFFDF0F0) : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isMissed ? const Color(0xFFF6D6D6) : const Color(0xFFE8EEF6),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isMissed
                    ? const Color(0xFFF8D7D7)
                    : AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isMissed ? Icons.close : Icons.check,
                color: isMissed ? const Color(0xFFD32F2F) : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.nautral,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isMissed ? AppColors.nautral : AppColors.black,
                      decoration: isMissed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isMissed
                    ? const Color(0xFFFADCDC)
                    : AppColors.ternary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isMissed ? 'Missed' : 'Terverifikasi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isMissed ? const Color(0xFFD32F2F) : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

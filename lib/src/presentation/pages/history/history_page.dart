import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/presentation/pages/hamburger/hamburger_menu.dart';
import 'package:lung_care_mobile/src/presentation/pages/history/activity_summary_sheet.dart';

/// "History" page: adherence calendar + recent log details.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const _bulanIndo = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static String _formatDateIndo(DateTime dt) =>
      '${dt.day} ${_bulanIndo[dt.month]} ${dt.year}';

  static String _formatDateEn(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

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
            date: _formatDateEn(today),
            time: '09:05 AM',
            status: _LogStatus.verified,
            onTap: () => ActivitySummarySheet.show(context, date: _formatDateIndo(today)),
          ),
          const SizedBox(height: 12),
          _LogCard(
            date: _formatDateEn(weekAgo),
            time: '09:00 AM',
            status: _LogStatus.missed,
            onTap: () => ActivitySummarySheet.show(context, date: _formatDateIndo(weekAgo)),
          ),
          const SizedBox(height: 12),
          _LogCard(
            date: _formatDateEn(yesterday),
            time: '09:05 AM',
            status: _LogStatus.verified,
            onTap: () => ActivitySummarySheet.show(context, date: _formatDateIndo(yesterday)),
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
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  late DateTime _now;
  late int _today;
  late int _daysInMonth;
  late int _firstWeekday; // 0=Sun, 1=Mon ... 6=Sat
  late Set<int> _taken;
  late Set<int> _missed;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _today = _now.day;
    _daysInMonth = DateTime(_now.year, _now.month + 1, 0).day;
    // DateTime.weekday: 1=Mon ... 7=Sun → convert ke 0=Sun grid
    final firstOfMonth = DateTime(_now.year, _now.month, 1);
    _firstWeekday = firstOfMonth.weekday % 7; // 0=Sun

    // Demo: semua hari sampai kemarin = taken, kecuali 7 hari lalu = missed
    final missedDay = _today - 7;
    _taken = {};
    _missed = {};
    for (var d = 1; d < _today; d++) {
      if (d == missedDay) {
        _missed.add(d);
      } else {
        _taken.add(d);
      }
    }
    _selectedDay = _today;
  }

  void _onDayTap(int day) {
    setState(() => _selectedDay = day);
    ActivitySummarySheet.show(
      context,
      date: '$day ${_months[_now.month - 1]} ${_now.year}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = '${_months[_now.month - 1]} ${_now.year}';
    final totalCells = _firstWeekday + _daysInMonth;
    final rows = ((totalCells + 6) ~/ 7) * 7; // round up to full weeks

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
            children: [
              const Icon(Icons.chevron_left, color: AppColors.nautral),
              Text(
                monthLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.nautral),
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
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.9,
            children: List.generate(rows, (i) {
              final day = i - _firstWeekday + 1;
              if (day < 1 || day > _daysInMonth) return const SizedBox.shrink();
              final disabled = day > _today;
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

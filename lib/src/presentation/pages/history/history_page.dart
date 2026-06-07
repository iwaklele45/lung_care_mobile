import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/presentation/bloc/history/history_bloc.dart';
import 'package:lung_care_mobile/src/presentation/pages/hamburger/hamburger_menu.dart';
import 'package:lung_care_mobile/src/presentation/pages/history/activity_summary_sheet.dart';

/// "History" page: adherence calendar + recent log details.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return BlocProvider(
      create: (_) => HistoryBloc()
        ..add(HistoryFetchRequested(year: now.year, month: now.month)),
      child: const _HistoryBody(),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody();

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
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is HistoryError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.nautral, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (state is HistoryLoaded) {
            return _LoadedContent(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  const _LoadedContent({required this.state});

  final HistoryLoaded state;

  void _showDaySummary(BuildContext context, CalendarDayData day) {
    final dateStr =
        '${state.displayYear}-${state.displayMonth.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final dateLabel = '${day.day} ${state.monthLabel.split(' ')[0]} ${state.displayYear}';

    final dayDoseCheckIns =
        state.doseCheckIns.where((d) => d['date'] == dateStr).toList();
    final dayHealth =
        state.healthTrackings.where((h) => h['date'] == dateStr).toList();
    final healthData = dayHealth.isNotEmpty ? dayHealth.first : null;

    final scheduleMap = {for (final s in state.schedules) s.id ?? '': s};

    final medStatuses = dayDoseCheckIns.map((d) {
      final scheduleId = d['schedule_id'] as String? ?? '';
      final schedule = scheduleMap[scheduleId];
      final timeIdx = d['time_index'] as int? ?? 0;
      final minutes = schedule != null &&
              timeIdx < schedule.times.length
          ? () {
              final t = schedule.times[timeIdx];
              final h = t.hour;
              final m = t.minute;
              final ampm = h >= 12 ? 'PM' : 'AM';
              final dh = h == 0 ? 12 : h > 12 ? h - 12 : h;
              return '$dh:${m.toString().padLeft(2, '0')} $ampm';
            }()
          : '--:--';
      return MedStatus(
        name: schedule?.name ?? 'Obat tidak dikenal',
        time: minutes,
        taken: true,
      );
    }).toList();

    if (day.status == CalendarDayStatus.missed && medStatuses.isEmpty) {
      for (final s in state.schedules) {
        for (final t in s.times) {
          final h = t.hour;
          final m = t.minute;
          final ampm = h >= 12 ? 'PM' : 'AM';
          final dh = h == 0 ? 12 : h > 12 ? h - 12 : h;
          medStatuses.add(MedStatus(
            name: s.name,
            time: '$dh:${m.toString().padLeft(2, '0')} $ampm',
            taken: false,
          ));
        }
      }
    }

    ActivitySummarySheet.show(
      context,
      date: dateLabel,
      medStatuses: medStatuses,
      symptoms: healthData?['symptoms'] is Map
          ? Map<String, int>.from(healthData!['symptoms'] as Map)
          : null,
      notes: healthData?['additional_notes'] as String?,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
        _CalendarCard(
          monthLabel: state.monthLabel,
          days: state.calendarDays,
          firstWeekday: state.firstWeekday,
          displayYear: state.displayYear,
          displayMonth: state.displayMonth,
          onMonthChange: (offset) {
            context.read<HistoryBloc>().add(HistoryChangeMonth(offset));
          },
          onDayTap: (day) => _showDaySummary(context, day),
        ),
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
        if (state.recentLogs.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'Belum ada riwayat aktivitas.',
                style: TextStyle(color: AppColors.nautral, fontSize: 14),
              ),
            ),
          )
        else
          ...state.recentLogs.map((log) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LogCard(
                  date: log.date,
                  time: log.time,
                  status: log.taken ? _LogStatus.verified : _LogStatus.missed,
                  isHealthCheckIn: log.isHealthCheckIn,
                  title: log.title,
                  subtitle: log.subtitle,
                  onTap: () {
                    final dateStr = '${log.date.split(' ')[0]} ${log.date.split(' ')[1]} ${log.date.split(' ')[2]}';
                    final dayParts = log.date.split(' ');
                    if (dayParts.isNotEmpty) {
                      ActivitySummarySheet.show(
                        context,
                        date: dateStr,
                        medStatuses: [],
                        notes: null,
                      );
                    }
                  },
                ),
              )),
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
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.monthLabel,
    required this.days,
    required this.firstWeekday,
    required this.displayYear,
    required this.displayMonth,
    required this.onMonthChange,
    required this.onDayTap,
  });

  final String monthLabel;
  final List<CalendarDayData> days;
  final int firstWeekday;
  final int displayYear;
  final int displayMonth;
  final ValueChanged<int> onMonthChange;
  final ValueChanged<CalendarDayData> onDayTap;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isCurrentMonth =
        displayYear == today.year && displayMonth == today.month;
    final totalCells = firstWeekday + days.length;
    final rows = ((totalCells + 6) ~/ 7) * 7;

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
              GestureDetector(
                onTap: () => onMonthChange(-1),
                child: const Icon(Icons.chevron_left, color: AppColors.nautral),
              ),
              Text(
                monthLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              GestureDetector(
                onTap: isCurrentMonth ? null : () => onMonthChange(1),
                child: Icon(
                  Icons.chevron_right,
                  color: isCurrentMonth
                      ? const Color(0xFFC2CCDA)
                      : AppColors.nautral,
                ),
              ),
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
              final index = i - firstWeekday;
              if (index < 0 || index >= days.length) {
                return const SizedBox.shrink();
              }
              final day = days[index];
              final isToday = isCurrentMonth &&
                  day.day == DateTime.now().day;
              return _DayCell(
                day: day.day,
                status: day.status,
                isToday: isToday,
                onTap: day.status == CalendarDayStatus.future
                    ? null
                    : () => onDayTap(day),
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
    required this.status,
    required this.isToday,
    required this.onTap,
  });

  final int day;
  final CalendarDayStatus status;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isFuture = status == CalendarDayStatus.future;
    final isTaken = status == CalendarDayStatus.taken;
    final isMissed = status == CalendarDayStatus.missed;
    final isPending = status == CalendarDayStatus.pending;
    final isSelected = isToday || isPending;

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
              color: isSelected ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !isPending
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : isFuture
                        ? const Color(0xFFC2CCDA)
                        : AppColors.black,
              ),
            ),
          ),
          const SizedBox(height: 2),
          if (isTaken || isMissed)
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: isMissed ? const Color(0xFFD32F2F) : AppColors.primary,
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
    required this.isHealthCheckIn,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String date;
  final String time;
  final _LogStatus status;
  final bool isHealthCheckIn;
  final String title;
  final String subtitle;
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
                    : isHealthCheckIn
                        ? const Color(0xFFD1FAE5)
                        : AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isMissed
                    ? Icons.close
                    : isHealthCheckIn
                        ? Icons.favorite
                        : Icons.check,
                color: isMissed
                    ? const Color(0xFFD32F2F)
                    : isHealthCheckIn
                        ? const Color(0xFF16A34A)
                        : AppColors.primary,
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
                    style: const TextStyle(fontSize: 13, color: AppColors.nautral),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isMissed ? AppColors.nautral : AppColors.black,
                      decoration: isMissed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      time.isNotEmpty ? '$time  $subtitle' : subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.nautral,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isMissed
                    ? const Color(0xFFFADCDC)
                    : isHealthCheckIn
                        ? const Color(0xFFD1FAE5)
                        : AppColors.ternary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isMissed
                    ? 'Missed'
                    : isHealthCheckIn
                        ? 'Selesai'
                        : 'Terverifikasi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isMissed
                      ? const Color(0xFFD32F2F)
                      : isHealthCheckIn
                          ? const Color(0xFF16A34A)
                          : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

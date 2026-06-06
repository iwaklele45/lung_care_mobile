import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/presentation/bloc/history/history_bloc.dart';
import 'package:lung_care_mobile/src/presentation/pages/history/activity_summary_sheet.dart';

/// "Riwayat Lengkap": full medication history grouped by month.
class FullHistoryPage extends StatelessWidget {
  const FullHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryBloc()..add(HistoryFetchAllRequested()),
      child: const _FullHistoryBody(),
    );
  }
}

class _FullHistoryBody extends StatelessWidget {
  const _FullHistoryBody();

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
                  style: const TextStyle(
                    color: AppColors.nautral,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (state is HistoryAllLoaded) {
            if (state.sections.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Belum ada riwayat pengobatan.\nMulai check-in dosis dan health tracking!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.nautral,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                for (final section in state.sections) ...[
                  _MonthLabel(section.label),
                  const SizedBox(height: 12),
                  ...section.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HistoryCard(
                        date: entry.date,
                        time: entry.time,
                        name: entry.title,
                        detail: entry.subtitle,
                        taken: entry.taken,
                        isHealthCheckIn: entry.isHealthCheckIn,
                        onTap: () {
                          ActivitySummarySheet.show(
                            context,
                            date: entry.date,
                            medStatuses: [],
                            notes: null,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          }
          return const SizedBox.shrink();
        },
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
    required this.date,
    required this.time,
    required this.name,
    required this.detail,
    required this.taken,
    required this.isHealthCheckIn,
    required this.onTap,
  });

  final String date;
  final String time;
  final String name;
  final String detail;
  final bool taken;
  final bool isHealthCheckIn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = taken
        ? isHealthCheckIn
            ? const Color(0xFF8B5CF6)
            : const Color(0xFF16A34A)
        : const Color(0xFFD32F2F);

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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.nautral,
                                ),
                              ),
                              if (time.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  time,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.nautral,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          _StatusChip(
                            taken: taken,
                            isHealthCheckIn: isHealthCheckIn,
                          ),
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
                      if (detail.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          detail,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.nautral,
                          ),
                        ),
                      ],
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
  const _StatusChip({required this.taken, required this.isHealthCheckIn});

  final bool taken;
  final bool isHealthCheckIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: taken
            ? isHealthCheckIn
                ? const Color(0xFFEDE9FE)
                : const Color(0xFFD1FAE5)
            : const Color(0xFFFADCDC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        taken
            ? isHealthCheckIn
                ? 'Check-in'
                : 'Sudah Diminum'
            : 'Terlewat',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: taken
              ? isHealthCheckIn
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFF16A34A)
              : const Color(0xFFD32F2F),
        ),
      ),
    );
  }
}

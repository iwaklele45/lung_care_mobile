import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/presentation/bloc/home/home_bloc.dart';
import 'package:lung_care_mobile/src/presentation/pages/hamburger/hamburger_menu.dart';
import 'package:lung_care_mobile/src/presentation/pages/checkin/check_in_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/profile/profile_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/meds/add_medication_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/home/widgets/header.dart';
import 'package:lung_care_mobile/src/presentation/pages/home/widgets/home_app_bar.dart';
import 'package:lung_care_mobile/src/presentation/pages/home/widgets/home_bottom_nav_bar.dart';
import 'package:lung_care_mobile/src/presentation/pages/home/widgets/medication_reminder_modal.dart';
import 'package:lung_care_mobile/src/presentation/pages/home/widgets/motivation_banner.dart';
import 'package:lung_care_mobile/src/presentation/pages/home/widgets/next_dose_card.dart';
import 'package:lung_care_mobile/src/presentation/pages/home/widgets/schedule_list_item.dart';
import 'package:lung_care_mobile/src/presentation/pages/home/widgets/treatment_progress_card.dart';

class HomeBodyView extends StatefulWidget {
  const HomeBodyView({super.key});

  @override
  State<HomeBodyView> createState() => _HomeBodyViewState();
}

class _HomeBodyViewState extends State<HomeBodyView> {
  int _navIndex = 0;
  Timer? _reminderTimer;
  DateTime? _lastReminderMinute;

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  void _startReminderCheck(List<MedicationScheduleItem> schedules) {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) return;
      final now = TimeOfDay.now();
      final minuteKey = DateTime(now.hour, now.minute);
      if (_lastReminderMinute == minuteKey) return;

      final pending = schedules.where((s) => s.status == 'pending').toList();
      for (final item in pending) {
        final parts = item.time.split(' ');
        if (parts.length != 2) continue;
        final timeDigits = parts[0].split(':');
        if (timeDigits.length != 2) continue;
        int? h = int.tryParse(timeDigits[0]);
        int? m = int.tryParse(timeDigits[1]);
        if (h == null || m == null) continue;
        final isPM = parts[1].toUpperCase() == 'PM';
        if (isPM && h != 12) h += 12;
        if (!isPM && h == 12) h = 0;
        if (h == now.hour && m == now.minute) {
          _lastReminderMinute = minuteKey;
          _showReminder(pending);
          break;
        }
      }
    });
  }

  void _showReminder(List<MedicationScheduleItem> pending) {
    MedicationReminderModal.show(
      context,
      items: pending,
      onConfirm: () {
        final item = pending.first;
        if (mounted) {
          context.read<HomeBloc>().add(HomeCheckInDoseRequested(item: item));
        }
      },
      onSnooze: () {
        _lastReminderMinute = null;
        Future.delayed(const Duration(minutes: 10), () {
          if (mounted) {
            final state = context.read<HomeBloc>().state;
            if (state is HomeLoaded) {
              _showReminder(
                state.schedules.where((s) => s.status == 'pending').toList(),
              );
            }
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        if (state is HomeCheckInSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Dose check-in recorded! 🎉'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return Scaffold(
            backgroundColor: AppColors.bodyColor,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is HomeLoaded || state is HomeCheckInSuccess) {
          final loaded = state is HomeLoaded
              ? state
              : context.read<HomeBloc>().state as HomeLoaded;
          final isCheckingIn = false;

          _startReminderCheck(loaded.schedules);

          return Scaffold(
            backgroundColor: AppColors.bodyColor,
            drawer: const HamburgerMenu(),
            appBar: _navIndex == 0
                ? HomeAppBar(userName: loaded.userName)
                : AppBar(
                    backgroundColor: AppColors.appbarColor,
                    elevation: 1,
                    centerTitle: true,
                    title: Text(
                      const ['', 'Tambah Obat', 'Daily Check-in', 'My Profile']
                          [_navIndex],
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
            bottomNavigationBar: HomeBottomNavBar(
              currentIndex: _navIndex,
              onTap: (index) => setState(() => _navIndex = index),
            ),
            body: switch (_navIndex) {
              1 => AddMedicationPage(),
              2 => CheckInPage(userName: loaded.userName),
              3 => const ProfilePage(),
              _ => RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<HomeBloc>().add(HomeFetchSchedulesRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Greeting header ───────────────────────────────
                    Header(userName: loaded.userName),

                    const SizedBox(height: 16),

                    // ── Treatment Progress ────────────────────────────
                    TreatmentProgressCard(
                      treatmentDay: loaded.treatmentDay,
                      totalDays: loaded.totalDays,
                      progressPercent: loaded.progressPercent,
                    ),

                    const SizedBox(height: 24),

                    // ── Today's Schedule header ───────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Today's Schedule",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/schedule'),
                            child: const Text(
                              'View all',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Next Dose hero card ───────────────────────────
                    NextDoseCard(
                      time: loaded.nextDoseTime,
                      medicineName: loaded.nextDoseName,
                      isLoading: isCheckingIn,
                      onCheckIn: () {
                        context.read<HomeBloc>().add(
                          HomeCheckInDoseRequested(
                            item: loaded.schedules
                                .firstWhere((s) => s.status == 'pending'),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // ── Schedule list ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: loaded.schedules
                            // Skip first (shown in NextDoseCard) only if pending
                            .skip(1)
                            .map((item) => ScheduleListItem(item: item))
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Motivation banner ─────────────────────────────
                    const MotivationBanner(),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
            },
          );
        }

        // Error fallback
        if (state is HomeError) {
          return Scaffold(
            backgroundColor: AppColors.bodyColor,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 64,
                    color: AppColors.nautral,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.nautral,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.read<HomeBloc>().add(
                      HomeFetchSchedulesRequested(),
                    ),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

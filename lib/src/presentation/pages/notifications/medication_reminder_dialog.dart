import 'package:flutter/material.dart';
import 'package:lung_care_mobile/src/core/notifications/medication_reminder_payload.dart';
import 'package:lung_care_mobile/src/core/notifications/notification_preferences.dart';
import 'package:lung_care_mobile/src/core/notifications/notification_service.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/data/datasource/dose_check_in_data_source.dart';
import 'package:lung_care_mobile/src/data/datasource/schedule_remote_data_source.dart';

class MedicationReminderDialog extends StatelessWidget {
  const MedicationReminderDialog({super.key, required this.payload});

  final MedicationReminderPayload payload;

  static Future<void> show(
    BuildContext context,
    MedicationReminderPayload payload,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MedicationReminderDialog(payload: payload),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCFE3FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFF006DBA),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Waktunya Minum Obat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF2FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 17,
                        color: Color(0xFF006DBA),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        payload.displayTime,
                        style: const TextStyle(
                          color: Color(0xFF006DBA),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD9E8F4)),
                ),
                child: Column(
                  children: [
                    for (final entry in payload.items.asMap().entries) ...[
                      _MedicationRow(item: entry.value),
                      if (entry.key != payload.items.length - 1)
                        const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Color(0xFFDCE8F1),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _SwipeConfirm(payload: payload),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () async {
                    await NotificationService.instance.snoozeReminder(payload);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF006DBA),
                    backgroundColor: const Color(0xFFDCEEFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: FutureBuilder<NotificationPreferences>(
                    future: NotificationService.instance.loadPreferences(),
                    builder: (context, snapshot) {
                      final minutes = snapshot.data?.snoozeMinutes ?? 10;
                      return Text(
                        'Tunda $minutes Menit',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
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

class _MedicationRow extends StatelessWidget {
  const _MedicationRow({required this.item});

  final MedicationReminderItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFDDF4FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication_liquid_rounded,
              color: Color(0xFF0073BC),
              size: 21,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.dose,
                  style: const TextStyle(
                    color: AppColors.nautral,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

class _SwipeConfirm extends StatefulWidget {
  const _SwipeConfirm({required this.payload});

  final MedicationReminderPayload payload;

  @override
  State<_SwipeConfirm> createState() => _SwipeConfirmState();
}

class _SwipeConfirmState extends State<_SwipeConfirm> {
  final _doseDataSource = DoseCheckInDataSource();
  final _scheduleDataSource = ScheduleRemoteDataSource();
  double _dragX = 0;
  bool _saving = false;

  Future<void> _confirm() async {
    if (_saving) return;
    if (widget.payload.isTest) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tes popup berhasil dikonfirmasi.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      for (final item in widget.payload.items) {
        await _doseDataSource.checkInDose(
          scheduleId: item.scheduleId,
          timeIndex: item.timeIndex,
        );
        await _scheduleDataSource.decrementAmount(item.scheduleId);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dose check-in recorded.')));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _dragX = 0;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal mencatat dosis.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const thumbSize = 52.0;
        final maxDrag = constraints.maxWidth - thumbSize - 6;
        final clampedDrag = _dragX.clamp(0.0, maxDrag);
        return SizedBox(
          width: double.infinity,
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFCFE0FF),
              borderRadius: BorderRadius.circular(29),
              border: Border.all(color: const Color(0xFFB8CEF4)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  _saving ? 'Confirming...' : 'Swipe to Confirm',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF006DBA),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Positioned(
                  left: 3 + clampedDrag,
                  top: 3,
                  child: GestureDetector(
                    onHorizontalDragUpdate: _saving
                        ? null
                        : (details) {
                            setState(() {
                              _dragX = (_dragX + details.delta.dx).clamp(
                                0.0,
                                maxDrag,
                              );
                            });
                          },
                    onHorizontalDragEnd: _saving
                        ? null
                        : (_) {
                            if (_dragX > maxDrag * 0.72) {
                              _confirm();
                            } else {
                              setState(() => _dragX = 0);
                            }
                          },
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0073BC),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF0073BC,
                            ).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _saving
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.keyboard_double_arrow_right_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/presentation/bloc/home/home_bloc.dart';

class MedicationReminderModal extends StatelessWidget {
  const MedicationReminderModal({
    super.key,
    required this.items,
    this.onConfirm,
    this.onSnooze,
  });

  final List<MedicationScheduleItem> items;
  final VoidCallback? onConfirm;
  final VoidCallback? onSnooze;

  static Future<T?> show<T>(
    BuildContext context, {
    required List<MedicationScheduleItem> items,
    VoidCallback? onConfirm,
    VoidCallback? onSnooze,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (_) => MedicationReminderModal(
        items: items,
        onConfirm: onConfirm,
        onSnooze: onSnooze,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = items.first;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Decorative glow + icon ──────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.ternary,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC9E7F7), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ternary.withValues(alpha: 0.6),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.medication_liquid_outlined,
                size: 28,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 16),

            // ── Title ───────────────────────────────────────────
            const Text(
              'Waktunya Minum Obat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 8),

            // ── Time badge ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD9F2FF),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 17,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    firstItem.time,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Medication details card ─────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FAFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFC1C7D3).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Column(
                children: items.map((item) {
                  if (item != items.first) {
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          height: 1,
                          color: const Color(0xFFC1C7D3).withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        _MedItem(name: item.name, dosage: item.dosage),
                      ],
                    );
                  }
                  return _MedItem(name: item.name, dosage: item.dosage);
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // ── Swipe to confirm ────────────────────────────────
            _SwipeToConfirmSlider(
              onConfirm: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
            ),

            const SizedBox(height: 12),

            // ── Snooze button ────────────────────────────────────
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                onSnooze?.call();
              },
              child: const Text(
                'Tunda 10 Menit',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedItem extends StatelessWidget {
  const _MedItem({required this.name, required this.dosage});

  final String name;
  final String dosage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFD9F2FF),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.medication, size: 18, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dosage,
                style: const TextStyle(fontSize: 12, color: AppColors.nautral),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwipeToConfirmSlider extends StatefulWidget {
  const _SwipeToConfirmSlider({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  State<_SwipeToConfirmSlider> createState() => _SwipeToConfirmSliderState();
}

class _SwipeToConfirmSliderState extends State<_SwipeToConfirmSlider>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  bool _confirmed = false;

  late final AnimationController _resetController;
  late final Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _resetAnimation = Tween<double>(begin: 0, end: 0).animate(_resetController);
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _resetThumb() {
    _resetAnimation = Tween<double>(
      begin: _dragPosition,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOut,
    ));
    _resetController.forward(from: 0).then((_) {
      if (mounted) setState(() => _dragPosition = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    const trackHeight = 56.0;
    const thumbSize = 46.0;
    const thumbPadding = 5.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final maxDrag = trackWidth - thumbSize - thumbPadding * 2;

        return AnimatedBuilder(
          animation: _resetAnimation,
          builder: (context, _) {
            final pos = _confirmed ? maxDrag : _dragPosition;

            return Container(
              height: trackHeight,
              width: trackWidth,
              decoration: BoxDecoration(
                color: const Color(0xFFD4E3FF),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // "Swipe to Confirm" label
                  Center(
                    child: Opacity(
                      opacity: (1 - (pos / maxDrag)).clamp(0.0, 1.0),
                      child: const Text(
                        'Swipe to Confirm',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  // Draggable thumb
                  Positioned(
                    left: thumbPadding + pos,
                    top: thumbPadding,
                    child: GestureDetector(
                      onHorizontalDragUpdate: _confirmed
                          ? null
                          : (details) {
                              setState(() {
                                _dragPosition =
                                    (_dragPosition + details.delta.dx)
                                        .clamp(0.0, maxDrag);
                              });
                            },
                      onHorizontalDragEnd: _confirmed
                          ? null
                          : (_) {
                              if (_dragPosition >= maxDrag * 0.85) {
                                setState(() {
                                  _confirmed = true;
                                  _dragPosition = maxDrag;
                                });
                                widget.onConfirm();
                              } else {
                                _resetThumb();
                              }
                            },
                      child: Container(
                        width: thumbSize,
                        height: thumbSize,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
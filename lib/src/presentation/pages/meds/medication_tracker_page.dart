import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/l10n/app_localizations.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/data/datasource/dose_check_in_data_source.dart';
import 'package:lung_care_mobile/src/data/datasource/schedule_remote_data_source.dart';
import 'package:lung_care_mobile/src/presentation/pages/meds/medication_form.dart';

/// "Medication Tracker" page: manage the medication schedule list (CRUD).
class MedicationTrackerPage extends StatefulWidget {
  const MedicationTrackerPage({super.key});

  @override
  State<MedicationTrackerPage> createState() => _MedicationTrackerPageState();
}

class _MedicationTrackerPageState extends State<MedicationTrackerPage> {
  final _dataSource = ScheduleRemoteDataSource();
  final _doseCheckInDataSource = DoseCheckInDataSource();
  Set<String> _checkedInScheduleIds = {};

  Future<void> _openForm({Medication? initial}) async {
    final l = AppLocalizations.of(context)!;
    final result = await Navigator.of(context).push<Medication>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.bodyColor,
          appBar: AppBar(
            backgroundColor: AppColors.appbarColor,
            elevation: 1,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primary,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              initial == null ? l.addMedicine : l.editMedicine,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: MedicationForm(
            initial: initial,
            onSubmit: (med) async {
              Navigator.of(context).pop(med);
              return false;
            },
          ),
        ),
      ),
    );
    if (result == null) return;
    try {
      if (result.id == null) {
        await _dataSource.addSchedule(result);
      } else {
        await _dataSource.updateSchedule(result);
      }
    } catch (e) {
      _showError(AppLocalizations.of(context)!.saveFailed(e.toString()));
    }
  }

  Future<void> _confirmDelete(Medication med) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteDialog(l: AppLocalizations.of(context)!),
    );
    if (confirmed != true || med.id == null) return;
    try {
      await _dataSource.deleteSchedule(med.id!);
    } catch (_) {
      _showError(AppLocalizations.of(context)!.deleteFailed);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
        title: Text(
          l.medicationTracker,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Medication>>(
        stream: _dataSource.watchSchedules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final meds = snapshot.data ?? const [];
          return FutureBuilder<Set<String>>(
            future: _doseCheckInDataSource.getCheckedInScheduleIdsToday(),
            builder: (context, checkedInSnapshot) {
              final checkedIds = checkedInSnapshot.data ?? _checkedInScheduleIds;
              _checkedInScheduleIds = checkedIds;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
                children: [
                  Text(
                    l.scheduleManagement,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.scheduleManagementDesc,
                    style: const TextStyle(fontSize: 14, color: AppColors.nautral),
                  ),
                  const SizedBox(height: 18),
                  if (meds.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Text(
                          l.noScheduleYet,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.nautral),
                        ),
                      ),
                    ),
                  ...meds.map(
                    (med) => _MedCard(
                      med: med,
                      onEdit: () => _openForm(initial: med),
                      onDelete: () => _confirmDelete(med),
                      canDelete: !checkedIds.contains(med.id),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _MedCard extends StatelessWidget {
  const _MedCard({
    required this.med,
    required this.onEdit,
    required this.onDelete,
    this.canDelete = true,
  });

  final Medication med;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ternary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      med.dose,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              _RoundIcon(
                icon: Icons.edit_outlined,
                bg: AppColors.ternary,
                color: AppColors.primary,
                onTap: onEdit,
              ),
              if (canDelete) ...[
                const SizedBox(width: 8),
                _RoundIcon(
                  icon: Icons.delete_outline_rounded,
                  bg: const Color(0xFFFADCDC),
                  color: const Color(0xFFD32F2F),
                  onTap: onDelete,
                ),
              ],
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE8EEF6)),
          ),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 18,
                color: AppColors.nautral,
              ),
              const SizedBox(width: 6),
              Text(
                med.times.map((t) => t.format(context)).join(', '),
                style: const TextStyle(fontSize: 13, color: AppColors.black),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.sync_rounded,
                size: 18,
                color: AppColors.nautral,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  med.frequency,
                  style: const TextStyle(fontSize: 13, color: AppColors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.bg,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color bg;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFADCDC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFD32F2F),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.deleteScheduleTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.deleteScheduleDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.nautral),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: Color(0xFFD8E2F0)),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62121),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l.delete),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

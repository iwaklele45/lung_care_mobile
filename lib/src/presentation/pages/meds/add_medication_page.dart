import 'package:flutter/material.dart';
import 'package:lung_care_mobile/src/data/datasource/schedule_remote_data_source.dart';
import 'package:lung_care_mobile/src/presentation/pages/meds/medication_form.dart';

/// Body-only view rendered inside the Home shell's "Meds" tab.
class AddMedicationPage extends StatelessWidget {
  AddMedicationPage({super.key});

  final _dataSource = ScheduleRemoteDataSource();

  @override
  Widget build(BuildContext context) {
    return MedicationForm(
      onSubmit: (med) async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await _dataSource.addSchedule(med);
          messenger.showSnackBar(
            const SnackBar(content: Text('Obat tersimpan.')),
          );
          return true;
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text('Gagal menyimpan obat: $e')),
          );
          return false;
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lung_care_mobile/src/presentation/pages/meds/medication_form.dart';

void main() {
  group('Medication', () {
    group('fromMap', () {
      test('creates medication from map with times list', () {
        final map = {
          'name': 'Paracetamol',
          'amount': '30',
          'type': 'Tablet',
          'dose': '500mg',
          'frequency': '2x sehari',
          'capsuleColor': 'Putih',
          'times': [480, 720], // 08:00, 12:00
          'reminder': true,
        };

        final medication = Medication.fromMap('med-1', map);

        expect(medication.id, 'med-1');
        expect(medication.name, 'Paracetamol');
        expect(medication.amount, '30');
        expect(medication.type, 'Tablet');
        expect(medication.dose, '500mg');
        expect(medication.frequency, '2x sehari');
        expect(medication.capsuleColor, 'Putih');
        expect(medication.times, hasLength(2));
        expect(medication.times[0], const TimeOfDay(hour: 8, minute: 0));
        expect(medication.times[1], const TimeOfDay(hour: 12, minute: 0));
        expect(medication.reminder, true);
      });

      test('creates medication from map with timeHour and timeMinute', () {
        final map = {
          'name': 'Amoxicillin',
          'amount': '20',
          'type': 'Kapsul',
          'dose': '250mg',
          'frequency': '1x sehari',
          'capsuleColor': 'Merah',
          'timeHour': 7,
          'timeMinute': 30,
          'reminder': false,
        };

        final medication = Medication.fromMap('med-2', map);

        expect(medication.times, hasLength(1));
        expect(medication.times[0], const TimeOfDay(hour: 7, minute: 30));
        expect(medication.reminder, false);
      });

      test('uses default values for missing fields', () {
        final map = <String, dynamic>{
          'name': 'Test Med',
        };

        final medication = Medication.fromMap('med-3', map);

        expect(medication.amount, '');
        expect(medication.type, isNull);
        expect(medication.dose, '');
        expect(medication.frequency, '1x sehari');
        expect(medication.capsuleColor, 'Putih');
        expect(medication.reminder, true);
      });

      test('defaults times to midnight when no time info provided', () {
        final map = <String, dynamic>{
          'name': 'Test Med',
        };

        final medication = Medication.fromMap('med-4', map);

        expect(medication.times, hasLength(1));
        expect(medication.times[0], const TimeOfDay(hour: 0, minute: 0));
      });
    });

    group('toMap', () {
      test('converts medication to map correctly', () {
        final medication = Medication(
          id: 'med-1',
          name: 'Paracetamol',
          amount: '30',
          type: 'Tablet',
          dose: '500mg',
          frequency: '2x sehari',
          capsuleColor: 'Putih',
          times: [
            const TimeOfDay(hour: 8, minute: 0),
            const TimeOfDay(hour: 20, minute: 30),
          ],
          reminder: true,
        );

        final map = medication.toMap();

        expect(map['name'], 'Paracetamol');
        expect(map['amount'], '30');
        expect(map['type'], 'Tablet');
        expect(map['dose'], '500mg');
        expect(map['frequency'], '2x sehari');
        expect(map['capsuleColor'], 'Putih');
        expect(map['times'], [480, 1230]); // 8*60, 20*60+30
        expect(map['reminder'], true);
      });

      test('toMap does not include id', () {
        final medication = Medication(
          id: 'med-1',
          name: 'Test',
          amount: '10',
          type: 'Tablet',
          dose: '100mg',
          frequency: '1x sehari',
          capsuleColor: 'Putih',
          times: const [],
          reminder: false,
        );

        final map = medication.toMap();

        expect(map.containsKey('id'), false);
      });
    });

    group('roundtrip', () {
      test('fromMap(toMap()) preserves data', () {
        final original = Medication(
          id: 'med-rt',
          name: 'Ibuprofen',
          amount: '15',
          type: 'Kapsul',
          dose: '400mg',
          frequency: '3x sehari',
          capsuleColor: 'Biru',
          times: [
            const TimeOfDay(hour: 6, minute: 0),
            const TimeOfDay(hour: 14, minute: 0),
            const TimeOfDay(hour: 22, minute: 0),
          ],
          reminder: true,
        );

        final map = original.toMap();
        final restored = Medication.fromMap(original.id!, map);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.amount, original.amount);
        expect(restored.type, original.type);
        expect(restored.dose, original.dose);
        expect(restored.frequency, original.frequency);
        expect(restored.capsuleColor, original.capsuleColor);
        expect(restored.reminder, original.reminder);
        expect(restored.times.length, original.times.length);
        for (var i = 0; i < original.times.length; i++) {
          expect(restored.times[i].hour, original.times[i].hour);
          expect(restored.times[i].minute, original.times[i].minute);
        }
      });
    });
  });
}

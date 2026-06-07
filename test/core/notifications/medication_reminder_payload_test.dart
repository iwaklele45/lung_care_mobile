import 'package:flutter_test/flutter_test.dart';
import 'package:lung_care_mobile/src/core/notifications/medication_reminder_payload.dart';

void main() {
  group('MedicationReminderPayload', () {
    group('displayTime', () {
      test('formats AM time correctly', () {
        const payload = MedicationReminderPayload(
          timeMinutes: 480, // 08:00
          items: [],
        );

        expect(payload.displayTime, '8:00 AM');
      });

      test('formats PM time correctly', () {
        const payload = MedicationReminderPayload(
          timeMinutes: 1020, // 17:00
          items: [],
        );

        expect(payload.displayTime, '5:00 PM');
      });

      test('formats noon correctly', () {
        const payload = MedicationReminderPayload(
          timeMinutes: 720, // 12:00
          items: [],
        );

        expect(payload.displayTime, '12:00 PM');
      });

      test('formats midnight correctly', () {
        const payload = MedicationReminderPayload(
          timeMinutes: 0, // 00:00
          items: [],
        );

        expect(payload.displayTime, '12:00 AM');
      });

      test('formats time with minutes correctly', () {
        const payload = MedicationReminderPayload(
          timeMinutes: 525, // 08:45
          items: [],
        );

        expect(payload.displayTime, '8:45 AM');
      });

      test('formats afternoon time correctly', () {
        const payload = MedicationReminderPayload(
          timeMinutes: 810, // 13:30
          items: [],
        );

        expect(payload.displayTime, '1:30 PM');
      });
    });

    group('toJsonString', () {
      test('encodes payload to JSON string', () {
        const payload = MedicationReminderPayload(
          timeMinutes: 480,
          isSnooze: false,
          isTest: true,
          items: [
            MedicationReminderItem(
              scheduleId: 'sched-1',
              timeIndex: 0,
              name: 'Paracetamol',
              dose: '500mg',
            ),
          ],
        );

        final json = payload.toJsonString();
        expect(json, contains('"kind":"medication_reminder"'));
        expect(json, contains('"timeMinutes":480'));
        expect(json, contains('"isTest":true'));
        expect(json, contains('"scheduleId":"sched-1"'));
        expect(json, contains('"name":"Paracetamol"'));
      });
    });

    group('fromJsonString', () {
      test('decodes JSON string to payload', () {
        const original = MedicationReminderPayload(
          timeMinutes: 1020,
          isSnooze: true,
          isTest: false,
          items: [
            MedicationReminderItem(
              scheduleId: 'sched-1',
              timeIndex: 0,
              name: 'Amoxicillin',
              dose: '250mg',
            ),
            MedicationReminderItem(
              scheduleId: 'sched-1',
              timeIndex: 1,
              name: 'Amoxicillin',
              dose: '250mg',
            ),
          ],
        );

        final json = original.toJsonString();
        final restored = MedicationReminderPayload.fromJsonString(json);

        expect(restored.timeMinutes, 1020);
        expect(restored.isSnooze, true);
        expect(restored.isTest, false);
        expect(restored.items, hasLength(2));
        expect(restored.items[0].scheduleId, 'sched-1');
        expect(restored.items[0].name, 'Amoxicillin');
        expect(restored.items[1].timeIndex, 1);
      });

      test('handles empty items list', () {
        const json = '{"timeMinutes":480,"items":[]}';
        final payload = MedicationReminderPayload.fromJsonString(json);

        expect(payload.items, isEmpty);
      });

      test('handles missing items field', () {
        const json = '{"timeMinutes":480}';
        final payload = MedicationReminderPayload.fromJsonString(json);

        expect(payload.items, isEmpty);
        expect(payload.timeMinutes, 480);
      });

      test('handles missing optional fields with defaults', () {
        const json = '{"items":[]}';
        final payload = MedicationReminderPayload.fromJsonString(json);

        expect(payload.timeMinutes, 0);
        expect(payload.isSnooze, false);
        expect(payload.isTest, false);
      });

      test('filters out non-map items in items list', () {
        const json = '{"timeMinutes":480,"items":[1,"string",null]}';
        final payload = MedicationReminderPayload.fromJsonString(json);

        expect(payload.items, isEmpty);
      });
    });

    group('roundtrip', () {
      test('fromJsonString(toJsonString()) preserves data', () {
        const original = MedicationReminderPayload(
          timeMinutes: 840,
          isSnooze: true,
          isTest: false,
          items: [
            MedicationReminderItem(
              scheduleId: 'sched-1',
              timeIndex: 0,
              name: 'Paracetamol',
              dose: '500mg',
            ),
            MedicationReminderItem(
              scheduleId: 'sched-2',
              timeIndex: 1,
              name: 'Ibuprofen',
              dose: '400mg',
            ),
          ],
        );

        final json = original.toJsonString();
        final restored = MedicationReminderPayload.fromJsonString(json);

        expect(restored.timeMinutes, original.timeMinutes);
        expect(restored.isSnooze, original.isSnooze);
        expect(restored.isTest, original.isTest);
        expect(restored.items.length, original.items.length);
        for (var i = 0; i < original.items.length; i++) {
          expect(restored.items[i].scheduleId, original.items[i].scheduleId);
          expect(restored.items[i].timeIndex, original.items[i].timeIndex);
          expect(restored.items[i].name, original.items[i].name);
          expect(restored.items[i].dose, original.items[i].dose);
        }
      });
    });
  });

  group('MedicationReminderItem', () {
    group('fromMap', () {
      test('creates item from map', () {
        final map = {
          'scheduleId': 'sched-1',
          'timeIndex': 0,
          'name': 'Paracetamol',
          'dose': '500mg',
        };

        final item = MedicationReminderItem.fromMap(map);

        expect(item.scheduleId, 'sched-1');
        expect(item.timeIndex, 0);
        expect(item.name, 'Paracetamol');
        expect(item.dose, '500mg');
      });

      test('uses default values for missing fields', () {
        final map = <String, dynamic>{};

        final item = MedicationReminderItem.fromMap(map);

        expect(item.scheduleId, '');
        expect(item.timeIndex, 0);
        expect(item.name, '');
        expect(item.dose, '');
      });
    });

    group('toMap', () {
      test('converts item to map', () {
        const item = MedicationReminderItem(
          scheduleId: 'sched-1',
          timeIndex: 0,
          name: 'Paracetamol',
          dose: '500mg',
        );

        final map = item.toMap();

        expect(map['scheduleId'], 'sched-1');
        expect(map['timeIndex'], 0);
        expect(map['name'], 'Paracetamol');
        expect(map['dose'], '500mg');
      });
    });

    group('roundtrip', () {
      test('fromMap(toMap()) preserves data', () {
        const original = MedicationReminderItem(
          scheduleId: 'sched-1',
          timeIndex: 0,
          name: 'Paracetamol',
          dose: '500mg',
        );

        final map = original.toMap();
        final restored = MedicationReminderItem.fromMap(map);

        expect(restored.scheduleId, original.scheduleId);
        expect(restored.timeIndex, original.timeIndex);
        expect(restored.name, original.name);
        expect(restored.dose, original.dose);
      });
    });
  });
}

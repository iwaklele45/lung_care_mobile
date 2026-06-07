import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lung_care_mobile/src/core/notifications/notification_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
  });

  group('NotificationPreferences', () {
    group('defaults', () {
      test('returns default preferences', () {
        final defaults = NotificationPreferences.defaults();

        expect(defaults.medicationReminder, true);
        expect(defaults.checkInReminder, true);
        expect(defaults.generalNotification, true);
        expect(defaults.sound, true);
        expect(defaults.vibration, true);
        expect(defaults.snoozeMinutes, 10);
      });
    });

    group('fromPrefs', () {
      test('loads preferences from SharedPreferences', () {
        when(() => mockPrefs.getBool('notif_medication')).thenReturn(false);
        when(() => mockPrefs.getBool('notif_checkin')).thenReturn(false);
        when(() => mockPrefs.getBool('notif_general')).thenReturn(false);
        when(() => mockPrefs.getBool('notif_sound')).thenReturn(false);
        when(() => mockPrefs.getBool('notif_vibration')).thenReturn(false);
        when(() => mockPrefs.getInt('notif_snooze_minutes')).thenReturn(5);

        final prefs = NotificationPreferences.fromPrefs(mockPrefs);

        expect(prefs.medicationReminder, false);
        expect(prefs.checkInReminder, false);
        expect(prefs.generalNotification, false);
        expect(prefs.sound, false);
        expect(prefs.vibration, false);
        expect(prefs.snoozeMinutes, 5);
      });

      test('uses defaults when SharedPreferences has no values', () {
        when(() => mockPrefs.getBool(any())).thenReturn(null);
        when(() => mockPrefs.getInt(any())).thenReturn(null);

        final prefs = NotificationPreferences.fromPrefs(mockPrefs);

        expect(prefs.medicationReminder, true);
        expect(prefs.checkInReminder, true);
        expect(prefs.generalNotification, true);
        expect(prefs.sound, true);
        expect(prefs.vibration, true);
        expect(prefs.snoozeMinutes, 10);
      });

      test('mixes custom and default values', () {
        when(() => mockPrefs.getBool('notif_medication')).thenReturn(false);
        when(() => mockPrefs.getBool('notif_checkin')).thenReturn(null);
        when(() => mockPrefs.getBool('notif_general')).thenReturn(true);
        when(() => mockPrefs.getBool('notif_sound')).thenReturn(null);
        when(() => mockPrefs.getBool('notif_vibration')).thenReturn(false);
        when(() => mockPrefs.getInt('notif_snooze_minutes')).thenReturn(null);

        final prefs = NotificationPreferences.fromPrefs(mockPrefs);

        expect(prefs.medicationReminder, false); // custom
        expect(prefs.checkInReminder, true); // default
        expect(prefs.generalNotification, true); // custom
        expect(prefs.sound, true); // default
        expect(prefs.vibration, false); // custom
        expect(prefs.snoozeMinutes, 10); // default
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        const original = NotificationPreferences(
          medicationReminder: true,
          checkInReminder: false,
          generalNotification: true,
          sound: false,
          vibration: true,
          snoozeMinutes: 15,
        );

        final copy = original.copyWith();

        expect(copy.medicationReminder, original.medicationReminder);
        expect(copy.checkInReminder, original.checkInReminder);
        expect(copy.generalNotification, original.generalNotification);
        expect(copy.sound, original.sound);
        expect(copy.vibration, original.vibration);
        expect(copy.snoozeMinutes, original.snoozeMinutes);
      });

      test('copies with selected changes', () {
        const original = NotificationPreferences(
          medicationReminder: true,
          checkInReminder: true,
          generalNotification: true,
          sound: true,
          vibration: true,
          snoozeMinutes: 10,
        );

        final copy = original.copyWith(
          medicationReminder: false,
          snoozeMinutes: 20,
        );

        expect(copy.medicationReminder, false);
        expect(copy.checkInReminder, true); // unchanged
        expect(copy.generalNotification, true); // unchanged
        expect(copy.sound, true); // unchanged
        expect(copy.vibration, true); // unchanged
        expect(copy.snoozeMinutes, 20);
      });

      test('copies with all changes', () {
        const original = NotificationPreferences(
          medicationReminder: true,
          checkInReminder: true,
          generalNotification: true,
          sound: true,
          vibration: true,
          snoozeMinutes: 10,
        );

        final copy = original.copyWith(
          medicationReminder: false,
          checkInReminder: false,
          generalNotification: false,
          sound: false,
          vibration: false,
          snoozeMinutes: 0,
        );

        expect(copy.medicationReminder, false);
        expect(copy.checkInReminder, false);
        expect(copy.generalNotification, false);
        expect(copy.sound, false);
        expect(copy.vibration, false);
        expect(copy.snoozeMinutes, 0);
      });
    });

    group('toMap', () {
      test('converts preferences to map', () {
        const prefs = NotificationPreferences(
          medicationReminder: true,
          checkInReminder: false,
          generalNotification: true,
          sound: false,
          vibration: true,
          snoozeMinutes: 15,
        );

        final map = prefs.toMap();

        expect(map['medicationReminder'], true);
        expect(map['checkInReminder'], false);
        expect(map['generalNotification'], true);
        expect(map['sound'], false);
        expect(map['vibration'], true);
        expect(map['snoozeMinutes'], 15);
        expect(map.containsKey('updatedAt'), true);
      });
    });

    group('constants', () {
      test('has correct keys', () {
        expect(NotificationPreferences.medicationKey, 'notif_medication');
        expect(NotificationPreferences.checkInKey, 'notif_checkin');
        expect(NotificationPreferences.generalKey, 'notif_general');
        expect(NotificationPreferences.soundKey, 'notif_sound');
        expect(NotificationPreferences.vibrationKey, 'notif_vibration');
        expect(NotificationPreferences.snoozeKey, 'notif_snooze_minutes');
      });
    });
  });
}

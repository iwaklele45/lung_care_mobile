import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  const NotificationPreferences({
    required this.medicationReminder,
    required this.checkInReminder,
    required this.generalNotification,
    required this.sound,
    required this.vibration,
    required this.snoozeMinutes,
  });

  static const medicationKey = 'notif_medication';
  static const checkInKey = 'notif_checkin';
  static const generalKey = 'notif_general';
  static const soundKey = 'notif_sound';
  static const vibrationKey = 'notif_vibration';
  static const snoozeKey = 'notif_snooze_minutes';

  final bool medicationReminder;
  final bool checkInReminder;
  final bool generalNotification;
  final bool sound;
  final bool vibration;
  final int snoozeMinutes;

  factory NotificationPreferences.defaults() => const NotificationPreferences(
    medicationReminder: true,
    checkInReminder: true,
    generalNotification: true,
    sound: true,
    vibration: true,
    snoozeMinutes: 10,
  );

  factory NotificationPreferences.fromPrefs(SharedPreferences prefs) {
    final defaults = NotificationPreferences.defaults();
    return NotificationPreferences(
      medicationReminder:
          prefs.getBool(medicationKey) ?? defaults.medicationReminder,
      checkInReminder: prefs.getBool(checkInKey) ?? defaults.checkInReminder,
      generalNotification:
          prefs.getBool(generalKey) ?? defaults.generalNotification,
      sound: prefs.getBool(soundKey) ?? defaults.sound,
      vibration: prefs.getBool(vibrationKey) ?? defaults.vibration,
      snoozeMinutes: prefs.getInt(snoozeKey) ?? defaults.snoozeMinutes,
    );
  }

  NotificationPreferences copyWith({
    bool? medicationReminder,
    bool? checkInReminder,
    bool? generalNotification,
    bool? sound,
    bool? vibration,
    int? snoozeMinutes,
  }) {
    return NotificationPreferences(
      medicationReminder: medicationReminder ?? this.medicationReminder,
      checkInReminder: checkInReminder ?? this.checkInReminder,
      generalNotification: generalNotification ?? this.generalNotification,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
    );
  }

  Map<String, dynamic> toMap() => {
    'medicationReminder': medicationReminder,
    'checkInReminder': checkInReminder,
    'generalNotification': generalNotification,
    'sound': sound,
    'vibration': vibration,
    'snoozeMinutes': snoozeMinutes,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

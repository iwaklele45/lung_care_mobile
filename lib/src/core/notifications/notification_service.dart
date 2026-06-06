import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:lung_care_mobile/src/core/notifications/medication_reminder_payload.dart';
import 'package:lung_care_mobile/src/core/notifications/notification_preferences.dart';
import 'package:lung_care_mobile/src/presentation/pages/meds/medication_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

typedef MedicationReminderSelected =
    void Function(MedicationReminderPayload payload);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _channelName = 'Medication Reminders';
  static const _channelDescription = 'Daily medication reminder alerts';

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MedicationReminderSelected? _onMedicationReminderSelected;
  bool _initialized = false;

  Future<void> initialize({
    MedicationReminderSelected? onMedicationReminderSelected,
  }) async {
    _onMedicationReminderSelected = onMedicationReminderSelected;
    if (_initialized) return;

    await _configureTimezone();
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
    await _ensureAndroidChannel(NotificationPreferences.defaults());
    await _handleLaunchNotification();
    _listenForFcmMessages();
    _initialized = true;
  }

  Future<NotificationPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPreferences.fromPrefs(prefs);
  }

  Future<void> savePreferences(NotificationPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      NotificationPreferences.medicationKey,
      preferences.medicationReminder,
    );
    await prefs.setBool(
      NotificationPreferences.checkInKey,
      preferences.checkInReminder,
    );
    await prefs.setBool(
      NotificationPreferences.generalKey,
      preferences.generalNotification,
    );
    await prefs.setBool(NotificationPreferences.soundKey, preferences.sound);
    await prefs.setBool(
      NotificationPreferences.vibrationKey,
      preferences.vibration,
    );
    await prefs.setInt(
      NotificationPreferences.snoozeKey,
      preferences.snoozeMinutes,
    );

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'notificationSettings': preferences.toMap(),
      }, SetOptions(merge: true));
    }

    if (preferences.generalNotification || preferences.medicationReminder) {
      await requestNotificationPermissions();
    }

    if (preferences.generalNotification) {
      await registerCurrentDeviceToken();
    } else {
      await unregisterCurrentDeviceToken();
    }

    if (!preferences.medicationReminder) {
      await cancelMedicationReminders();
    }
  }

  Future<bool> requestNotificationPermissions() async {
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _local
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final macos = _local
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();

    final fcmSettings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final androidGranted =
        await android?.requestNotificationsPermission() ?? true;
    final iosGranted =
        await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
        true;
    final macosGranted =
        await macos?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    return fcmSettings.authorizationStatus == AuthorizationStatus.authorized ||
        fcmSettings.authorizationStatus == AuthorizationStatus.provisional ||
        androidGranted ||
        iosGranted ||
        macosGranted;
  }

  Future<bool?> canScheduleExactNotifications() {
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return android?.canScheduleExactNotifications() ?? Future.value(null);
  }

  Future<bool?> requestExactAlarmPermission() {
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return android?.requestExactAlarmsPermission() ?? Future.value(null);
  }

  Future<bool?> requestFullScreenIntentPermission() {
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return android?.requestFullScreenIntentPermission() ?? Future.value(null);
  }

  Future<void> registerCurrentDeviceToken() async {
    final user = _auth.currentUser;
    if (user == null || kIsWeb) return;
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return;
    await _upsertDeviceToken(user.uid, token);
  }

  Future<void> unregisterCurrentDeviceToken() async {
    final user = _auth.currentUser;
    if (user == null || kIsWeb) return;
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return;
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .where('fcmToken', isEqualTo: token)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> syncMedicationReminders(List<Medication> medications) async {
    final preferences = await loadPreferences();
    await cancelMedicationReminders();
    if (!preferences.medicationReminder) return;

    final groups = <int, List<MedicationReminderItem>>{};
    for (final medication in medications) {
      if (!medication.reminder || medication.id == null) continue;
      for (final entry in medication.times.asMap().entries) {
        final time = entry.value;
        final minuteOfDay = time.hour * 60 + time.minute;
        groups.putIfAbsent(minuteOfDay, () => []);
        groups[minuteOfDay]!.add(
          MedicationReminderItem(
            scheduleId: medication.id!,
            timeIndex: entry.key,
            name: medication.name,
            dose: medication.dose,
          ),
        );
      }
    }
    if (groups.isEmpty) return;

    await requestNotificationPermissions();
    final scheduleMode = await _androidScheduleMode(preferAlarmClock: true);
    for (final entry in groups.entries) {
      final payload = MedicationReminderPayload(
        timeMinutes: entry.key,
        items: entry.value,
      );
      await _local.zonedSchedule(
        id: _notificationId('medication_${entry.key}'),
        title: 'Waktunya Minum Obat',
        body: _bodyFor(payload),
        scheduledDate: _nextInstanceOfMinute(entry.key),
        notificationDetails: await _details(
          preferences,
          fullScreenIntent: true,
        ),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload.toJsonString(),
      );
    }
  }

  Future<void> cancelMedicationReminders() async {
    try {
      await _local.cancelAllPendingNotifications();
    } catch (_) {
      await _local.cancelAll();
    }
  }

  Future<void> showTestNotification() async {
    final preferences = await loadPreferences();
    await requestNotificationPermissions();
    await _local.show(
      id: _notificationId('test_notification'),
      title: 'LungCare+',
      body: 'Pengingat notifikasi aktif.',
      notificationDetails: await _details(preferences),
    );
  }

  Future<void> scheduleFullScreenTestReminder() async {
    final preferences = await loadPreferences();
    await requestNotificationPermissions();
    await requestExactAlarmPermission();
    final now = DateTime.now();
    final payload = MedicationReminderPayload(
      timeMinutes: now.hour * 60 + now.minute,
      isTest: true,
      items: const [
        MedicationReminderItem(
          scheduleId: '__test__',
          timeIndex: 0,
          name: 'Tes Pengingat',
          dose: 'Full-screen popup',
        ),
      ],
    );
    await _local.zonedSchedule(
      id: _notificationId('fullscreen_test_${now.millisecondsSinceEpoch}'),
      title: 'Waktunya Minum Obat',
      body: 'Tes popup layar penuh akan membuka LungCare+.',
      scheduledDate: tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(seconds: 8)),
      notificationDetails: await _details(preferences, fullScreenIntent: true),
      androidScheduleMode: await _androidScheduleMode(preferAlarmClock: true),
      payload: payload.toJsonString(),
    );
  }

  Future<void> snoozeReminder(MedicationReminderPayload payload) async {
    final preferences = await loadPreferences();
    final snoozePayload = MedicationReminderPayload(
      timeMinutes: payload.timeMinutes,
      items: payload.items,
      isSnooze: true,
    );
    await _local.zonedSchedule(
      id: _notificationId('snooze_${DateTime.now().millisecondsSinceEpoch}'),
      title: 'Waktunya Minum Obat',
      body: _bodyFor(snoozePayload),
      scheduledDate: tz.TZDateTime.now(
        tz.local,
      ).add(Duration(minutes: preferences.snoozeMinutes)),
      notificationDetails: await _details(preferences, fullScreenIntent: true),
      androidScheduleMode: await _androidScheduleMode(preferAlarmClock: true),
      payload: snoozePayload.toJsonString(),
    );
  }

  Future<void> _configureTimezone() async {
    tz_data.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }
  }

  Future<void> _ensureAndroidChannel(
    NotificationPreferences preferences, {
    bool fullScreenIntent = false,
  }) async {
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        _channelIdFor(preferences, fullScreenIntent: fullScreenIntent),
        fullScreenIntent ? 'Medication Alarm' : _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: preferences.sound,
        enableVibration: preferences.vibration,
        vibrationPattern: preferences.vibration
            ? Int64List.fromList(const [0, 700, 250, 700, 250, 700])
            : null,
        audioAttributesUsage: fullScreenIntent
            ? AudioAttributesUsage.alarm
            : AudioAttributesUsage.notification,
      ),
    );
  }

  void _listenForFcmMessages() {
    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;
      if (notification == null) return;
      final preferences = await loadPreferences();
      if (!preferences.generalNotification) return;
      await _local.show(
        id: _notificationId(
          message.messageId ?? DateTime.now().toIso8601String(),
        ),
        title: notification.title,
        body: notification.body,
        notificationDetails: await _details(preferences),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((_) {});
    _messaging.onTokenRefresh.listen((token) async {
      final user = _auth.currentUser;
      if (user != null) await _upsertDeviceToken(user.uid, token);
    });
  }

  Future<void> _handleLaunchNotification() async {
    final details = await _local.getNotificationAppLaunchDetails();
    final response = details?.notificationResponse;
    if (details?.didNotificationLaunchApp != true || response == null) return;
    _handleNotificationResponse(response);
  }

  Future<void> _upsertDeviceToken(String uid, String token) async {
    final devices = _firestore
        .collection('users')
        .doc(uid)
        .collection('devices');
    final snapshot = await devices
        .where('fcmToken', isEqualTo: token)
        .limit(1)
        .get();
    final data = {
      'fcmToken': token,
      'platform': defaultTargetPlatform.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (snapshot.docs.isEmpty) {
      await devices.add(data);
    } else {
      await snapshot.docs.first.reference.set(data, SetOptions(merge: true));
    }
  }

  Future<NotificationDetails> _details(
    NotificationPreferences preferences, {
    bool fullScreenIntent = false,
  }) async {
    await _ensureAndroidChannel(
      preferences,
      fullScreenIntent: fullScreenIntent,
    );
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelIdFor(preferences, fullScreenIntent: fullScreenIntent),
        fullScreenIntent ? 'Medication Alarm' : _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: fullScreenIntent ? Priority.max : Priority.high,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        fullScreenIntent: fullScreenIntent,
        playSound: preferences.sound,
        enableVibration: preferences.vibration,
        vibrationPattern: preferences.vibration
            ? Int64List.fromList(const [0, 700, 250, 700, 250, 700])
            : null,
        audioAttributesUsage: fullScreenIntent
            ? AudioAttributesUsage.alarm
            : AudioAttributesUsage.notification,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: preferences.sound,
        presentBadge: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: preferences.sound,
        presentBadge: true,
      ),
    );
  }

  String _channelIdFor(
    NotificationPreferences preferences, {
    required bool fullScreenIntent,
  }) {
    final kind = fullScreenIntent ? 'alarm' : 'general';
    final sound = preferences.sound ? 'sound' : 'silent';
    final vibration = preferences.vibration ? 'vibrate' : 'still';
    return 'lungcare_${kind}_${sound}_${vibration}_v4';
  }

  Future<AndroidScheduleMode> _androidScheduleMode({
    bool preferAlarmClock = false,
  }) async {
    final canScheduleExact = await canScheduleExactNotifications();
    if (canScheduleExact == false) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
    if (preferAlarmClock) {
      return AndroidScheduleMode.alarmClock;
    }
    return AndroidScheduleMode.exactAllowWhileIdle;
  }

  tz.TZDateTime _nextInstanceOfMinute(int minuteOfDay) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minuteOfDay ~/ 60,
      minuteOfDay % 60,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  String _bodyFor(MedicationReminderPayload payload) {
    final names = payload.items.map((item) => item.name).join(', ');
    return '${payload.displayTime} - $names';
  }

  int _notificationId(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final reminder = MedicationReminderPayload.fromJsonString(payload);
      _onMedicationReminderSelected?.call(reminder);
    } catch (_) {}
  }
}

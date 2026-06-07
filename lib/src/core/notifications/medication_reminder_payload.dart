import 'dart:convert';

class MedicationReminderPayload {
  const MedicationReminderPayload({
    required this.timeMinutes,
    required this.items,
    this.isSnooze = false,
    this.isTest = false,
  });

  final int timeMinutes;
  final List<MedicationReminderItem> items;
  final bool isSnooze;
  final bool isTest;

  String get displayTime {
    final hour = timeMinutes ~/ 60;
    final minute = timeMinutes % 60;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
  }

  String toJsonString() => jsonEncode({
    'kind': 'medication_reminder',
    'timeMinutes': timeMinutes,
    'isSnooze': isSnooze,
    'isTest': isTest,
    'items': items.map((item) => item.toMap()).toList(),
  });

  factory MedicationReminderPayload.fromJsonString(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return MedicationReminderPayload(
      timeMinutes: map['timeMinutes'] as int? ?? 0,
      isSnooze: map['isSnooze'] as bool? ?? false,
      isTest: map['isTest'] as bool? ?? false,
      items: ((map['items'] as List?) ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                MedicationReminderItem.fromMap(item.cast<String, dynamic>()),
          )
          .toList(),
    );
  }
}

class MedicationReminderItem {
  const MedicationReminderItem({
    required this.scheduleId,
    required this.timeIndex,
    required this.name,
    required this.dose,
  });

  final String scheduleId;
  final int timeIndex;
  final String name;
  final String dose;

  Map<String, dynamic> toMap() => {
    'scheduleId': scheduleId,
    'timeIndex': timeIndex,
    'name': name,
    'dose': dose,
  };

  factory MedicationReminderItem.fromMap(Map<String, dynamic> map) {
    return MedicationReminderItem(
      scheduleId: map['scheduleId'] as String? ?? '',
      timeIndex: map['timeIndex'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      dose: map['dose'] as String? ?? '',
    );
  }
}

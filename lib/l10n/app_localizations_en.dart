// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LungCare+';

  @override
  String greeting(String name) {
    return 'Hello, $name';
  }

  @override
  String howAreYouFeeling(String time) {
    return 'How are you feeling at $time today?';
  }

  @override
  String goodMorning(String name) {
    return 'Good Morning, $name';
  }

  @override
  String get profileTitle => 'My Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get settings => 'Settings';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get logout => 'Logout';

  @override
  String get logoutSuccess => 'Logged out successfully.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get notifications => 'NOTIFICATIONS';

  @override
  String get medicationReminder => 'Medication Reminder';

  @override
  String get medicationReminderDesc => 'Medication schedule notifications';

  @override
  String get checkInReminder => 'Check-in Reminder';

  @override
  String get checkInReminderDesc => 'Daily check-in notifications';

  @override
  String get generalNotification => 'General Notification';

  @override
  String get generalNotificationDesc => 'App info & updates';

  @override
  String get language => 'LANGUAGE';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get english => 'English';

  @override
  String get englishBeta => '(Beta)';

  @override
  String get soundReminder => 'Reminder Sound';

  @override
  String get soundReminderDesc => 'Play sound when reminder appears.';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationDesc => 'Vibrate device when reminder appears.';

  @override
  String get snoozeDuration => 'Snooze Duration';

  @override
  String get snoozeDurationDesc =>
      'Extra time after pressing the snooze button.';

  @override
  String get exactAlarm => 'Exact Alarm';

  @override
  String get exactAlarmActiveDesc =>
      'Active for more precise medication schedules.';

  @override
  String get exactAlarmInactiveDesc =>
      'Inactive. Reminders may be slightly delayed.';

  @override
  String get activate => 'Activate';

  @override
  String get fullScreenPopup => 'Full Screen Popup';

  @override
  String get fullScreenPopupDesc =>
      'Open app automatically when medication reminder sounds.';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get testNotificationDesc => 'Send a test notification to this device.';

  @override
  String get send => 'Send';

  @override
  String get testFullScreenPopup => 'Test Full Screen Popup';

  @override
  String get testFullScreenPopupDesc =>
      'Schedule a popup in 8 seconds. Lock the screen after pressing.';

  @override
  String get test => 'Test';

  @override
  String get saveNotifFailed => 'Failed to save notification settings.';

  @override
  String get exactAlarmGranted => 'Exact alarm permission granted.';

  @override
  String get exactAlarmDenied => 'Exact alarm permission not yet active.';

  @override
  String get fullScreenGranted => 'Full screen popup permission granted.';

  @override
  String get fullScreenDenied =>
      'Enable full screen popup from system settings.';

  @override
  String get testNotifSent => 'Test notification sent.';

  @override
  String get testFullScreenScheduled =>
      'Popup test scheduled in 8 seconds. Lock the screen.';

  @override
  String get helpTitle => 'Help & Support';

  @override
  String get helpHeader => 'How can we help?';

  @override
  String get helpSubheader =>
      'Contact our team or find answers\nin frequently asked questions.';

  @override
  String get contactUs => 'CONTACT US';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get chatDirectly => 'Chat directly';

  @override
  String get email => 'Email';

  @override
  String get sendMessage => 'Send message';

  @override
  String get faq => 'FREQUENTLY ASKED QUESTIONS (FAQ)';

  @override
  String get aboutApp => 'ABOUT THE APP';

  @override
  String get appVersion => 'App Version';

  @override
  String get developer => 'Developer';

  @override
  String get developerName => 'LungCare+ Team';

  @override
  String get serviceArea => 'Service Area';

  @override
  String get serviceAreaValue => 'Surabaya';

  @override
  String get cannotOpenWhatsApp => 'Cannot open WhatsApp.';

  @override
  String get cannotOpenEmail => 'Cannot open email.';

  @override
  String get faq1Question => 'How do I add a medication schedule?';

  @override
  String get faq1Answer =>
      'Open the \"Medication Schedule\" page from the main menu, then tap the + button at the bottom right. Fill in the medicine name, dosage, and time, then tap \"Save\".';

  @override
  String get faq2Question => 'Is my data safe?';

  @override
  String get faq2Answer =>
      'Yes. Your data is stored encrypted on Firebase servers and can only be accessed by your own account. We do not share personal data with third parties.';

  @override
  String get faq3Question => 'How do I edit my profile?';

  @override
  String get faq3Answer =>
      'Open the \"Profile\" tab then tap \"Edit Profile\". You can change your name, WhatsApp number, and address.';

  @override
  String get faq4Question => 'Notifications aren\'t showing, what should I do?';

  @override
  String get faq4Answer =>
      'Make sure notification permissions for LungCare+ are enabled in your phone settings. If the problem persists, try logging out and logging back in.';

  @override
  String get faq5Question => 'Is this service available outside Surabaya?';

  @override
  String get faq5Answer =>
      'Currently LungCare+ is only available for the Surabaya area. We plan to expand coverage in the future.';

  @override
  String get symptomsCheck => 'SYMPTOMS CHECK';

  @override
  String get tapToRate => 'Tap to rate intensity';

  @override
  String get additionalNotes => 'ADDITIONAL NOTES';

  @override
  String get otherSymptoms => 'Other Symptoms';

  @override
  String get completeCheckIn => 'Complete Check-in';

  @override
  String get alreadyCheckedIn => 'Already Checked In Today';

  @override
  String get selectSymptomFirst => 'Select at least one symptom first.';

  @override
  String get checkInSaved => 'Check-in saved.';

  @override
  String checkInFailed(String error) {
    return 'Failed to save check-in: $error';
  }

  @override
  String get currentStreak => 'Current Streak';

  @override
  String dayCount(int count) {
    return '$count Days';
  }

  @override
  String get dataSecureNote =>
      'Your data is stored securely and only shared with your provider.';

  @override
  String get nausea => 'Nausea';

  @override
  String get dizziness => 'Dizziness';

  @override
  String get fatigue => 'Fatigue';

  @override
  String get fever => 'Fever';

  @override
  String get none => 'None';

  @override
  String get mild => 'Mild';

  @override
  String get moderate => 'Moderate';

  @override
  String get severe => 'Severe';

  @override
  String get verySevere => 'Very Severe';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get medicationHistory => 'Medication History';

  @override
  String get tbEducationChatbot => 'TB Education Chatbot';

  @override
  String get healthFacilities => 'Health Facilities';

  @override
  String get todaysSchedule => 'Today\'s Schedule';

  @override
  String get viewAll => 'View all';

  @override
  String get doseCheckInSuccess => 'Dose check-in recorded! 🎉';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get addMedicine => 'Add Medicine';

  @override
  String get dailyCheckIn => 'Daily Check-in';

  @override
  String get myProfile => 'My Profile';

  @override
  String get fullName => 'Full Name';

  @override
  String get whatsappNumber => 'WhatsApp Number';

  @override
  String get address => 'Address';

  @override
  String get save => 'Save';

  @override
  String get requiredField => 'Required.';

  @override
  String get saveProfileFailed => 'Failed to save profile.';

  @override
  String get dataNotFound => 'Data not found.';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String helloName(String name) {
    return 'Hello, $name!';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navMeds => 'Meds';

  @override
  String get navCheckIn => 'Check-in';

  @override
  String get navProfile => 'Profile';

  @override
  String get medicationSchedule => 'Medication Schedule';

  @override
  String get medicationScheduleTitle => 'Medication Schedule';

  @override
  String get setYourReminder => 'Set Your Reminders';

  @override
  String get noRemindersYet => 'No medication reminders yet.';

  @override
  String get intensivePhase => 'Intensive Phase (Month 1-2)';

  @override
  String get intensivePhaseDesc =>
      'The initial treatment phase that requires high discipline.';

  @override
  String get morningAfterBreakfast => 'Morning (After Breakfast)';

  @override
  String get recommendedTime => 'Recommended at 07:00 - 09:00';

  @override
  String get confirmStock => 'Confirm Medicine Stock';

  @override
  String get remainingStock => 'Remaining Stock This Month';

  @override
  String pillCount(int remaining, int total) {
    return '$remaining / $total Pills';
  }

  @override
  String daysLeftSuffix(int days) {
    return 'Enough for $days days ahead';
  }

  @override
  String get medicationTracker => 'Medication Tracker';

  @override
  String get scheduleManagement => 'Medication Schedule Management';

  @override
  String get scheduleManagementDesc =>
      'Manage your medicine list and intake schedule.';

  @override
  String get noScheduleYet => 'No medication schedule yet.\nTap + to add one.';

  @override
  String get editMedicine => 'Edit Medicine';

  @override
  String saveFailed(String error) {
    return 'Failed to save schedule: $error';
  }

  @override
  String get deleteFailed => 'Failed to delete schedule.';

  @override
  String get deleteScheduleTitle => 'Delete this schedule?';

  @override
  String get deleteScheduleDesc =>
      'This medication schedule will be permanently removed from your reminders.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get medicineName => 'Medicine Name';

  @override
  String get medicineNameHint => 'e.g. Paracetamol';

  @override
  String get medicineAmount => 'Amount';

  @override
  String get medicineAmountHint => 'e.g. 10';

  @override
  String get medicineType => 'Medicine Type';

  @override
  String get medicineTypeHint => 'Select type';

  @override
  String get dosage => 'Dosage';

  @override
  String get dosageHint => 'e.g. 500mg';

  @override
  String get frequency => 'Frequency';

  @override
  String get medicineColor => 'Medicine Color';

  @override
  String get intakeTime => 'Intake Time';

  @override
  String intakeTimeMultiple(int count) {
    return 'Intake Time (${count}x)';
  }

  @override
  String timeLabel(int index) {
    return 'Time $index';
  }

  @override
  String get enableReminder => 'Enable Reminder';

  @override
  String get saveMedicine => 'Save Medicine';

  @override
  String get fillTypeAndTime => 'Please fill medicine type and intake time.';

  @override
  String get tablet => 'Tablet';

  @override
  String get capsule => 'Capsule';

  @override
  String get syrup => 'Syrup';

  @override
  String get injection => 'Injection';

  @override
  String get onceDaily => 'Once daily';

  @override
  String get twiceDaily => 'Twice daily';

  @override
  String get thriceDaily => 'Three times daily';

  @override
  String get white => 'White';

  @override
  String get red => 'Red';

  @override
  String get blue => 'Blue';

  @override
  String get yellow => 'Yellow';

  @override
  String get green => 'Green';

  @override
  String get nextDose => 'NEXT DOSE';

  @override
  String get checkInDose => 'Check-in Dose';

  @override
  String get checkingIn => 'Checking in...';

  @override
  String get notYetTime => 'Not yet time';

  @override
  String get treatmentProgress => 'Treatment Progress';

  @override
  String percentComplete(int percent) {
    return '$percent% Complete';
  }

  @override
  String dayOfTotal(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String get statusTaken => 'Taken';

  @override
  String get statusMissed => 'Missed';

  @override
  String get statusPending => 'Pending';
}

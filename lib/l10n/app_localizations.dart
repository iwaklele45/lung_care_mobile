import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'LungCare+'**
  String get appTitle;

  /// No description provided for @greeting.
  ///
  /// In id, this message translates to:
  /// **'Halo, {name}'**
  String greeting(String name);

  /// No description provided for @howAreYouFeeling.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana perasaanmu jam {time} hari ini?'**
  String howAreYouFeeling(String time);

  /// No description provided for @goodMorning.
  ///
  /// In id, this message translates to:
  /// **'Selamat Pagi, {name}'**
  String goodMorning(String name);

  /// No description provided for @profileTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil Saya'**
  String get profileTitle;

  /// No description provided for @editProfile.
  ///
  /// In id, this message translates to:
  /// **'Edit Profil'**
  String get editProfile;

  /// No description provided for @settings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settings;

  /// No description provided for @helpAndSupport.
  ///
  /// In id, this message translates to:
  /// **'Bantuan & Dukungan'**
  String get helpAndSupport;

  /// No description provided for @logout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get logout;

  /// No description provided for @logoutSuccess.
  ///
  /// In id, this message translates to:
  /// **'Berhasil logout.'**
  String get logoutSuccess;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @notifications.
  ///
  /// In id, this message translates to:
  /// **'NOTIFIKASI'**
  String get notifications;

  /// No description provided for @medicationReminder.
  ///
  /// In id, this message translates to:
  /// **'Pengingat Obat'**
  String get medicationReminder;

  /// No description provided for @medicationReminderDesc.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi jadwal minum obat'**
  String get medicationReminderDesc;

  /// No description provided for @checkInReminder.
  ///
  /// In id, this message translates to:
  /// **'Pengingat Check-in'**
  String get checkInReminder;

  /// No description provided for @checkInReminderDesc.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi check-in harian'**
  String get checkInReminderDesc;

  /// No description provided for @generalNotification.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi Umum'**
  String get generalNotification;

  /// No description provided for @generalNotificationDesc.
  ///
  /// In id, this message translates to:
  /// **'Info & update aplikasi'**
  String get generalNotificationDesc;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'BAHASA'**
  String get language;

  /// No description provided for @indonesian.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get indonesian;

  /// No description provided for @english.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @helpTitle.
  ///
  /// In id, this message translates to:
  /// **'Bantuan & Dukungan'**
  String get helpTitle;

  /// No description provided for @helpHeader.
  ///
  /// In id, this message translates to:
  /// **'Ada yang bisa kami bantu?'**
  String get helpHeader;

  /// No description provided for @helpSubheader.
  ///
  /// In id, this message translates to:
  /// **'Hubungi tim kami atau temukan jawaban\ndi pertanyaan yang sering ditanyakan.'**
  String get helpSubheader;

  /// No description provided for @contactUs.
  ///
  /// In id, this message translates to:
  /// **'HUBUNGI KAMI'**
  String get contactUs;

  /// No description provided for @whatsapp.
  ///
  /// In id, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @chatDirectly.
  ///
  /// In id, this message translates to:
  /// **'Chat langsung'**
  String get chatDirectly;

  /// No description provided for @email.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @sendMessage.
  ///
  /// In id, this message translates to:
  /// **'Kirim pesan'**
  String get sendMessage;

  /// No description provided for @faq.
  ///
  /// In id, this message translates to:
  /// **'PERTANYAAN UMUM (FAQ)'**
  String get faq;

  /// No description provided for @aboutApp.
  ///
  /// In id, this message translates to:
  /// **'TENTANG APLIKASI'**
  String get aboutApp;

  /// No description provided for @appVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi Aplikasi'**
  String get appVersion;

  /// No description provided for @developer.
  ///
  /// In id, this message translates to:
  /// **'Pengembang'**
  String get developer;

  /// No description provided for @developerName.
  ///
  /// In id, this message translates to:
  /// **'Tim LungCare+'**
  String get developerName;

  /// No description provided for @serviceArea.
  ///
  /// In id, this message translates to:
  /// **'Wilayah Layanan'**
  String get serviceArea;

  /// No description provided for @serviceAreaValue.
  ///
  /// In id, this message translates to:
  /// **'Surabaya'**
  String get serviceAreaValue;

  /// No description provided for @cannotOpenWhatsApp.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat membuka WhatsApp.'**
  String get cannotOpenWhatsApp;

  /// No description provided for @cannotOpenEmail.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat membuka email.'**
  String get cannotOpenEmail;

  /// No description provided for @faq1Question.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana cara menambahkan jadwal obat?'**
  String get faq1Question;

  /// No description provided for @faq1Answer.
  ///
  /// In id, this message translates to:
  /// **'Buka halaman \"Jadwal Obat\" melalui menu utama, lalu tekan tombol + di pojok kanan bawah. Isi nama obat, dosis, dan waktu minum, kemudian tekan \"Simpan\".'**
  String get faq1Answer;

  /// No description provided for @faq2Question.
  ///
  /// In id, this message translates to:
  /// **'Apakah data saya aman?'**
  String get faq2Question;

  /// No description provided for @faq2Answer.
  ///
  /// In id, this message translates to:
  /// **'Ya. Data Anda disimpan secara terenkripsi di server Firebase dan hanya dapat diakses oleh akun Anda sendiri. Kami tidak membagikan data pribadi kepada pihak ketiga.'**
  String get faq2Answer;

  /// No description provided for @faq3Question.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana cara mengubah profil saya?'**
  String get faq3Question;

  /// No description provided for @faq3Answer.
  ///
  /// In id, this message translates to:
  /// **'Buka tab \"Profil\" lalu tekan \"Edit Profil\". Anda dapat mengubah nama, nomor WhatsApp, dan alamat.'**
  String get faq3Answer;

  /// No description provided for @faq4Question.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi tidak muncul, apa yang harus dilakukan?'**
  String get faq4Question;

  /// No description provided for @faq4Answer.
  ///
  /// In id, this message translates to:
  /// **'Pastikan izin notifikasi untuk LungCare+ sudah diaktifkan di pengaturan HP Anda. Jika masih bermasalah, coba logout lalu login kembali.'**
  String get faq4Answer;

  /// No description provided for @faq5Question.
  ///
  /// In id, this message translates to:
  /// **'Apakah layanan ini tersedia di luar Surabaya?'**
  String get faq5Question;

  /// No description provided for @faq5Answer.
  ///
  /// In id, this message translates to:
  /// **'Saat ini LungCare+ hanya tersedia untuk wilayah Kota Surabaya. Kami berencana memperluas cakupan di masa mendatang.'**
  String get faq5Answer;

  /// No description provided for @symptomsCheck.
  ///
  /// In id, this message translates to:
  /// **'CEK GEJALA'**
  String get symptomsCheck;

  /// No description provided for @tapToRate.
  ///
  /// In id, this message translates to:
  /// **'Tap untuk menilai'**
  String get tapToRate;

  /// No description provided for @additionalNotes.
  ///
  /// In id, this message translates to:
  /// **'CATATAN TAMBAHAN'**
  String get additionalNotes;

  /// No description provided for @otherSymptoms.
  ///
  /// In id, this message translates to:
  /// **'Gejala Lainnya'**
  String get otherSymptoms;

  /// No description provided for @completeCheckIn.
  ///
  /// In id, this message translates to:
  /// **'Selesai Check-in'**
  String get completeCheckIn;

  /// No description provided for @alreadyCheckedIn.
  ///
  /// In id, this message translates to:
  /// **'Sudah Check-in Hari Ini'**
  String get alreadyCheckedIn;

  /// No description provided for @selectSymptomFirst.
  ///
  /// In id, this message translates to:
  /// **'Pilih minimal satu gejala dulu.'**
  String get selectSymptomFirst;

  /// No description provided for @checkInSaved.
  ///
  /// In id, this message translates to:
  /// **'Check-in tersimpan.'**
  String get checkInSaved;

  /// No description provided for @checkInFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan check-in: {error}'**
  String checkInFailed(String error);

  /// No description provided for @currentStreak.
  ///
  /// In id, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @dayCount.
  ///
  /// In id, this message translates to:
  /// **'{count} Hari'**
  String dayCount(int count);

  /// No description provided for @dataSecureNote.
  ///
  /// In id, this message translates to:
  /// **'Data Anda disimpan dengan aman dan hanya dibagikan dengan provider Anda.'**
  String get dataSecureNote;

  /// No description provided for @nausea.
  ///
  /// In id, this message translates to:
  /// **'Mual'**
  String get nausea;

  /// No description provided for @dizziness.
  ///
  /// In id, this message translates to:
  /// **'Pusing'**
  String get dizziness;

  /// No description provided for @fatigue.
  ///
  /// In id, this message translates to:
  /// **'Kelelahan'**
  String get fatigue;

  /// No description provided for @fever.
  ///
  /// In id, this message translates to:
  /// **'Demam'**
  String get fever;

  /// No description provided for @none.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada'**
  String get none;

  /// No description provided for @mild.
  ///
  /// In id, this message translates to:
  /// **'Ringan'**
  String get mild;

  /// No description provided for @moderate.
  ///
  /// In id, this message translates to:
  /// **'Sedang'**
  String get moderate;

  /// No description provided for @severe.
  ///
  /// In id, this message translates to:
  /// **'Parah'**
  String get severe;

  /// No description provided for @verySevere.
  ///
  /// In id, this message translates to:
  /// **'Sangat Parah'**
  String get verySevere;

  /// No description provided for @dashboard.
  ///
  /// In id, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @medicationHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Pengobatan'**
  String get medicationHistory;

  /// No description provided for @tbEducationChatbot.
  ///
  /// In id, this message translates to:
  /// **'Chatbot Edukasi TBC'**
  String get tbEducationChatbot;

  /// No description provided for @healthFacilities.
  ///
  /// In id, this message translates to:
  /// **'Fasilitas Kesehatan'**
  String get healthFacilities;

  /// No description provided for @todaysSchedule.
  ///
  /// In id, this message translates to:
  /// **'Jadwal Hari Ini'**
  String get todaysSchedule;

  /// No description provided for @viewAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua'**
  String get viewAll;

  /// No description provided for @doseCheckInSuccess.
  ///
  /// In id, this message translates to:
  /// **'Dose check-in tercatat! 🎉'**
  String get doseCheckInSuccess;

  /// No description provided for @tryAgain.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get tryAgain;

  /// No description provided for @addMedicine.
  ///
  /// In id, this message translates to:
  /// **'Tambah Obat'**
  String get addMedicine;

  /// No description provided for @dailyCheckIn.
  ///
  /// In id, this message translates to:
  /// **'Check-in Harian'**
  String get dailyCheckIn;

  /// No description provided for @myProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil Saya'**
  String get myProfile;

  /// No description provided for @fullName.
  ///
  /// In id, this message translates to:
  /// **'Nama Lengkap'**
  String get fullName;

  /// No description provided for @whatsappNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor WhatsApp'**
  String get whatsappNumber;

  /// No description provided for @address.
  ///
  /// In id, this message translates to:
  /// **'Alamat'**
  String get address;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @requiredField.
  ///
  /// In id, this message translates to:
  /// **'Wajib diisi.'**
  String get requiredField;

  /// No description provided for @saveProfileFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan profil.'**
  String get saveProfileFailed;

  /// No description provided for @dataNotFound.
  ///
  /// In id, this message translates to:
  /// **'Data tidak ditemukan.'**
  String get dataNotFound;

  /// No description provided for @greetingMorning.
  ///
  /// In id, this message translates to:
  /// **'Selamat pagi'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In id, this message translates to:
  /// **'Selamat siang'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In id, this message translates to:
  /// **'Selamat malam'**
  String get greetingEvening;

  /// No description provided for @helloName.
  ///
  /// In id, this message translates to:
  /// **'Halo, {name}!'**
  String helloName(String name);

  /// No description provided for @navHome.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get navHome;

  /// No description provided for @navMeds.
  ///
  /// In id, this message translates to:
  /// **'Obat'**
  String get navMeds;

  /// No description provided for @navCheckIn.
  ///
  /// In id, this message translates to:
  /// **'Check-in'**
  String get navCheckIn;

  /// No description provided for @navProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get navProfile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

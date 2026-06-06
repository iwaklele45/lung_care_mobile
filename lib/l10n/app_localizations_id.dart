// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'LungCare+';

  @override
  String greeting(String name) {
    return 'Halo, $name';
  }

  @override
  String howAreYouFeeling(String time) {
    return 'Bagaimana perasaanmu jam $time hari ini?';
  }

  @override
  String goodMorning(String name) {
    return 'Selamat Pagi, $name';
  }

  @override
  String get profileTitle => 'Profil Saya';

  @override
  String get editProfile => 'Edit Profil';

  @override
  String get settings => 'Pengaturan';

  @override
  String get helpAndSupport => 'Bantuan & Dukungan';

  @override
  String get logout => 'Keluar';

  @override
  String get logoutSuccess => 'Berhasil logout.';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get notifications => 'NOTIFIKASI';

  @override
  String get medicationReminder => 'Pengingat Obat';

  @override
  String get medicationReminderDesc => 'Notifikasi jadwal minum obat';

  @override
  String get checkInReminder => 'Pengingat Check-in';

  @override
  String get checkInReminderDesc => 'Notifikasi check-in harian';

  @override
  String get generalNotification => 'Notifikasi Umum';

  @override
  String get generalNotificationDesc => 'Info & update aplikasi';

  @override
  String get language => 'BAHASA';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get english => 'English';

  @override
  String get helpTitle => 'Bantuan & Dukungan';

  @override
  String get helpHeader => 'Ada yang bisa kami bantu?';

  @override
  String get helpSubheader =>
      'Hubungi tim kami atau temukan jawaban\ndi pertanyaan yang sering ditanyakan.';

  @override
  String get contactUs => 'HUBUNGI KAMI';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get chatDirectly => 'Chat langsung';

  @override
  String get email => 'Email';

  @override
  String get sendMessage => 'Kirim pesan';

  @override
  String get faq => 'PERTANYAAN UMUM (FAQ)';

  @override
  String get aboutApp => 'TENTANG APLIKASI';

  @override
  String get appVersion => 'Versi Aplikasi';

  @override
  String get developer => 'Pengembang';

  @override
  String get developerName => 'Tim LungCare+';

  @override
  String get serviceArea => 'Wilayah Layanan';

  @override
  String get serviceAreaValue => 'Surabaya';

  @override
  String get cannotOpenWhatsApp => 'Tidak dapat membuka WhatsApp.';

  @override
  String get cannotOpenEmail => 'Tidak dapat membuka email.';

  @override
  String get faq1Question => 'Bagaimana cara menambahkan jadwal obat?';

  @override
  String get faq1Answer =>
      'Buka halaman \"Jadwal Obat\" melalui menu utama, lalu tekan tombol + di pojok kanan bawah. Isi nama obat, dosis, dan waktu minum, kemudian tekan \"Simpan\".';

  @override
  String get faq2Question => 'Apakah data saya aman?';

  @override
  String get faq2Answer =>
      'Ya. Data Anda disimpan secara terenkripsi di server Firebase dan hanya dapat diakses oleh akun Anda sendiri. Kami tidak membagikan data pribadi kepada pihak ketiga.';

  @override
  String get faq3Question => 'Bagaimana cara mengubah profil saya?';

  @override
  String get faq3Answer =>
      'Buka tab \"Profil\" lalu tekan \"Edit Profil\". Anda dapat mengubah nama, nomor WhatsApp, dan alamat.';

  @override
  String get faq4Question =>
      'Notifikasi tidak muncul, apa yang harus dilakukan?';

  @override
  String get faq4Answer =>
      'Pastikan izin notifikasi untuk LungCare+ sudah diaktifkan di pengaturan HP Anda. Jika masih bermasalah, coba logout lalu login kembali.';

  @override
  String get faq5Question => 'Apakah layanan ini tersedia di luar Surabaya?';

  @override
  String get faq5Answer =>
      'Saat ini LungCare+ hanya tersedia untuk wilayah Kota Surabaya. Kami berencana memperluas cakupan di masa mendatang.';

  @override
  String get symptomsCheck => 'CEK GEJALA';

  @override
  String get tapToRate => 'Tap untuk menilai';

  @override
  String get additionalNotes => 'CATATAN TAMBAHAN';

  @override
  String get otherSymptoms => 'Gejala Lainnya';

  @override
  String get completeCheckIn => 'Selesai Check-in';

  @override
  String get alreadyCheckedIn => 'Sudah Check-in Hari Ini';

  @override
  String get selectSymptomFirst => 'Pilih minimal satu gejala dulu.';

  @override
  String get checkInSaved => 'Check-in tersimpan.';

  @override
  String checkInFailed(String error) {
    return 'Gagal menyimpan check-in: $error';
  }

  @override
  String get currentStreak => 'Current Streak';

  @override
  String dayCount(int count) {
    return '$count Hari';
  }

  @override
  String get dataSecureNote =>
      'Data Anda disimpan dengan aman dan hanya dibagikan dengan provider Anda.';

  @override
  String get nausea => 'Mual';

  @override
  String get dizziness => 'Pusing';

  @override
  String get fatigue => 'Kelelahan';

  @override
  String get fever => 'Demam';

  @override
  String get none => 'Tidak Ada';

  @override
  String get mild => 'Ringan';

  @override
  String get moderate => 'Sedang';

  @override
  String get severe => 'Parah';

  @override
  String get verySevere => 'Sangat Parah';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get medicationHistory => 'Riwayat Pengobatan';

  @override
  String get tbEducationChatbot => 'Chatbot Edukasi TBC';

  @override
  String get healthFacilities => 'Fasilitas Kesehatan';

  @override
  String get todaysSchedule => 'Jadwal Hari Ini';

  @override
  String get viewAll => 'Lihat semua';

  @override
  String get doseCheckInSuccess => 'Dose check-in tercatat! 🎉';

  @override
  String get tryAgain => 'Coba Lagi';

  @override
  String get addMedicine => 'Tambah Obat';

  @override
  String get dailyCheckIn => 'Check-in Harian';

  @override
  String get myProfile => 'Profil Saya';

  @override
  String get fullName => 'Nama Lengkap';

  @override
  String get whatsappNumber => 'Nomor WhatsApp';

  @override
  String get address => 'Alamat';

  @override
  String get save => 'Simpan';

  @override
  String get requiredField => 'Wajib diisi.';

  @override
  String get saveProfileFailed => 'Gagal menyimpan profil.';

  @override
  String get dataNotFound => 'Data tidak ditemukan.';

  @override
  String get greetingMorning => 'Selamat pagi';

  @override
  String get greetingAfternoon => 'Selamat siang';

  @override
  String get greetingEvening => 'Selamat malam';

  @override
  String helloName(String name) {
    return 'Halo, $name!';
  }

  @override
  String get navHome => 'Beranda';

  @override
  String get navMeds => 'Obat';

  @override
  String get navCheckIn => 'Check-in';

  @override
  String get navProfile => 'Profil';

  @override
  String get medicationSchedule => 'Jadwal Obat';

  @override
  String get medicationScheduleTitle => 'Jadwal Minum Obat';

  @override
  String get setYourReminder => 'Atur Pengingat Anda';

  @override
  String get noRemindersYet => 'Belum ada pengingat obat.';

  @override
  String get intensivePhase => 'Tahap Intensif (Bulan 1-2)';

  @override
  String get intensivePhaseDesc =>
      'Fase pengobatan awal yang membutuhkan kedisiplinan tinggi.';

  @override
  String get morningAfterBreakfast => 'Pagi Hari (Setelah Sarapan)';

  @override
  String get recommendedTime => 'Direkomendasikan pukul 07:00 - 09:00';

  @override
  String get confirmStock => 'Konfirmasi Stok Obat';

  @override
  String get remainingStock => 'Sisa Stok Bulan Ini';

  @override
  String pillCount(int remaining, int total) {
    return '$remaining / $total Pil';
  }

  @override
  String daysLeftSuffix(int days) {
    return 'Cukup untuk $days hari ke depan';
  }

  @override
  String get medicationTracker => 'Pelacak Obat';

  @override
  String get scheduleManagement => 'Manajemen Jadwal Obat';

  @override
  String get scheduleManagementDesc =>
      'Kelola daftar obat dan jadwal konsumsi Anda.';

  @override
  String get noScheduleYet => 'Belum ada jadwal obat.\nTekan + untuk menambah.';

  @override
  String get editMedicine => 'Edit Obat';

  @override
  String saveFailed(String error) {
    return 'Gagal menyimpan jadwal: $error';
  }

  @override
  String get deleteFailed => 'Gagal menghapus jadwal.';

  @override
  String get deleteScheduleTitle => 'Hapus jadwal ini?';

  @override
  String get deleteScheduleDesc =>
      'Jadwal obat ini akan dihapus secara permanen dari daftar pengingat Anda.';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get medicineName => 'Nama Obat';

  @override
  String get medicineNameHint => 'Contoh: Paracetamol';

  @override
  String get medicineAmount => 'Jumlah Obat';

  @override
  String get medicineAmountHint => 'Contoh: 10';

  @override
  String get medicineType => 'Jenis Obat';

  @override
  String get medicineTypeHint => 'Pilih jenis';

  @override
  String get dosage => 'Dosis';

  @override
  String get dosageHint => 'Contoh: 500mg';

  @override
  String get frequency => 'Frekuensi';

  @override
  String get medicineColor => 'Warna Obat';

  @override
  String get intakeTime => 'Waktu Minum (Jam)';

  @override
  String intakeTimeMultiple(int count) {
    return 'Waktu Minum (${count}x)';
  }

  @override
  String timeLabel(int index) {
    return 'Jam $index';
  }

  @override
  String get enableReminder => 'Aktifkan Pengingat';

  @override
  String get saveMedicine => 'Simpan Obat';

  @override
  String get fillTypeAndTime => 'Lengkapi jenis obat dan waktu minum.';

  @override
  String get tablet => 'Tablet';

  @override
  String get capsule => 'Kapsul';

  @override
  String get syrup => 'Sirup';

  @override
  String get injection => 'Injeksi';

  @override
  String get onceDaily => '1x sehari';

  @override
  String get twiceDaily => '2x sehari';

  @override
  String get thriceDaily => '3x sehari';

  @override
  String get white => 'Putih';

  @override
  String get red => 'Merah';

  @override
  String get blue => 'Biru';

  @override
  String get yellow => 'Kuning';

  @override
  String get green => 'Hijau';

  @override
  String get nextDose => 'DOSIS BERIKUTNYA';

  @override
  String get checkInDose => 'Check-in Dosis';

  @override
  String get checkingIn => 'Memproses...';

  @override
  String get notYetTime => 'Belum waktunya';

  @override
  String get treatmentProgress => 'Progres Pengobatan';

  @override
  String percentComplete(int percent) {
    return '$percent% Selesai';
  }

  @override
  String dayOfTotal(int day, int total) {
    return 'Hari $day dari $total';
  }

  @override
  String get statusTaken => 'Diminum';

  @override
  String get statusMissed => 'Terlewat';

  @override
  String get statusPending => 'Menunggu';
}

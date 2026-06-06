import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/l10n/app_localizations.dart';
import 'package:lung_care_mobile/src/core/locale/locale_provider.dart';
import 'package:lung_care_mobile/src/core/notifications/notification_preferences.dart';
import 'package:lung_care_mobile/src/core/notifications/notification_service.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/data/datasource/schedule_remote_data_source.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  NotificationPreferences _preferences = NotificationPreferences.defaults();
  final _scheduleDataSource = ScheduleRemoteDataSource();
  bool _loading = true;
  bool _saving = false;
  bool? _canScheduleExact;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await NotificationService.instance.loadPreferences();
    final canScheduleExact = await NotificationService.instance
        .canScheduleExactNotifications();
    if (!mounted) return;
    setState(() {
      _preferences = preferences;
      _canScheduleExact = canScheduleExact;
      _loading = false;
    });
  }

  Future<void> _savePreferences(NotificationPreferences preferences) async {
    setState(() {
      _preferences = preferences;
      _saving = true;
    });
    try {
      await NotificationService.instance.savePreferences(preferences);
      await _syncMedicationReminders();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan pengaturan notifikasi.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _syncMedicationReminders() async {
    final medications = await _scheduleDataSource.fetchSchedules();
    await NotificationService.instance.syncMedicationReminders(medications);
  }

  Future<void> _requestExactPermission() async {
    final granted = await NotificationService.instance
        .requestExactAlarmPermission();
    if (!mounted) return;
    setState(() => _canScheduleExact = granted);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          granted == true
              ? 'Izin alarm presisi aktif.'
              : 'Izin alarm presisi belum aktif.',
        ),
      ),
    );
  }

  Future<void> _requestFullScreenPermission() async {
    final granted = await NotificationService.instance
        .requestFullScreenIntentPermission();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          granted == true
              ? 'Izin popup layar penuh aktif.'
              : 'Aktifkan popup layar penuh dari pengaturan sistem.',
        ),
      ),
    );
  }

  Future<void> _sendTestNotification() async {
    await NotificationService.instance.showTestNotification();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifikasi percobaan dikirim.')),
    );
  }

  Future<void> _sendFullScreenTestReminder() async {
    await NotificationService.instance.scheduleFullScreenTestReminder();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tes popup dijadwalkan 8 detik lagi. Kunci layar HP.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final localeProvider = context.read<LocaleProvider>();
    final currentLang = localeProvider.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.bodyColor,
      appBar: AppBar(
        title: Text(
          l.settingsTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.bodyColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Notification Section ──────────────────────────────
                  _SectionHeader(title: l.notifications),
                  const SizedBox(height: 12),
                  _SwitchTile(
                    icon: Icons.medication_rounded,
                    label: l.medicationReminder,
                    subtitle: l.medicationReminderDesc,
                    value: _preferences.medicationReminder,
                    onChanged: _saving
                        ? null
                        : (v) => _savePreferences(
                            _preferences.copyWith(medicationReminder: v),
                          ),
                  ),
                  const SizedBox(height: 10),
                  _SwitchTile(
                    icon: Icons.check_circle_outline_rounded,
                    label: l.checkInReminder,
                    subtitle: l.checkInReminderDesc,
                    value: _preferences.checkInReminder,
                    onChanged: _saving
                        ? null
                        : (v) => _savePreferences(
                            _preferences.copyWith(checkInReminder: v),
                          ),
                  ),
                  const SizedBox(height: 10),
                  _SwitchTile(
                    icon: Icons.notifications_none_rounded,
                    label: l.generalNotification,
                    subtitle: l.generalNotificationDesc,
                    value: _preferences.generalNotification,
                    onChanged: _saving
                        ? null
                        : (v) => _savePreferences(
                            _preferences.copyWith(generalNotification: v),
                          ),
                  ),
                  const SizedBox(height: 10),
                  _SwitchTile(
                    icon: Icons.volume_up_outlined,
                    label: 'Suara Pengingat',
                    subtitle: 'Mainkan suara saat pengingat muncul.',
                    value: _preferences.sound,
                    onChanged: _saving
                        ? null
                        : (v) =>
                              _savePreferences(_preferences.copyWith(sound: v)),
                  ),
                  const SizedBox(height: 10),
                  _SwitchTile(
                    icon: Icons.vibration_rounded,
                    label: 'Getar',
                    subtitle: 'Getarkan perangkat saat pengingat muncul.',
                    value: _preferences.vibration,
                    onChanged: _saving
                        ? null
                        : (v) => _savePreferences(
                            _preferences.copyWith(vibration: v),
                          ),
                  ),
                  const SizedBox(height: 10),
                  _SnoozeTile(
                    value: _preferences.snoozeMinutes,
                    onChanged: _saving
                        ? null
                        : (value) => _savePreferences(
                            _preferences.copyWith(snoozeMinutes: value),
                          ),
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.alarm_on_rounded,
                    label: 'Alarm Presisi',
                    subtitle: _canScheduleExact == false
                        ? 'Belum aktif. Pengingat bisa sedikit terlambat.'
                        : 'Aktif untuk jadwal obat yang lebih tepat waktu.',
                    actionLabel: _canScheduleExact == false ? 'Aktifkan' : null,
                    onTap: _canScheduleExact == false
                        ? _requestExactPermission
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.open_in_full_rounded,
                    label: 'Popup Layar Penuh',
                    subtitle:
                        'Buka aplikasi otomatis saat pengingat obat berbunyi.',
                    actionLabel: 'Aktifkan',
                    onTap: _requestFullScreenPermission,
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.notification_add_outlined,
                    label: 'Tes Notifikasi',
                    subtitle: 'Kirim notifikasi percobaan ke perangkat ini.',
                    actionLabel: 'Kirim',
                    onTap: _sendTestNotification,
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.fullscreen_rounded,
                    label: 'Tes Popup Layar Penuh',
                    subtitle:
                        'Jadwalkan popup obat 8 detik lagi. Kunci layar setelah menekan.',
                    actionLabel: 'Tes',
                    onTap: _sendFullScreenTestReminder,
                  ),

                  const SizedBox(height: 28),

                  // ── Language Section ───────────────────────────────────
                  _SectionHeader(title: l.language),
                  const SizedBox(height: 12),
                  _LanguageTile(
                    flag: '🇮🇩',
                    label: l.indonesian,
                    isSelected: currentLang == 'id',
                    onTap: () => localeProvider.setLocale(const Locale('id')),
                  ),
                  const SizedBox(height: 10),
                  _LanguageTile(
                    flag: '🇬🇧',
                    label: l.english,
                    isSelected: currentLang == 'en',
                    onTap: () => localeProvider.setLocale(const Locale('en')),
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w600,
        color: AppColors.nautral,
      ),
    );
  }
}

// ── Switch Tile ───────────────────────────────────────────────────────────────

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bodyColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.nautral,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.secondary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}

class _SnoozeTile extends StatelessWidget {
  const _SnoozeTile({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    const options = [5, 10, 15];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bodyColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.snooze_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Durasi Tunda',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Waktu tambahan setelah tombol tunda ditekan.',
                  style: TextStyle(fontSize: 12, color: AppColors.nautral),
                ),
              ],
            ),
          ),
          SegmentedButton<int>(
            segments: options
                .map(
                  (minutes) => ButtonSegment<int>(
                    value: minutes,
                    label: Text('$minutes'),
                  ),
                )
                .toList(),
            selected: {value},
            onSelectionChanged: onChanged == null
                ? null
                : (selection) => onChanged!(selection.first),
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bodyColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.nautral,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onTap, child: Text(actionLabel!))
          else
            const Icon(Icons.check_circle_rounded, color: AppColors.primary),
        ],
      ),
    );
  }
}

// ── Language Tile ─────────────────────────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

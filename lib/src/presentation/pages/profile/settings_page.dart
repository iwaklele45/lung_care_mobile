import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/l10n/app_localizations.dart';
import 'package:lung_care_mobile/src/core/locale/locale_provider.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ── Notification settings ─────────────────────────────────────────────
  bool _medicationReminder = true;
  bool _checkInReminder = true;
  bool _generalNotification = true;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _medicationReminder = prefs.getBool('notif_medication') ?? true;
      _checkInReminder = prefs.getBool('notif_checkin') ?? true;
      _generalNotification = prefs.getBool('notif_general') ?? true;
      _loading = false;
    });
  }

  Future<void> _setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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
                    value: _medicationReminder,
                    onChanged: (v) {
                      setState(() => _medicationReminder = v);
                      _setBool('notif_medication', v);
                    },
                  ),
                  const SizedBox(height: 10),
                  _SwitchTile(
                    icon: Icons.check_circle_outline_rounded,
                    label: l.checkInReminder,
                    subtitle: l.checkInReminderDesc,
                    value: _checkInReminder,
                    onChanged: (v) {
                      setState(() => _checkInReminder = v);
                      _setBool('notif_checkin', v);
                    },
                  ),
                  const SizedBox(height: 10),
                  _SwitchTile(
                    icon: Icons.notifications_none_rounded,
                    label: l.generalNotification,
                    subtitle: l.generalNotificationDesc,
                    value: _generalNotification,
                    onChanged: (v) {
                      setState(() => _generalNotification = v);
                      _setBool('notif_general', v);
                    },
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
  final ValueChanged<bool> onChanged;

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
            activeColor: AppColors.secondary,
          ),
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

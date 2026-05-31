import 'package:flutter/material.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/data/datasource/check_in_remote_data_source.dart';

/// Body-only view rendered inside the Home shell's "Check-in" tab.
class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key, required this.userName});

  final String userName;

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final _notesController = TextEditingController();

  static const _symptoms = {
    'Nausea': Icons.medical_services_outlined,
    'Dizziness': Icons.blur_circular_outlined,
    'Fatigue': Icons.nightlight_outlined,
    'Fever': Icons.thermostat_outlined,
  };
  static const _levels = ['None', 'Mild', 'Moderate', 'Severe', 'Very Severe'];
  static const _emojis = ['😊', '🙂', '😐', '😟', '😣'];

  final Map<String, int> _ratings = {};
  final _dataSource = CheckInRemoteDataSource();
  bool _saving = false;
  bool _done = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkToday();
  }

  Future<void> _checkToday() async {
    try {
      final data = await _dataSource.getTodayCheckIn();
      if (data != null && mounted) {
        final symptoms = (data['symptoms'] as Map?) ?? const {};
        setState(() {
          _done = true;
          // Prefill the labels that match saved (lowercased) keys.
          for (final label in _symptoms.keys) {
            final value = symptoms[label.toLowerCase()];
            if (value is int) _ratings[label] = value;
          }
          _notesController.text = (data['additional_notes'] as String?) ?? '';
        });
      }
    } catch (_) {
      // Ignore: treat as not-yet-done so the user can still try.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (_ratings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu gejala dulu.')),
      );
      return;
    }
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _dataSource.addCheckIn(
        symptoms: _ratings.map(
          (key, value) => MapEntry(key.toLowerCase(), value),
        ),
        notes: _notesController.text.trim(),
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Check-in tersimpan.')),
      );
      setState(() {
        _done = true;
      });
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Gagal menyimpan check-in: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning, ${widget.userName}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'How are you feeling at ${TimeOfDay.now().format(context)} today?',
            style: const TextStyle(fontSize: 15, color: AppColors.nautral),
          ),
          const SizedBox(height: 18),
          _StreakCard(),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SYMPTOMS CHECK',
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.nautral,
                ),
              ),
              const Text(
                'Tap to rate intensity',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._symptoms.entries.map(
            (e) => _SymptomCard(
              label: e.key,
              icon: e.value,
              levels: _levels,
              emojis: _emojis,
              selected: _ratings[e.key],
              onSelect: _done
                  ? null
                  : (i) => setState(() => _ratings[e.key] = i),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'ADDITIONAL NOTES',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
              color: AppColors.nautral,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            maxLines: 4,
            enabled: !_done,
            decoration: InputDecoration(
              hintText: 'Other Symptoms',
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD8E2F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD8E2F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: (_saving || _done) ? null : _complete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.nautral,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _done
                          ? 'Sudah Check-in Hari Ini'
                          : 'Complete Check-in',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Your data is stored securely and only shared with your provider.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.nautral),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Streak',
                  style: TextStyle(fontSize: 14, color: AppColors.nautral),
                ),
                Text(
                  '12 Days',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          ...['M', 'T', 'W'].map(
            (d) => Padding(
              padding: const EdgeInsets.only(left: 4),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF1A4F8B),
                child: Text(
                  d,
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SymptomCard extends StatelessWidget {
  const _SymptomCard({
    required this.label,
    required this.icon,
    required this.levels,
    required this.emojis,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final IconData icon;
  final List<String> levels;
  final List<String> emojis;
  final int? selected;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(levels.length, (i) {
              final isSelected = selected == i;
              return GestureDetector(
                onTap: onSelect == null ? null : () => onSelect!(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        emojis[i],
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        levels[i],
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.nautral,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

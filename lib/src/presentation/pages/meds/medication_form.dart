import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';

/// Simple medication model shared by the add/edit form and tracker list.
class Medication {
  Medication({
    this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.dose,
    required this.frequency,
    required this.capsuleColor,
    required this.times,
    required this.reminder,
  });

  final String? id;
  final String name;
  final String amount;
  final String? type;
  final String dose;
  final String frequency;
  final String capsuleColor;
  final List<TimeOfDay> times;
  final bool reminder;

  factory Medication.fromMap(String id, Map<String, dynamic> map) {
    final rawTimes = (map['times'] as List?)?.cast<int>();
    final minutes =
        rawTimes ??
        [
          ((map['timeHour'] as int? ?? 0) * 60) +
              (map['timeMinute'] as int? ?? 0),
        ];
    return Medication(
      id: id,
      name: map['name'] as String? ?? '',
      amount: map['amount'] as String? ?? '',
      type: map['type'] as String?,
      dose: map['dose'] as String? ?? '',
      frequency: map['frequency'] as String? ?? '1x sehari',
      capsuleColor: map['capsuleColor'] as String? ?? 'Putih',
      times: minutes
          .map((m) => TimeOfDay(hour: m ~/ 60, minute: m % 60))
          .toList(),
      reminder: map['reminder'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'amount': amount,
    'type': type,
    'dose': dose,
    'frequency': frequency,
    'capsuleColor': capsuleColor,
    'times': times.map((t) => (t.hour * 60) + t.minute).toList(),
    'reminder': reminder,
  };
}

/// Reusable add/edit medication form (body-only).
class MedicationForm extends StatefulWidget {
  const MedicationForm({super.key, this.initial, required this.onSubmit});

  final Medication? initial;

  /// Returns `true` if the form should be cleared after a successful submit.
  final Future<bool> Function(Medication) onSubmit;

  @override
  State<MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.initial?.name ?? '',
  );
  late final _amountController = TextEditingController(
    text: widget.initial?.amount ?? '',
  );
  late final _doseController = TextEditingController(
    text: widget.initial?.dose ?? '',
  );

  late String? _type = widget.initial?.type;
  late String _frequency = widget.initial?.frequency ?? '1x sehari';
  late String _capsuleColor = widget.initial?.capsuleColor ?? 'Putih';
  late List<TimeOfDay?> _times = _initTimes();
  late bool _reminder = widget.initial?.reminder ?? true;

  static const _types = ['Tablet', 'Kapsul', 'Sirup', 'Injeksi'];
  static const _frequencies = ['1x sehari', '2x sehari', '3x sehari'];
  static const _colors = ['Putih', 'Merah', 'Biru', 'Kuning', 'Hijau'];

  /// Number of intake times derived from the frequency label (e.g. "2x" -> 2).
  int get _doseCount =>
      int.tryParse(RegExp(r'\d+').firstMatch(_frequency)?.group(0) ?? '1') ?? 1;

  List<TimeOfDay?> _initTimes() {
    final freq = widget.initial?.frequency ?? '1x';
    final count =
        int.tryParse(RegExp(r'\d+').firstMatch(freq)?.group(0) ?? '1') ?? 1;
    final initial = widget.initial?.times ?? const [];
    return List<TimeOfDay?>.generate(
      count,
      (i) => i < initial.length ? initial[i] : null,
    );
  }

  void _onFrequencyChanged(String value) {
    setState(() {
      _frequency = value;
      final count = _doseCount;
      if (_times.length < count) {
        _times = [..._times, ...List.filled(count - _times.length, null)];
      } else if (_times.length > count) {
        _times = _times.sublist(0, count);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index] ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _times[index] = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_type == null || _times.any((t) => t == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi jenis obat dan waktu minum.')),
      );
      return;
    }
    widget
        .onSubmit(
          Medication(
            id: widget.initial?.id,
            name: _nameController.text.trim(),
            amount: _amountController.text.trim(),
            type: _type,
            dose: _doseController.text.trim(),
            frequency: _frequency,
            capsuleColor: _capsuleColor,
            times: _times.cast<TimeOfDay>(),
            reminder: _reminder,
          ),
        )
        .then((shouldReset) {
          if (shouldReset && mounted) _reset();
        });
  }

  void _reset() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _amountController.clear();
    _doseController.clear();
    setState(() {
      _type = null;
      _frequency = '1x sehari';
      _capsuleColor = 'Putih';
      _times = [null];
      _reminder = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Field(
              label: 'Nama Obat',
              child: _input(_nameController, 'Contoh: Paracetamol'),
            ),
            _Field(
              label: 'Jumlah Obat',
              child: _input(
                _amountController,
                'Contoh: 10',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Field(
                    label: 'Jenis Obat',
                    child: _dropdown(
                      value: _type,
                      hint: 'Pilih jenis',
                      items: _types,
                      onChanged: (v) => setState(() => _type = v),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _Field(
                    label: 'Dosis',
                    child: _input(_doseController, 'Contoh: 500mg'),
                  ),
                ),
              ],
            ),
            _Field(
              label: 'Frekuensi',
              child: _dropdown(
                value: _frequency,
                items: _frequencies,
                onChanged: (v) => _onFrequencyChanged(v!),
              ),
            ),
            _Field(
              label: 'Warna Obat',
              child: _dropdown(
                value: _capsuleColor,
                items: _colors,
                onChanged: (v) => setState(() => _capsuleColor = v!),
              ),
            ),
            _Field(
              label: _times.length > 1
                  ? 'Waktu Minum (${_times.length}x)'
                  : 'Waktu Minum (Jam)',
              child: Column(
                children: List.generate(_times.length, (i) {
                  final time = _times[i];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: i == _times.length - 1 ? 0 : 10,
                    ),
                    child: InkWell(
                      onTap: () => _pickTime(i),
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: _decoration(null),
                        child: Row(
                          children: [
                            if (_times.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  'Jam ${i + 1}',
                                  style: const TextStyle(
                                    color: AppColors.nautral,
                                  ),
                                ),
                              ),
                            Text(
                              time?.format(context) ?? '--:--',
                              style: TextStyle(
                                color: time == null
                                    ? Colors.grey.shade500
                                    : AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 4),
            _ReminderCard(
              value: _reminder,
              onChanged: (v) => setState(() => _reminder = v),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B5CAB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.save_outlined, size: 20),
                label: const Text(
                  'Simpan Obat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: _decoration(hint),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi.' : null,
    );
  }

  Widget _dropdown({
    required String? value,
    String? hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      hint: hint == null ? null : Text(hint),
      decoration: _decoration(null),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _decoration(String? hint) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border(const Color(0xFFD8E2F0)),
      enabledBorder: border(const Color(0xFFD8E2F0)),
      focusedBorder: border(AppColors.primary),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.ternary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Aktifkan Pengingat',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

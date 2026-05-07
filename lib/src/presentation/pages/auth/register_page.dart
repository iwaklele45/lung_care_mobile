import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/gen/assets.gen.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyColor,
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        elevation: 1,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Assets.icons.arrowLeftIcon.image(),
        ),
        title: const Text(
          'Daftar Akun Baru',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PageHero(),
              SizedBox(height: 28),
              _SectionTitle(text: 'INFORMASI PRIBADI'),
              SizedBox(height: 14),
              _LabeledInput(
                label: 'Nama Lengkap',
                hint: 'Contoh: Budi Santoso',
                icon: Assets.icons.profileIcon,
              ),
              SizedBox(height: 16),
              _LabeledInput(
                label: 'Nomor WhatsApp',
                hint: '08123456789',
                maxLength: 12,
                icon: Assets.icons.messageIcon,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 30),
              _SectionTitle(text: 'INFORMASI AKUN'),
              SizedBox(height: 14),
              _LabeledInput(
                label: 'Email',
                hint: 'contoh@email.com',
                icon: Assets.icons.mainIcon,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              _LabeledInput(
                label: 'Password',
                hint: 'Masukkan password',
                icon: Assets.icons.lockIcon,
                obscureText: true,
              ),
              SizedBox(height: 30),
              _SectionTitle(text: 'LOKASI'),
              SizedBox(height: 14),
              _LabeledInput(
                label: 'Alamat (Kota Surabaya)',
                hint: 'Kecamatan, Kelurahan...',
                icon: Assets.icons.locationIcon,
              ),
              SizedBox(height: 10),
              Text(
                'Layanan ini sementara hanya tersedia untuk wilayah Surabaya.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF5E6775),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4D95E6),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Buat Akun',
                        style: TextStyle(
                          fontSize: 27 / 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  Expanded(
                    child: Divider(thickness: 1, color: Color(0xFFD1D8E5)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'atau daftar dengan',
                      style: TextStyle(fontSize: 14, color: Color(0xFF566174)),
                    ),
                  ),
                  Expanded(
                    child: Divider(thickness: 1, color: Color(0xFFD1D8E5)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFC8CFDB)),
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  icon: Assets.icons.googleIcon.image(width: 22, height: 22),
                  label: const Text(
                    'Daftar dengan Google',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF21374A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Sudah punya akun?',
                    style: TextStyle(fontSize: 16, color: Color(0xFF4D5562)),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF3F8CE3),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageHero extends StatelessWidget {
  const _PageHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF3F8FE3),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3A3C8FE2),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Mulai Perjalanan\nSehat',
          style: TextStyle(
            fontSize: 48 / 2,
            height: 1.15,
            color: Color(0xFF0E2A3C),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Lengkapi data diri Anda untuk bergabung\n'
          'dengan platform pemantauan TBC.',
          style: TextStyle(
            fontSize: 17,
            height: 1.45,
            color: Color(0xFF586372),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        letterSpacing: 0.5,
        fontSize: 14 / 1.02,
        color: Color(0xFF557486),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _LabeledInput extends StatefulWidget {
  const _LabeledInput({
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLength = 100,
    this.keyboardType,
    this.obscureText = false,
  });

  final int maxLength;
  final String label;
  final String hint;
  final AssetGenImage icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  State<_LabeledInput> createState() => _LabeledInputState();
}

class _LabeledInputState extends State<_LabeledInput> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  void _toggleObscureText() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 27 / 2,
            color: Color(0xFF3E8DE4),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBEC8D6)),
          ),
          child: TextField(
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText && _isObscured,
            style: const TextStyle(fontSize: 16, color: Color(0xFF21374A)),
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color(0xFF6E7886),
                fontSize: 17 / 1.02,
              ),
              counterText: '',
              border: InputBorder.none,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(14),
                child: widget.icon.image(
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      onPressed: _toggleObscureText,
                      icon: Icon(
                        _isObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF717B8A),
                      ),
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ],
    );
  }
}

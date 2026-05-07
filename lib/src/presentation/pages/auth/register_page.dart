import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/gen/assets.gen.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/presentation/bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        address: _addressController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
          return;
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bodyColor,
        appBar: AppBar(
          backgroundColor: AppColors.appbarColor,
          elevation: 1,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          title: const Text(
            'LungCare+',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _PageHero(),
                  const SizedBox(height: 28),
                  const _SectionTitle(text: 'INFORMASI PRIBADI'),
                  const SizedBox(height: 14),
                  _LabeledInput(
                    controller: _fullNameController,
                    label: 'Nama Lengkap',
                    hint: 'Contoh: Budi Santoso',
                    icon: Assets.icons.profileIcon,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final fullName = value?.trim() ?? '';
                      if (fullName.isEmpty) {
                        return 'Nama lengkap wajib diisi.';
                      }
                      if (fullName.length < 3) {
                        return 'Nama minimal 3 karakter.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _LabeledInput(
                    controller: _phoneNumberController,
                    label: 'Nomor WhatsApp',
                    hint: '08123456789',
                    maxLength: 15,
                    icon: Assets.icons.messageIcon,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      final phoneNumber = value?.trim() ?? '';
                      if (phoneNumber.isEmpty) {
                        return 'Nomor WhatsApp wajib diisi.';
                      }
                      if (!RegExp(r'^[0-9]{10,15}$').hasMatch(phoneNumber)) {
                        return 'Gunakan 10-15 digit angka.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  const _SectionTitle(text: 'INFORMASI AKUN'),
                  const SizedBox(height: 14),
                  _LabeledInput(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'contoh@email.com',
                    icon: Assets.icons.mainIcon,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) {
                        return 'Email wajib diisi.';
                      }
                      if (!RegExp(
                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                      ).hasMatch(email)) {
                        return 'Format email tidak valid.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _LabeledInput(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Masukkan password',
                    icon: Assets.icons.lockIcon,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    onToggleObscure: () => setState(() {
                      _obscurePassword = !_obscurePassword;
                    }),
                    validator: (value) {
                      final password = value ?? '';
                      if (password.isEmpty) {
                        return 'Password wajib diisi.';
                      }
                      if (password.length < 6) {
                        return 'Password minimal 6 karakter.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  const _SectionTitle(text: 'LOKASI'),
                  const SizedBox(height: 14),
                  _LabeledInput(
                    controller: _addressController,
                    label: 'Alamat (Kota Surabaya)',
                    hint: 'Kecamatan, Kelurahan...',
                    icon: Assets.icons.locationIcon,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) {
                      final address = value?.trim() ?? '';
                      if (address.isEmpty) {
                        return 'Alamat wajib diisi.';
                      }
                      if (address.length < 5) {
                        return 'Alamat terlalu singkat.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
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
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return FilledButton(
                          onPressed: isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF4D95E6),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Row(
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
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 1, color: Color(0xFFD1D8E5)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'atau daftar dengan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF566174),
                          ),
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
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFC8CFDB)),
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      icon: Assets.icons.googleIcon.image(
                        width: 22,
                        height: 22,
                      ),
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
                  const _BottomLink(),
                ],
              ),
            ),
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
          'Daftar Akun Baru',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 0.5,
            color: Color(0xFF557486),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
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

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLength,
    this.keyboardType,
    this.obscureText = false,
    this.onToggleObscure,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final int? maxLength;
  final String label;
  final String hint;
  final AssetGenImage icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          child: TextFormField(
            controller: controller,
            maxLength: maxLength,
            keyboardType: keyboardType,
            obscureText: obscureText,
            textInputAction: textInputAction,
            onFieldSubmitted: onFieldSubmitted,
            inputFormatters: inputFormatters,
            validator: validator,
            style: const TextStyle(fontSize: 16, color: Color(0xFF21374A)),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF6E7886),
                fontSize: 17 / 1.02,
              ),
              counterText: '',
              border: InputBorder.none,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(14),
                child: icon.image(width: 20, height: 20, fit: BoxFit.contain),
              ),
              suffixIcon: onToggleObscure == null
                  ? null
                  : IconButton(
                      onPressed: onToggleObscure,
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF717B8A),
                      ),
                    ),
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

class _BottomLink extends StatelessWidget {
  const _BottomLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Sudah punya akun? '),
        GestureDetector(
          onTap: () => context.push('/login'),
          child: const Text(
            'Login sekarang',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A90E2),
            ),
          ),
        ),
      ],
    );
  }
}

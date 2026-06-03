import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/presentation/bloc/auth/auth_bloc.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();

  // AutovalidateMode: only validate after first submit attempt
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    // Pre-fill name from Google account if available
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      _fullNameController.text = user.displayName!;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    // Enable real-time validation after first submit attempt
    if (_autovalidateMode != AutovalidateMode.onUserInteraction) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      AuthSaveProfileRequested(
        name: _fullNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        address: _addressController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileSaved) {
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
          automaticallyImplyLeading: false,
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
              autovalidateMode: _autovalidateMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Google account info header
                  _GoogleAccountHeader(user: user),
                  const SizedBox(height: 28),
                  // Page hero
                  const _PageHero(),
                  const SizedBox(height: 28),
                  const _SectionTitle(text: 'INFORMASI PRIBADI'),
                  const SizedBox(height: 14),
                  _LabeledInput(
                    controller: _fullNameController,
                    label: 'Nama Lengkap',
                    hint: 'Contoh: Budi Santoso',
                    icon: Icons.person_outline_rounded,
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
                    icon: Icons.phone_outlined,
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
                  const _SectionTitle(text: 'LOKASI'),
                  const SizedBox(height: 14),
                  _LabeledInput(
                    controller: _addressController,
                    label: 'Alamat (Kota Surabaya)',
                    hint: 'Kecamatan, Kelurahan...',
                    icon: Icons.location_on_outlined,
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
                  const SizedBox(height: 28),
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
                                      'Simpan & Lanjutkan',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 22,
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleAccountHeader extends StatelessWidget {
  const _GoogleAccountHeader({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE6F4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: avatar + name + status badge
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE1F0FF),
                backgroundImage: user!.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user!.photoURL == null
                    ? const Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 26,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user!.displayName ?? 'Akun Google',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0E2A3C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Terhubung',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Email row – separated for clarity
          if (user!.email != null && user!.email!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: Color(0xFF7A8A9E),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user!.email!,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF586372),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
            Icons.edit_note_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Lengkapi Profil',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 0.5,
            color: Color(0xFF557486),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Satu Langkah\nLagi!',
          style: TextStyle(
            fontSize: 24,
            height: 1.15,
            color: Color(0xFF0E2A3C),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Lengkapi data diri Anda untuk mulai\nmenggunakan layanan LungCare+.',
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
        fontSize: 13.5,
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
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final int? maxLength;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
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
            fontSize: 13.5,
            color: Color(0xFF3E8DE4),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          keyboardType: keyboardType,
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
              fontSize: 16,
            ),
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(14),
              child: Icon(icon, size: 22, color: const Color(0xFF3E8DE4)),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            // Normal state border
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFBEC8D6)),
            ),
            // Focused state border
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF3E8DE4),
                width: 1.5,
              ),
            ),
            // Error state border
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE53935),
                width: 1.2,
              ),
            ),
            // Focused + error state border
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE53935),
                width: 1.5,
              ),
            ),
            // Error text style
            errorStyle: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFFE53935),
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}

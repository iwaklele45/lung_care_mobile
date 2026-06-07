import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lung_care_mobile/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/data/services/profile_storage_service.dart';
import 'package:lung_care_mobile/src/presentation/bloc/auth/auth_bloc.dart';
import 'package:lung_care_mobile/src/presentation/widgets/profile_picture_picker.dart';

/// Body-only view rendered inside the Home shell's "Profile" tab.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _user = FirebaseAuth.instance.currentUser;
  late final DocumentReference<Map<String, dynamic>>? _doc = _user == null
      ? null
      : FirebaseFirestore.instance.collection('users').doc(_user.uid);

  // Cached across tab switches so re-opening Profile doesn't re-fetch.
  static Future<DocumentSnapshot<Map<String, dynamic>>?>? _cachedFuture;

  /// True while uploading or deleting a profile picture.
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _cachedFuture ??= _doc?.get();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Instant fallback from FirebaseAuth (no loading needed).
    final currentUser = FirebaseAuth.instance.currentUser;
    final fallbackName = currentUser?.displayName?.isNotEmpty == true
        ? currentUser!.displayName!
        : currentUser?.email?.split('@').first ?? 'User';
    final fallbackEmail = currentUser?.email ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
        future: _cachedFuture,
        builder: (context, snapshot) {
          // Use Firestore data if available, otherwise instant fallback.
          final data = snapshot.data?.data() ?? const {};
          final name = (data['name'] as String?)?.isNotEmpty == true
              ? data['name'] as String
              : fallbackName;
          final email = (data['email'] as String?)?.isNotEmpty == true
              ? data['email'] as String
              : fallbackEmail;

          return Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ProfilePicturePicker(
                    imageUrl: (data['profilePictureUrl'] as String?)?.isNotEmpty == true
                        ? data['profilePictureUrl'] as String
                        : currentUser?.photoURL,
                    onChanged: (file) => _onProfilePicChanged(file, data),
                  ),
                  if (_isUploading)
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              Text(
                email,
                style: const TextStyle(fontSize: 14, color: AppColors.nautral),
              ),
              const SizedBox(height: 24),
              _Tile(
                icon: Icons.edit_outlined,
                label: l.editProfile,
                onTap: () => _openEditForm(context, data),
              ),
              const SizedBox(height: 12),
              _Tile(
                icon: Icons.settings_sharp,
                label: l.settings,
                onTap: () => context.push('/settings'),
              ),
              const SizedBox(height: 12),
              _Tile(
                icon: Icons.help_outline_rounded,
                label: l.helpAndSupport,
                onTap: () => context.push('/help-support'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthSignOutRequested());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Berhasil logout.')),
                    );
                    context.go('/login');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: Text(
                    l.logout,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openEditForm(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    if (_doc == null) return;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bodyColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditProfileForm(doc: _doc, data: data),
    );
    if (saved == true && mounted) {
      setState(() => _cachedFuture = _doc.get());
    }
  }

  /// Called when the user picks or removes a profile picture.
  ///
  /// Uploads to Firebase Storage, updates Firestore, and refreshes the view.
  Future<void> _onProfilePicChanged(File? file, Map<String, dynamic> data) async {
    if (_doc == null || !mounted) return;

    setState(() => _isUploading = true);

    try {
      final uid = _user!.uid;
      final storage = ProfileStorageService();

      if (file != null) {
        // Upload new picture
        final url = await storage.upload(uid: uid, imageFile: file);
        // Use set + merge so it works even if the doc doesn't exist yet
        await _doc!.set({
          'profilePictureUrl': url,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // Remove picture
        await storage.delete(uid);
        await _doc!.set({
          'profilePictureUrl': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Invalidate cache so the UI picks up the new URL
      if (mounted) {
        setState(() {
          _isUploading = false;
          _cachedFuture = _doc!.get();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui.')),
        );
      }
    } catch (e) {
      debugPrint('[ProfilePage] Profile picture update failed: $e');
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui foto profil.')),
        );
      }
    }
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ternary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.nautral),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  const _EditProfileForm({required this.doc, required this.data});

  final DocumentReference<Map<String, dynamic>> doc;
  final Map<String, dynamic> data;

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.data['name'] as String? ?? '',
  );
  late final _phoneController = TextEditingController(
    text: widget.data['phoneNumber'] as String? ?? '',
  );
  late final _addressController = TextEditingController(
    text: widget.data['address'] as String? ?? '',
  );
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.doc.update({
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan profil.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 16),
            _field(_nameController, 'Nama Lengkap'),
            const SizedBox(height: 14),
            _field(
              _phoneController,
              'Nomor WhatsApp',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            _field(_addressController, 'Alamat'),
            const SizedBox(height: 22),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.white,
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
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi.' : null,
    );
  }
}

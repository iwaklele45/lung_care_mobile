import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';

/// A tappable avatar widget that lets the user pick or remove a profile photo.
///
/// Shows the current image (from [imageUrl] or [imageFile]), a placeholder
/// icon when neither is set, and a camera overlay badge.  Tapping opens a
/// bottom sheet with Camera / Gallery / Remove options.
class ProfilePicturePicker extends StatefulWidget {
  const ProfilePicturePicker({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.onChanged,
    this.radius = 52,
  });

  /// Existing network URL (e.g. from Google or a prior upload).
  final String? imageUrl;

  /// Locally picked file (preview before upload).
  final File? imageFile;

  /// Called after the user picks or removes an image.
  ///
  /// * `null` → user removed the picture.
  /// * non-null → user picked a new picture.
  final ValueChanged<File?>? onChanged;

  final double radius;

  @override
  State<ProfilePicturePicker> createState() => _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends State<ProfilePicturePicker> {
  File? _localFile;

  @override
  void initState() {
    super.initState();
    _localFile = widget.imageFile;
  }

  @override
  void didUpdateWidget(covariant ProfilePicturePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageFile != oldWidget.imageFile) {
      _localFile = widget.imageFile;
    }
  }

  void _pickFrom(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (xFile == null) return;

    final file = File(xFile.path);
    setState(() => _localFile = file);
    widget.onChanged?.call(file);
  }

  void _remove() {
    setState(() => _localFile = null);
    widget.onChanged?.call(null);
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E2F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Foto Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 20),
              _OptionTile(
                icon: Icons.camera_alt_outlined,
                label: 'Ambil Foto',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFrom(ImageSource.camera);
                },
              ),
              const Divider(height: 1, color: Color(0xFFE8EEF6)),
              _OptionTile(
                icon: Icons.photo_library_outlined,
                label: 'Pilih dari Galeri',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFrom(ImageSource.gallery);
                },
              ),
              if (widget.imageUrl != null || _localFile != null) ...[
                const Divider(height: 1, color: Color(0xFFE8EEF6)),
                _OptionTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Hapus Foto',
                  iconColor: Colors.red,
                  labelColor: Colors.red,
                  onTap: () {
                    Navigator.pop(ctx);
                    _remove();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasLocal = _localFile != null;
    final hasUrl = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: widget.radius,
          backgroundColor: AppColors.ternary,
          backgroundImage: hasLocal
              ? FileImage(_localFile!)
              : (hasUrl ? NetworkImage(widget.imageUrl!) : null),
          child: (hasLocal || hasUrl)
              ? null
              : Icon(
                  Icons.person_rounded,
                  size: widget.radius * 1.1,
                  color: AppColors.primary,
                ),
        ),
        GestureDetector(
          onTap: _showPickerSheet,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? AppColors.primary),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: labelColor ?? AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

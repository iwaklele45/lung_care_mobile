import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';

/// A circular avatar that shows the user's profile picture.
///
/// Priority order:
/// 1. Firestore `profilePictureUrl` (uploaded via profile page)
/// 2. Firebase Auth `photoURL` (e.g. Google account photo)
/// 3. Fallback person icon
///
/// Use this widget anywhere you need to display the user's avatar
/// (hamburger menu, motivation banner, etc.).
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.radius = 28});

  /// Radius of the CircleAvatar.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _fallback();

    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: doc.get(),
      builder: (context, snapshot) {
        String? imageUrl;

        // 1. Try Firestore profilePictureUrl
        if (snapshot.hasData && snapshot.data?.data() != null) {
          final data = snapshot.data!.data()!;
          final firestoreUrl = data['profilePictureUrl'] as String?;
          if (firestoreUrl != null && firestoreUrl.isNotEmpty) {
            imageUrl = firestoreUrl;
          }
        }

        // 2. Fallback to Firebase Auth photoURL
        imageUrl ??= user.photoURL;

        if (imageUrl != null && imageUrl.isNotEmpty) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.ternary,
            backgroundImage: NetworkImage(imageUrl),
          );
        }

        return _fallback();
      },
    );
  }

  Widget _fallback() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.ternary,
      child: Icon(
        Icons.person_rounded,
        size: radius * 1.1,
        color: AppColors.primary,
      ),
    );
  }
}

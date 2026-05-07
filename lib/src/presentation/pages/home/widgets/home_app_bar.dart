import 'package:flutter/material.dart';
import 'package:lung_care_mobile/gen/assets.gen.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key, required this.userName});

  final String userName;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appbarColor,
      elevation: 1,
      centerTitle: true,
      leading: IconButton(
        icon: Assets.icons.hamburgerIcon.image(),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: const Text(
        'LungCare+',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}

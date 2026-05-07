import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/gen/assets.gen.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';

class HamburgerMenu extends StatefulWidget {
  const HamburgerMenu({super.key, this.userName = 'Jane'});

  final String userName;

  @override
  State<HamburgerMenu> createState() => _HamburgerMenuState();
}

class _HamburgerMenuState extends State<HamburgerMenu> {
  int _selectedIndex = 0;

  static const _menuItems = [
    _MenuItem(label: 'Dashboard', icon: Icons.dashboard_rounded),
    _MenuItem(label: 'Riwayat Pengobatan', icon: Icons.calendar_today_rounded),
    _MenuItem(label: 'Chatbot Edukasi TBC', icon: Icons.smart_toy_outlined),
    _MenuItem(label: 'Fasilitas Kesehatan', icon: Icons.location_on_outlined),
  ];

  void _onItemTap(int index) {
    setState(() => _selectedIndex = index);

    // TODO(Week4): Replace with proper GoRouter navigation per item.
    Navigator.of(context).pop(); // close drawer

    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        // context.push('/history');
        break;
      case 2:
        // context.push('/chatbot');
        break;
      case 3:
        // context.push('/facilities');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),

            // ── User profile row ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Avatar circle
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: ClipOval(
                      child: Assets.icons.profileMotivationImg.image(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Name
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Divider ───────────────────────────────────────────
            Divider(
              color: AppColors.ternary,
              thickness: 1,
              indent: 24,
              endIndent: 24,
            ),

            const SizedBox(height: 8),

            // ── Navigation items ──────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  final isSelected = _selectedIndex == index;

                  return _DrawerTile(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => _onItemTap(index),
                  );
                },
              ),
            ),

            // ── Logout at bottom ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: _DrawerTile(
                item: const _MenuItem(
                  label: 'Keluar',
                  icon: Icons.logout_rounded,
                ),
                isSelected: false,
                isDestructive: true,
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: trigger AuthSignOutRequested
                  context.go('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _MenuItem {
  const _MenuItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

// ── Drawer tile ───────────────────────────────────────────────────────────────

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.isDestructive = false,
  });

  final _MenuItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isDestructive
        ? Colors.redAccent
        : isSelected
        ? AppColors.primary
        : AppColors.nautral;

    final Color labelColor = isDestructive
        ? Colors.redAccent
        : isSelected
        ? AppColors.primary
        : AppColors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: isSelected ? AppColors.ternary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(item.icon, size: 22, color: iconColor),
                const SizedBox(width: 14),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: labelColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lung_care_mobile/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:lung_care_mobile/gen/assets.gen.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/presentation/bloc/auth/auth_bloc.dart';

class HamburgerMenu extends StatefulWidget {
  const HamburgerMenu({super.key, this.selectedIndex = 0});

  final int selectedIndex;

  @override
  State<HamburgerMenu> createState() => _HamburgerMenuState();
}

class _HamburgerMenuState extends State<HamburgerMenu> {
  late int _selectedIndex = widget.selectedIndex;

  List<_MenuItem> _menuItems(AppLocalizations l) => [
    _MenuItem(label: l.dashboard, icon: Icons.dashboard_rounded),
    _MenuItem(label: l.medicationHistory, icon: Icons.calendar_today_rounded),
    _MenuItem(label: l.tbEducationChatbot, icon: Icons.smart_toy_outlined),
    _MenuItem(label: l.healthFacilities, icon: Icons.location_on_outlined),
  ];

  void _onItemTap(int index) {
    setState(() => _selectedIndex = index);

    Navigator.of(context).pop(); // close drawer

    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.push('/history');
      case 2:
        context.push('/chatbot');
      case 3:
        context.push('/facilities');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final items = _menuItems(l);

    // Ambil nama user dari Firebase Auth (fallback ke 'User')
    final currentUser = FirebaseAuth.instance.currentUser;
    final displayName = currentUser?.displayName?.isNotEmpty == true
        ? currentUser!.displayName!
        : currentUser?.email?.split('@').first ?? 'User';

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
                    displayName,
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
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
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
                item: _MenuItem(
                  label: l.logout,
                  icon: Icons.logout_rounded,
                ),
                isSelected: false,
                isDestructive: true,
                onTap: () {
                  Navigator.of(context).pop(); // close drawer first
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berhasil logout.')),
                  );
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

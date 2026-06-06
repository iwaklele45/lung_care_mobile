import 'package:flutter/material.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';

/// Detail page for a single health facility.
class FacilityDetailPage extends StatelessWidget {
  const FacilityDetailPage({
    super.key,
    required this.name,
    required this.type,
    required this.address,
  });

  final String name;
  final String type;
  final String address;

  @override
  Widget build(BuildContext context) {
    final isPuskesmas = type == 'Puskesmas';
    return Scaffold(
      backgroundColor: AppColors.bodyColor,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(name: name, type: type, isPuskesmas: isPuskesmas),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TbcServiceCard(),
                const SizedBox(height: 22),
                const _SectionLabel('LOKASI'),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: AppColors.nautral,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: const [
                              Icon(
                                Icons.directions_walk,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '1.2 km dari lokasi Anda',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32, color: Color(0xFFE8EEF6)),
                const _SectionLabel('KONTAK'),
                const SizedBox(height: 10),
                const _ContactCard(),
                const SizedBox(height: 22),
                const _SectionLabel('JAM OPERASIONAL'),
                const SizedBox(height: 10),
                const _HoursCard(),
                const SizedBox(height: 28),
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B9BE8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.navigation, size: 20),
                    label: const Text(
                      'Lihat Di Google Map',
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
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.type,
    required this.isPuskesmas,
  });

  final String name;
  final String type;
  final bool isPuskesmas;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 280,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8FB7DC), Color(0xFF5B7A93)],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.45),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                // _CircleButton(icon: Icons.share_outlined, onTap: () {}),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPuskesmas
                          ? Icons.local_hospital_outlined
                          : Icons.business_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: const [
                  Icon(Icons.star, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    '4.8 (124 Ulasan)',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.black),
      ),
    );
  }
}

class _TbcServiceCard extends StatelessWidget {
  const _TbcServiceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ternary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.healing,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Layanan TBC Tersedia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Fasilitas ini menyediakan tes dahak (TCM) dan pengobatan '
                  'OAT gratis sesuai program pemerintah.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.nautral,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EEF6)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.ternary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.phone, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Telepon Klinik',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  '(021) 31930108',
                  style: TextStyle(fontSize: 13, color: AppColors.nautral),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.nautral),
        ],
      ),
    );
  }
}

class _HoursCard extends StatelessWidget {
  const _HoursCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EEF6)),
      ),
      child: Column(
        children: const [
          _HoursRow(day: 'Senin - Jumat', time: '08:00 - 15:00'),
          SizedBox(height: 8),
          _HoursRow(day: 'Sabtu', time: '08:00 - 12:00'),
        ],
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  const _HoursRow({required this.day, required this.time});

  final String day;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: const TextStyle(fontSize: 14, color: AppColors.black)),
        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w600,
        color: AppColors.nautral,
      ),
    );
  }
}

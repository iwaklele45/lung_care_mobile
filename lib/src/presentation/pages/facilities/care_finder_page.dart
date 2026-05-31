import 'package:flutter/material.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/presentation/pages/facilities/facility_detail_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/hamburger/hamburger_menu.dart';

class _Facility {
  const _Facility({
    required this.type,
    required this.name,
    required this.address,
    required this.hours,
  });

  final String type; // 'Puskesmas' | 'Rumah Sakit'
  final String name;
  final String address;
  final String hours;
}

/// "CareFinder": list of nearby health facilities.
class CareFinderPage extends StatelessWidget {
  const CareFinderPage({super.key});

  static const _facilities = [
    _Facility(
      type: 'Puskesmas',
      name: 'Puskesmas Mulyorejo',
      address: 'Jl. Mulyorejo No.1, Surabaya Timur',
      hours: 'Buka - Tutup jam 14:00',
    ),
    _Facility(
      type: 'Rumah Sakit',
      name: 'RSUD Dr. Soetomo',
      address: 'Jl. Mayjen Prof. Dr. Moestopo No.6-8, Surabaya',
      hours: 'Buka 24 Jam',
    ),
    _Facility(
      type: 'Puskesmas',
      name: 'Puskesmas Sukolilo',
      address: 'Jl. Sukolilo Lor No.2, Surabaya Timur',
      hours: 'Buka - Tutup jam 15:00',
    ),
    _Facility(
      type: 'Rumah Sakit',
      name: 'RS Universitas Airlangga',
      address: 'Kampus C Unair, Mulyorejo, Surabaya',
      hours: 'Buka 24 Jam',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyColor,
      drawer: const HamburgerMenu(selectedIndex: 3),
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        elevation: 1,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
            SizedBox(width: 6),
            Text(
              'CareFinder',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          const Text(
            'Fasilitas Kesehatan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Daftar klinik dan rumah sakit di sekitar Anda.',
            style: TextStyle(fontSize: 14, color: AppColors.nautral),
          ),
          const SizedBox(height: 18),
          ..._facilities.map((f) => _FacilityCard(facility: f)),
        ],
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({required this.facility});

  final _Facility facility;

  @override
  Widget build(BuildContext context) {
    final isPuskesmas = facility.type == 'Puskesmas';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isPuskesmas
                      ? AppColors.ternary
                      : const Color(0xFFFADCDC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  facility.type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPuskesmas
                        ? AppColors.primary
                        : const Color(0xFFD05A5A),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    facility.hours,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            facility.name,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.nautral),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  facility.address,
                  style: const TextStyle(fontSize: 13, color: AppColors.nautral),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE8EEF6)),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FacilityDetailPage(
                    name: facility.name,
                    type: facility.type,
                    address: facility.address,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9BE8),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.navigation_outlined, size: 16),
              label: const Text(
                'Directions',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

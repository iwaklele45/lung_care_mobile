import 'package:flutter/material.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/data/models/facility.dart';
import 'package:lung_care_mobile/src/presentation/pages/facilities/facility_detail_page.dart';
import 'package:lung_care_mobile/src/presentation/pages/hamburger/hamburger_menu.dart';

/// "CareFinder": list of nearby health facilities in Surabaya.
class CareFinderPage extends StatefulWidget {
  const CareFinderPage({super.key});

  @override
  State<CareFinderPage> createState() => _CareFinderPageState();
}

class _CareFinderPageState extends State<CareFinderPage> {
  /// Current filter: null = all, 'Rumah Sakit' or 'Puskesmas'
  String? _selectedFilter;

  /// Curated list of real healthcare facilities in Surabaya.
  /// Data sourced from Wikipedia & Dinkes Surabaya.
  static const List<Facility> _allFacilities = [
    // ─── RUMAH SAKIT ───
    Facility(
      type: 'Rumah Sakit',
      name: 'RSUD Dr. Soetomo',
      address: 'Jl. Mayjen Prof. Dr. Moestopo No.6-8, Airlangga, Gubeng, Surabaya',
      phone: '(031) 5501000',
      hours: 'Buka 24 Jam',
      hoursWeekday: '24 Jam',
      hoursWeekend: '24 Jam',
      rating: 4.7,
      reviewCount: 520,
      distance: 2.5,
      hasTbcService: true,
      coverImageUrl: 'https://images.unsplash.com/photo-1587351021759-3772687fe598?w=600&h=400&fit=crop',
    ),
    Facility(
      type: 'Rumah Sakit',
      name: 'RSUD Dr. Mohamad Soewandhie',
      address: 'Jl. Tambak Rejo No.45, Tambakrejo, Simokerto, Surabaya',
      phone: '(031) 3710525',
      hours: 'Buka 24 Jam',
      hoursWeekday: '24 Jam',
      hoursWeekend: '24 Jam',
      rating: 4.4,
      reviewCount: 210,
      distance: 4.1,
      hasTbcService: true,
      coverImageUrl: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=600&h=400&fit=crop',
    ),
    Facility(
      type: 'Rumah Sakit',
      name: 'RSAL Dr. Ramelan',
      address: 'Jl. Gadung No.1, Jagir, Wonokromo, Surabaya',
      phone: '(031) 8414100',
      hours: 'Buka 24 Jam',
      hoursWeekday: '24 Jam',
      hoursWeekend: '24 Jam',
      rating: 4.6,
      reviewCount: 340,
      distance: 3.8,
      hasTbcService: true,
      coverImageUrl: 'https://images.unsplash.com/photo-1551076805-e1869033e561?w=600&h=400&fit=crop',
    ),
    Facility(
      type: 'Rumah Sakit',
      name: 'RS Universitas Airlangga',
      address: 'Jl. Dharma Husada Permai No.16, Mulyorejo, Surabaya',
      phone: '(031) 5916421',
      hours: 'Buka 24 Jam',
      hoursWeekday: '24 Jam',
      hoursWeekend: '24 Jam',
      rating: 4.5,
      reviewCount: 185,
      distance: 5.2,
      hasTbcService: true,
      coverImageUrl: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=600&h=400&fit=crop',
    ),
    Facility(
      type: 'Rumah Sakit',
      name: 'RS Siloam Surabaya',
      address: 'Jl. Raya Gubeng No.70, Gubeng, Surabaya',
      phone: '(031) 5005151',
      hours: 'Buka 24 Jam',
      hoursWeekday: '24 Jam',
      hoursWeekend: '24 Jam',
      rating: 4.8,
      reviewCount: 410,
      distance: 1.8,
      hasTbcService: true,
      coverImageUrl: 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=600&h=400&fit=crop',
    ),
    Facility(
      type: 'Rumah Sakit',
      name: 'RS Haji Surabaya',
      address: 'Jl. Manyar Kertoadi No.13, Klampisngasem, Sukolilo, Surabaya',
      phone: '(031) 5942475',
      hours: 'Buka 24 Jam',
      hoursWeekday: '24 Jam',
      hoursWeekend: '24 Jam',
      rating: 4.3,
      reviewCount: 95,
      distance: 6.0,
      hasTbcService: true,
      coverImageUrl: 'https://images.unsplash.com/photo-1584515933487-779824d29309?w=600&h=400&fit=crop',
    ),
    Facility(
      type: 'Rumah Sakit',
      name: 'RS Premier Surabaya',
      address: 'Jl. Nginden Intan Barat No.9, Nginden Jangkungan, Sukolilo, Surabaya',
      phone: '(031) 5924500',
      hours: 'Buka 24 Jam',
      hoursWeekday: '24 Jam',
      hoursWeekend: '24 Jam',
      rating: 4.7,
      reviewCount: 280,
      distance: 7.5,
      hasTbcService: false,
      coverImageUrl: 'https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=600&h=400&fit=crop',
    ),
    Facility(
      type: 'Rumah Sakit',
      name: 'RS Islam Surabaya Jemursari',
      address: 'Jl. Raya Jemursari No.51, Jemur Wonosari, Wonocolo, Surabaya',
      phone: '(031) 8477000',
      hours: 'Buka 24 Jam',
      hoursWeekday: '24 Jam',
      hoursWeekend: '24 Jam',
      rating: 4.5,
      reviewCount: 160,
      distance: 6.8,
      hasTbcService: true,
      coverImageUrl: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=600&h=400&fit=crop',
    ),
    Facility(
      type: 'Rumah Sakit',
      name: 'RS Bhayangkara Samsoeri Mertoyoso',
      address: 'Jl. Ahmad Yani No.116, Ketintang, Gayungan, Surabaya',
      phone: '(031) 8290870',
      hours: 'Buka 24 Jam',
      hoursWeekday: '24 Jam',
      hoursWeekend: '24 Jam',
      rating: 4.4,
      reviewCount: 130,
      distance: 4.5,
      hasTbcService: true,
      coverImageUrl: 'https://images.unsplash.com/photo-1579154204601-01588f6f1a1c?w=600&h=400&fit=crop',
    ),
    Facility(
      type: 'Rumah Sakit',
      name: 'RS Paru Surabaya',
      address: 'Jl. Karang Tembok No.39, Pegirian, Semampir, Surabaya',
      phone: '(031) 3522446',
      hours: 'Buka 24 Jam',
      hoursWeekday: '24 Jam',
      hoursWeekend: '24 Jam',
      rating: 4.2,
      reviewCount: 75,
      distance: 3.2,
      hasTbcService: true,
      coverImageUrl: 'https://images.unsplash.com/photo-1587351021759-3772687fe598?w=600&h=400&fit=crop',
    ),

    // ─── PUSKESMAS ───
    Facility(
      type: 'Puskesmas',
      name: 'Puskesmas Mulyorejo',
      address: 'Jl. Mulyorejo No.1, Mulyorejo, Surabaya',
      phone: '(031) 5942635',
      hours: 'Buka - Tutup jam 14:00',
      hoursWeekday: '08:00 - 14:00',
      hoursWeekend: null,
      rating: 4.3,
      reviewCount: 88,
      distance: 5.5,
      hasTbcService: true,
    ),
    Facility(
      type: 'Puskesmas',
      name: 'Puskesmas Sukolilo',
      address: 'Jl. Sukolilo Lor No.2, Sukolilo, Surabaya',
      phone: '(031) 5946420',
      hours: 'Buka - Tutup jam 15:00',
      hoursWeekday: '08:00 - 15:00',
      hoursWeekend: null,
      rating: 4.1,
      reviewCount: 62,
      distance: 6.2,
      hasTbcService: true,
    ),
    Facility(
      type: 'Puskesmas',
      name: 'Puskesmas Kedurus',
      address: 'Jl. Kedurus No.30, Kedurus, Karangpilang, Surabaya',
      phone: '(031) 7662105',
      hours: 'Buka - Tutup jam 15:00',
      hoursWeekday: '08:00 - 15:00',
      hoursWeekend: null,
      rating: 4.0,
      reviewCount: 45,
      distance: 4.8,
      hasTbcService: true,
    ),
    Facility(
      type: 'Puskesmas',
      name: 'Puskesmas Tambakrejo',
      address: 'Jl. Tambak Rejo No.1, Tambakrejo, Simokerto, Surabaya',
      phone: '(031) 3713309',
      hours: 'Buka - Tutup jam 14:00',
      hoursWeekday: '08:00 - 14:00',
      hoursWeekend: null,
      rating: 4.2,
      reviewCount: 53,
      distance: 3.5,
      hasTbcService: true,
    ),
    Facility(
      type: 'Puskesmas',
      name: 'Puskesmas Jagir',
      address: 'Jl. Jagir Sidomukti No.1, Jagir, Wonokromo, Surabaya',
      phone: '(031) 8413357',
      hours: 'Buka - Tutup jam 14:00',
      hoursWeekday: '08:00 - 14:00',
      hoursWeekend: null,
      rating: 4.3,
      reviewCount: 71,
      distance: 3.0,
      hasTbcService: true,
    ),
    Facility(
      type: 'Puskesmas',
      name: 'Puskesmas Ketabang',
      address: 'Jl. Ketabang Kali No.5, Ketabang, Genteng, Surabaya',
      phone: '(031) 5341090',
      hours: 'Buka - Tutup jam 14:00',
      hoursWeekday: '08:00 - 14:00',
      hoursWeekend: null,
      rating: 4.4,
      reviewCount: 58,
      distance: 1.2,
      hasTbcService: true,
    ),
    Facility(
      type: 'Puskesmas',
      name: 'Puskesmas Balongsari',
      address: 'Jl. Balongsari No.1, Balongsari, Tandes, Surabaya',
      phone: '(031) 7401159',
      hours: 'Buka - Tutup jam 15:00',
      hoursWeekday: '08:00 - 15:00',
      hoursWeekend: null,
      rating: 4.1,
      reviewCount: 39,
      distance: 8.0,
      hasTbcService: true,
    ),
    Facility(
      type: 'Puskesmas',
      name: 'Puskesmas Gunung Anyar',
      address: 'Jl. Gunung Anyar Lor No.1, Gunung Anyar, Surabaya',
      phone: '(031) 3812505',
      hours: 'Buka - Tutup jam 14:00',
      hoursWeekday: '08:00 - 14:00',
      hoursWeekend: null,
      rating: 4.0,
      reviewCount: 35,
      distance: 9.5,
      hasTbcService: true,
    ),
  ];

  List<Facility> get _filteredFacilities {
    if (_selectedFilter == null) return _allFacilities;
    return _allFacilities.where((f) => f.type == _selectedFilter).toList();
  }

  int get _totalCount => _allFacilities.length;
  int get _rsCount => _allFacilities.where((f) => f.type == 'Rumah Sakit').length;
  int get _puskesmasCount => _allFacilities.where((f) => f.type == 'Puskesmas').length;

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredFacilities;

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
            'Daftar puskesmas dan rumah sakit di Surabaya.',
            style: TextStyle(fontSize: 14, color: AppColors.nautral),
          ),
          const SizedBox(height: 18),
          // Type filter chips — tappable now!
          _FilterRow(
            selectedFilter: _selectedFilter,
            totalCount: _totalCount,
            rsCount: _rsCount,
            puskesmasCount: _puskesmasCount,
            onFilter: (filter) {
              setState(() => _selectedFilter = filter);
            },
          ),
          const SizedBox(height: 12),
          // Results count
          Text(
            '${filtered.length} fasilitas${_selectedFilter != null ? ' ${_selectedFilter!.toLowerCase()}' : ''}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.nautral,
            ),
          ),
          const SizedBox(height: 14),
          ...filtered.map((f) => FacilityCard(facility: f)),
        ],
      ),
    );
  }
}

/// Filter chips for Semua / Rumah Sakit / Puskesmas
class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selectedFilter,
    required this.totalCount,
    required this.rsCount,
    required this.puskesmasCount,
    required this.onFilter,
  });

  final String? selectedFilter;
  final int totalCount;
  final int rsCount;
  final int puskesmasCount;
  final void Function(String?) onFilter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'Semua ($totalCount)',
            selected: selectedFilter == null,
            onTap: () => onFilter(null),
          ),
          const SizedBox(width: 10),
          _Chip(
            label: 'Rumah Sakit ($rsCount)',
            selected: selectedFilter == 'Rumah Sakit',
            onTap: () => onFilter('Rumah Sakit'),
          ),
          const SizedBox(width: 10),
          _Chip(
            label: 'Puskesmas ($puskesmasCount)',
            selected: selectedFilter == 'Puskesmas',
            onTap: () => onFilter('Puskesmas'),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFD8E2F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.nautral,
          ),
        ),
      ),
    );
  }
}

class FacilityCard extends StatelessWidget {
  const FacilityCard({required this.facility});

  final Facility facility;

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
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 4),
              Text(
                '${facility.rating}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              Text(
                ' (${facility.reviewCount} ulasan)',
                style: const TextStyle(fontSize: 12, color: AppColors.nautral),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFE8EEF6)),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FacilityDetailPage(facility: facility),
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

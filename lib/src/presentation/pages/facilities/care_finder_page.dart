import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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
  /// Current filter: null = all, or a specific type string.
  String? _selectedFilter;

  /// All facilities loaded from JSON asset.
  List<Facility> _allFacilities = [];

  /// Whether data is still loading.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    final jsonString =
        await rootBundle.loadString('assets/data/hospitals.json');
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

    final facilities = jsonList
        .map((e) => Facility.fromJson(e as Map<String, dynamic>))
        .toList();

    if (mounted) {
      setState(() {
        _allFacilities = facilities;
        _isLoading = false;
      });
    }
  }

  List<Facility> get _filteredFacilities {
    if (_selectedFilter == null) return _allFacilities;
    return _allFacilities.where((f) => f.type == _selectedFilter).toList();
  }

  /// Get unique type values and their counts for filter chips.
  Map<String, int> get _typeCounts {
    final counts = <String, int>{};
    for (final f in _allFacilities) {
      counts[f.type] = (counts[f.type] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredFacilities;
    final typeCounts = _typeCounts;

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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : ListView(
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
                Text(
                  'Daftar ${_allFacilities.length} rumah sakit di Surabaya.',
                  style:
                      const TextStyle(fontSize: 14, color: AppColors.nautral),
                ),
                const SizedBox(height: 18),
                // Type filter chips — scrollable
                _FilterRow(
                  selectedFilter: _selectedFilter,
                  totalCount: _allFacilities.length,
                  typeCounts: typeCounts,
                  onFilter: (filter) {
                    setState(() => _selectedFilter = filter);
                  },
                ),
                const SizedBox(height: 12),
                // Results count
                Text(
                  '${filtered.length} fasilitas${_selectedFilter != null ? ' ($_selectedFilter)' : ''}',
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

/// Filter chips for all types + Semua
class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selectedFilter,
    required this.totalCount,
    required this.typeCounts,
    required this.onFilter,
  });

  final String? selectedFilter;
  final int totalCount;
  final Map<String, int> typeCounts;
  final void Function(String?) onFilter;

  @override
  Widget build(BuildContext context) {
    // Sort types so the most common ones appear first
    final sortedTypes = typeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
          ...sortedTypes.map((entry) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _Chip(
                  label: '${entry.key} (${entry.value})',
                  selected: selectedFilter == entry.key,
                  onTap: () => onFilter(entry.key),
                ),
              )),
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
  const FacilityCard({super.key, required this.facility});

  final Facility facility;

  @override
  Widget build(BuildContext context) {
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
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFADCDC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    facility.type,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD05A5A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 14, color: AppColors.primary),
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
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.nautral),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  facility.address,
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.nautral),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Rating & review count
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF5C842)),
              const SizedBox(width: 4),
              Text(
                '${facility.rating}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${facility.reviewCount} ulasan)',
                style:
                    const TextStyle(fontSize: 12, color: AppColors.nautral),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.navigation_outlined, size: 16),
              label: const Text(
                'Detail',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

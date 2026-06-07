import 'package:flutter/material.dart';
import 'package:lung_care_mobile/src/core/theme/app_colors.dart';
import 'package:lung_care_mobile/src/data/models/facility.dart';
import 'package:url_launcher/url_launcher.dart';

/// Detail page for a single health facility in Surabaya.
class FacilityDetailPage extends StatelessWidget {
  const FacilityDetailPage({super.key, required this.facility});

  final Facility facility;

  String get _googleMapsUrl =>
      facility.googleMapsUrl ??
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeQueryComponent(facility.address)}';

  Future<void> _openGoogleMaps(BuildContext context) async {
    try {
      final uri = Uri.parse(_googleMapsUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPuskesmas = facility.type == 'Puskesmas';
    final is24h = facility.hours == 'Buka 24 Jam';

    return Scaffold(
      backgroundColor: AppColors.bodyColor,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(facility: facility, isPuskesmas: isPuskesmas),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating & reviews
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 20, color: Color(0xFFF5C842)),
                    const SizedBox(width: 4),
                    Text(
                      '${facility.rating}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${facility.reviewCount} ulasan)',
                      style: const TextStyle(fontSize: 14, color: AppColors.nautral),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (facility.hasTbcService) ...[
                  const _TbcServiceCard(),
                  const SizedBox(height: 22),
                ],
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
                            facility.address,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32, color: Color(0xFFE8EEF6)),
                const _SectionLabel('KONTAK'),
                const SizedBox(height: 10),
                _ContactCard(phone: facility.phone),
                if (facility.website != null && facility.website!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _WebsiteCard(url: facility.website!),
                ],
                const SizedBox(height: 22),
                const _SectionLabel('JAM OPERASIONAL'),
                const SizedBox(height: 10),
                _HoursCard(
                  is24h: is24h,
                  weekday: facility.hoursWeekday,
                  weekend: facility.hoursWeekend,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => _openGoogleMaps(context),
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
  const _Header({required this.facility, required this.isPuskesmas});

  final Facility facility;
  final bool isPuskesmas;

  /// Default gradient when no cover image is available.
  static const _defaultGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF8FB7DC), Color(0xFF5B7A93)],
  );

  @override
  Widget build(BuildContext context) {
    final hasCover = facility.coverImageUrl != null &&
        facility.coverImageUrl!.isNotEmpty;

    return Stack(
      children: [
        // Background: cover image or gradient
        if (hasCover)
          SizedBox(
            height: 280,
            child: Image.network(
              facility.coverImageUrl!,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _gradientContainer(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _gradientContainer(
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                    ),
                  ),
                );
              },
            ),
          )
        else
          _gradientContainer(),

        // Dark overlay for text readability on cover image
        if (hasCover)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),

        // Back button
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
              ],
            ),
          ),
        ),

        // Facility info overlay at bottom
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
                      facility.type,
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
                facility.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _gradientContainer({Widget? child}) {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        gradient: _defaultGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: child,
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
  const _ContactCard({required this.phone});

  final String phone;

  Future<void> _callPhone(BuildContext context) async {
    // Clean the phone number: remove spaces, dashes, etc.
    final cleaned = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    if (cleaned == '-' || cleaned.isEmpty) return;
    try {
      final uri = Uri.parse('tel:$cleaned');
      await launchUrl(uri);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka telepon')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _callPhone(context),
      child: Container(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Telepon',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    phone,
                    style: const TextStyle(fontSize: 13, color: AppColors.nautral),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.nautral),
          ],
        ),
      ),
    );
  }
}

class _WebsiteCard extends StatelessWidget {
  const _WebsiteCard({required this.url});

  final String url;

  String get _displayUrl {
    var display = url
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .replaceAll('www.', '');
    if (display.endsWith('/')) display = display.substring(0, display.length - 1);
    // Truncate long URLs
    if (display.length > 35) display = '${display.substring(0, 35)}...';
    return display;
  }

  Future<void> _openWebsite(BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka website')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openWebsite(context),
      child: Container(
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
              child: const Icon(Icons.language, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Website',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    _displayUrl,
                    style: const TextStyle(fontSize: 13, color: AppColors.nautral),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.nautral),
          ],
        ),
      ),
    );
  }
}

class _HoursCard extends StatelessWidget {
  const _HoursCard({
    required this.is24h,
    required this.weekday,
    required this.weekend,
  });

  final bool is24h;
  final String weekday;
  final String? weekend;

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
        children: [
          if (is24h) ...[
            const _HoursRow(day: 'Setiap Hari', time: '24 Jam'),
          ] else ...[
            _HoursRow(day: 'Senin - Jumat', time: weekday),
            if (weekend != null) ...[
              const SizedBox(height: 8),
              _HoursRow(day: 'Sabtu', time: weekend!),
            ],
            const SizedBox(height: 8),
            const _HoursRow(day: 'Minggu & Libur', time: 'Tutup'),
          ],
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

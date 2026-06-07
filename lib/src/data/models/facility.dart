/// A health facility in Surabaya displayed on the CareFinder page.
class Facility {
  const Facility({
    required this.type,
    required this.name,
    required this.address,
    required this.phone,
    required this.hours,
    required this.hoursWeekday,
    this.hoursWeekend,
    this.rating = 4.5,
    this.reviewCount = 100,
    this.distance = 1.0,
    this.hasTbcService = true,
    this.coverImageUrl,
    this.googleMapsUrl,
    this.website,
    this.primaryCategory,
  });

  /// Create a Facility from a JSON map (loaded from hospitals.json asset).
  factory Facility.fromJson(Map<String, dynamic> json) {
    final primaryCat = json['primaryCategory'] as String? ?? '';
    final facilityType = json['type'] as String? ?? 'general';

    // Determine display type based on the type field from JSON
    String displayType;
    switch (facilityType) {
      case 'government':
        displayType = 'RS Pemerintah';
        break;
      case 'military':
        displayType = 'RS Militer';
        break;
      case 'private':
        displayType = 'RS Swasta';
        break;
      case 'private_religious':
        displayType = 'RS Swasta';
        break;
      case 'maternity_children':
        displayType = 'RS Ibu & Anak';
        break;
      case 'psychiatric':
        displayType = 'RS Jiwa';
        break;
      case 'eye':
        displayType = 'RS/Klinik Mata';
        break;
      case 'specialist':
        displayType = 'RS Spesialis';
        break;
      case 'university':
        displayType = 'RS Universitas';
        break;
      default:
        displayType = 'Rumah Sakit';
    }

    // Determine if TB services are likely available
    // Government hospitals, military hospitals, and large general hospitals
    // typically have DOTS TB programs
    final hasTbc = facilityType == 'government' ||
        facilityType == 'military' ||
        facilityType == 'general' ||
        facilityType == 'private' ||
        facilityType == 'private_religious';

    // Determine operating hours based on hospital type
    // Most hospitals in Indonesia are 24h for IGD, polyclinics vary
    String hours;
    String hoursWeekday;
    String? hoursWeekend;

    if (facilityType == 'eye') {
      hours = 'Senin-Sabtu';
      hoursWeekday = '08:00 - 17:00';
      hoursWeekend = '08:00 - 13:00';
    } else {
      // Most RS in Surabaya have 24h IGD
      hours = 'Buka 24 Jam';
      hoursWeekday = '24 Jam';
      hoursWeekend = '24 Jam';
    }

    // Build cover image URL from the hospital website using a high-quality
    // stock image as fallback. We cycle through themed images based on type.
    final website = json['website'] as String? ?? '';
    String? coverImage;
    switch (facilityType) {
      case 'government':
        coverImage =
            'https://images.unsplash.com/photo-1587351021759-3772687fe598?w=600&h=400&fit=crop';
        break;
      case 'military':
        coverImage =
            'https://images.unsplash.com/photo-1551076805-e1869033e561?w=600&h=400&fit=crop';
        break;
      case 'private':
      case 'private_religious':
        coverImage =
            'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=600&h=400&fit=crop';
        break;
      case 'maternity_children':
        coverImage =
            'https://images.unsplash.com/photo-1584515933487-779824d29309?w=600&h=400&fit=crop';
        break;
      case 'eye':
        coverImage =
            'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=600&h=400&fit=crop';
        break;
      case 'specialist':
        coverImage =
            'https://images.unsplash.com/photo-1538108149393-fbbd81895907?w=600&h=400&fit=crop';
        break;
      case 'university':
        coverImage =
            'https://images.unsplash.com/photo-1551601651-2a8555f1a29f?w=600&h=400&fit=crop';
        break;
      default:
        coverImage =
            'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=600&h=400&fit=crop';
    }

    return Facility(
      type: displayType,
      name: json['name'] as String? ?? '',
      address:
          '${json['address'] as String? ?? ''}, ${json['city'] as String? ?? ''}',
      phone: json['phone'] as String? ?? '-',
      hours: hours,
      hoursWeekday: hoursWeekday,
      hoursWeekend: hoursWeekend,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      hasTbcService: hasTbc,
      coverImageUrl: coverImage,
      googleMapsUrl: json['googleMapsUrl'] as String?,
      website: website.isNotEmpty ? website : null,
      primaryCategory: primaryCat.isNotEmpty ? primaryCat : null,
    );
  }

  /// 'Rumah Sakit' | 'Puskesmas' | 'RS Pemerintah' | 'RS Swasta' etc.
  final String type;
  final String name;
  final String address;
  final String phone;

  /// Summary for card display (e.g. 'Buka 24 Jam')
  final String hours;
  final String hoursWeekday;

  /// e.g. '08:00 - 12:00' or null if closed on weekends
  final String? hoursWeekend;
  final double rating;
  final int reviewCount;

  /// Estimated distance in km
  final double distance;
  final bool hasTbcService;

  /// Cover photo URL for the detail page header.
  final String? coverImageUrl;

  /// Direct Google Maps URL with place_id for precise navigation.
  final String? googleMapsUrl;

  /// Hospital official website URL.
  final String? website;

  /// Primary category from Google Places (e.g. 'Rumah Sakit Umum').
  final String? primaryCategory;
}

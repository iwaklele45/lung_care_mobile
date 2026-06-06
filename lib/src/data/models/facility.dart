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
  });

  /// 'Puskesmas' | 'Rumah Sakit'
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

  /// Cover photo URL for the detail page header (Unsplash or similar).
  final String? coverImageUrl;
}

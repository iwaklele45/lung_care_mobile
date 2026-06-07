import 'package:flutter_test/flutter_test.dart';
import 'package:lung_care_mobile/src/data/models/facility.dart';

void main() {
  group('Facility', () {
    group('fromJson', () {
      test('creates facility from government hospital JSON', () {
        final json = {
          'type': 'government',
          'name': 'RSUD Dr. Soetomo',
          'address': 'Jl. Mayjen Prof. Dr. Moestopo 6-8',
          'city': 'Surabaya',
          'phone': '031-5501078',
          'rating': 4.5,
          'reviewCount': 500,
          'website': 'https://rsudsoetomo.surabaya.go.id',
          'primaryCategory': 'Rumah Sakit Umum',
        };

        final facility = Facility.fromJson(json);

        expect(facility.type, 'RS Pemerintah');
        expect(facility.name, 'RSUD Dr. Soetomo');
        expect(facility.address, contains('Surabaya'));
        expect(facility.phone, '031-5501078');
        expect(facility.hours, 'Buka 24 Jam');
        expect(facility.hoursWeekday, '24 Jam');
        expect(facility.hoursWeekend, '24 Jam');
        expect(facility.rating, 4.5);
        expect(facility.reviewCount, 500);
        expect(facility.hasTbcService, true);
        expect(facility.coverImageUrl, isNotNull);
        expect(facility.website, 'https://rsudsoetomo.surabaya.go.id');
        expect(facility.primaryCategory, 'Rumah Sakit Umum');
      });

      test('creates facility from private hospital JSON', () {
        final json = {
          'type': 'private',
          'name': 'RS Siloam',
          'address': 'Jl. Gubeng Kuantan',
          'city': 'Surabaya',
          'phone': '031-9910888',
          'rating': 4.7,
        };

        final facility = Facility.fromJson(json);

        expect(facility.type, 'RS Swasta');
        expect(facility.hasTbcService, true);
      });

      test('creates facility from eye hospital JSON', () {
        final json = {
          'type': 'eye',
          'name': 'RS Mata undang',
          'address': 'Jl. Pandeglang',
          'city': 'Surabaya',
          'phone': '031-1234567',
          'rating': 4.3,
        };

        final facility = Facility.fromJson(json);

        expect(facility.type, 'RS/Klinik Mata');
        expect(facility.hours, 'Senin-Sabtu');
        expect(facility.hoursWeekday, '08:00 - 17:00');
        expect(facility.hoursWeekend, '08:00 - 13:00');
        expect(facility.hasTbcService, false);
      });

      test('creates facility from psychiatric hospital JSON', () {
        final json = {
          'type': 'psychiatric',
          'name': 'RS Jiwa Menur',
          'address': 'Jl. Menur',
          'city': 'Surabaya',
          'phone': '031-1234567',
          'rating': 4.2,
        };

        final facility = Facility.fromJson(json);

        expect(facility.type, 'RS Jiwa');
        expect(facility.hasTbcService, false);
      });

      test('creates facility from military hospital JSON', () {
        final json = {
          'type': 'military',
          'name': 'RS TK. IV Dr. Rivoesalam',
          'address': 'Jl. Taman Bukit Darmo',
          'city': 'Surabaya',
          'phone': '031-1234567',
          'rating': 4.4,
        };

        final facility = Facility.fromJson(json);

        expect(facility.type, 'RS Militer');
        expect(facility.hasTbcService, true);
      });

      test('creates facility from maternity hospital JSON', () {
        final json = {
          'type': 'maternity_children',
          'name': 'RS Ibu dan Anak',
          'address': 'Jl. Raya Darmo',
          'city': 'Surabaya',
          'phone': '031-1234567',
          'rating': 4.6,
        };

        final facility = Facility.fromJson(json);

        expect(facility.type, 'RS Ibu & Anak');
        expect(facility.hasTbcService, false);
      });

      test('creates facility from specialist hospital JSON', () {
        final json = {
          'type': 'specialist',
          'name': 'RS Jantung',
          'address': 'Jl. Diponegoro',
          'city': 'Surabaya',
          'phone': '031-1234567',
          'rating': 4.8,
        };

        final facility = Facility.fromJson(json);

        expect(facility.type, 'RS Spesialis');
        expect(facility.hasTbcService, false);
      });

      test('creates facility from university hospital JSON', () {
        final json = {
          'type': 'university',
          'name': 'RS Unair',
          'address': 'Jl. Mayjen Prof. Dr. Moestopo',
          'city': 'Surabaya',
          'phone': '031-1234567',
          'rating': 4.9,
        };

        final facility = Facility.fromJson(json);

        expect(facility.type, 'RS Universitas');
        expect(facility.hasTbcService, false);
      });

      test('creates facility from unknown type JSON', () {
        final json = {
          'type': 'unknown',
          'name': 'Unknown Hospital',
          'address': 'Jl. Unknown',
          'city': 'Surabaya',
          'phone': '031-1234567',
          'rating': 4.0,
        };

        final facility = Facility.fromJson(json);

        expect(facility.type, 'Rumah Sakit');
        expect(facility.hasTbcService, false);
      });

      test('uses default values for missing JSON fields', () {
        final json = <String, dynamic>{
          'name': 'Minimal Hospital',
        };

        final facility = Facility.fromJson(json);

        expect(facility.name, 'Minimal Hospital');
        expect(facility.address, ', ');
        expect(facility.phone, '-');
        expect(facility.rating, 4.5);
        expect(facility.reviewCount, 0);
        expect(facility.website, isNull);
        expect(facility.primaryCategory, isNull);
        expect(facility.googleMapsUrl, isNull);
      });

      test('combines address and city correctly', () {
        final json = {
          'name': 'Test Hospital',
          'address': 'Jl. Test No. 1',
          'city': 'Jakarta',
        };

        final facility = Facility.fromJson(json);

        expect(facility.address, 'Jl. Test No. 1, Jakarta');
      });

      test('returns null website when empty string', () {
        final json = {
          'name': 'Test Hospital',
          'website': '',
        };

        final facility = Facility.fromJson(json);

        expect(facility.website, isNull);
      });

      test('returns null primaryCategory when empty string', () {
        final json = {
          'name': 'Test Hospital',
          'primaryCategory': '',
        };

        final facility = Facility.fromJson(json);

        expect(facility.primaryCategory, isNull);
      });
    });
  });
}

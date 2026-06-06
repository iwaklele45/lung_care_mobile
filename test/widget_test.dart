// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:lung_care_mobile/main.dart';
import 'package:lung_care_mobile/src/core/locale/locale_provider.dart';

void main() {
  testWidgets('register page renders expected sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(localeProvider: LocaleProvider()));

    expect(find.text('Daftar Akun Baru'), findsOneWidget);
    expect(find.text('Mulai Perjalanan\nSehat'), findsOneWidget);
    expect(find.text('Buat Akun'), findsOneWidget);
    expect(find.text('Daftar dengan Google'), findsOneWidget);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:lung_care_mobile/main.dart';

void main() {
  testWidgets('register page renders expected sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Daftar Akun Baru'), findsOneWidget);
    expect(find.text('Mulai Perjalanan\nSehat'), findsOneWidget);
    expect(find.text('Buat Akun'), findsOneWidget);
    expect(find.text('Daftar dengan Google'), findsOneWidget);
  });
}

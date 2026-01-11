// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:faselunar/main.dart';

void main() {
  testWidgets('MoonApp shows loading state initially', (WidgetTester tester) async {
    await tester.pumpWidget(const MoonApp());

    // The app fetches lunar data on startup; before the Future completes,
    // a loading message should be visible.
    expect(find.text('Loading lunar data…'), findsOneWidget);
  });
}

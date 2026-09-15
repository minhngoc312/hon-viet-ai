import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viet_heritage_ai/main.dart';

void main() {
  testWidgets('Hon Viet AI app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const HonVietAIApp(initialThemeMode: ThemeMode.light),
    );

    await tester.pumpAndSettle();

    expect(find.text('H\u{1ED3}n Vi\u{1EC7}t AI'), findsOneWidget);
  });
}

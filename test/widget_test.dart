import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statitikcard/main.dart' as app;

import 'package:integration_test/integration_test.dart';

void main() => run(_testMain);

void _testMain() {
  testWidgets('checkDraw', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    app.main();

    // Trigger a frame.
    await tester.pumpAndSettle();

    // Go to add draw
    Finder addButton = find.widgetWithIcon(BottomNavigationBarItem, Icons.addchart);
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pump();

    // Press Fr
    Finder langueButton = find.byType(FlatButton);
    expect(langueButton, findsWidgets);
    await tester.tap(langueButton.first);
    await tester.pump();
  });
}
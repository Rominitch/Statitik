import 'package:flutter/material.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'package:statitikcard/main.dart' as app;

/*
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
*/

void main() {
  group('CheckDraw', () {
    // First, define the Finders and use them to locate widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys in step 1.
    final counterTextFinder = find.byValueKey('counter');
    final buttonFinder = find.byValueKey('increment');

    final addButton = find.byValueKey('Tirage');
    final langueButton = find.byType('FlatButton');


    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('starts at 0', () async {
      // Use the `driver.getText` method to verify the counter starts at 0.
      expect(await driver.getText(counterTextFinder), "0");
    });

    test('increments the counter', () async {
      // Build our app and trigger a frame.
      app.main();

      // Trigger a frame.
      await driver.waitFor(addButton);

      // Go to add draw
      await driver.tap(addButton);
      await driver.waitFor(langueButton);

      // Press Fr
      await driver.tap(langueButton);
    });
  });
}

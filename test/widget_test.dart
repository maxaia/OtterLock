// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:otterlock/main.dart';

void main() {
  testWidgets('Login screen validates and submits PIN', (WidgetTester tester) async {
    await tester.pumpWidget(const OtterLockApp());

    expect(find.text('Entrer le code PIN'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '1234');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pump();

    expect(find.text('Code PIN validé !'), findsOneWidget);
  });
}

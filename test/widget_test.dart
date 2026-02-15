// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:budjar/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BudjarApp());

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that the main navigation is present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });

  testWidgets('Add transaction FAB is present', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BudjarApp());

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that the add transaction button is present
    expect(find.text('Add Transaction'), findsOneWidget);
  });
}

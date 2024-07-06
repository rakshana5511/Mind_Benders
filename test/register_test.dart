// register_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coral_reef/Authentication/Register.dart';

void main() {
  testWidgets('Register widget has all required fields', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Register()));

    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your contact no'), findsOneWidget);
    expect(find.text('Enter your place of work'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
  });

  testWidgets('Register widget has a register button', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Register()));

    expect(find.text('REGISTER'), findsOneWidget);
  });

  testWidgets('Register widget shows error for empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Register()));

    await tester.tap(find.text('REGISTER'));
    await tester.pump();

    expect(find.text('username is required'), findsOneWidget);
    expect(find.text('email is required'), findsOneWidget);
    expect(find.text('contact no is required'), findsOneWidget);
    expect(find.text('work place is required'), findsOneWidget);
    expect(find.text('password is required'), findsNWidgets(2));
  });
}
// login_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coral_reef/Authentication/Login.dart';

void main() {
  testWidgets('Login widget has a username and password field', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Login()));

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Login widget has a login button', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Login()));

    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('Login widget shows error for empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Login()));

    await tester.tap(find.text('LOGIN'));
    await tester.pump();

    expect(find.text('Username is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}




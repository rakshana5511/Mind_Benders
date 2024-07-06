import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coral_reef/Authentication/Login.dart';

void main() {
  testWidgets('Login screen has expected elements', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: Login()));

    // Verify that the Login widget is present.
    expect(find.byType(Login), findsOneWidget);

    // Verify that the login button is present.
    expect(find.text('LOGIN'), findsOneWidget);

    // Verify that the register link is present.
    expect(find.text('Register'), findsOneWidget);
  });
}





// // This is a basic Flutter widget test.
// //
// // To perform an interaction with a widget in your test, use the WidgetTester
// // utility in the flutter_test package. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widget
// // tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:coral_reef/main.dart';

// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(MyApp());

//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);

//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();

//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }















// import 'package:coral_reef/Authentication/Login.dart';
// import 'package:coral_reef/main.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   testWidgets('App should start with Login screen', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(MyApp());

//     // Verify that the Login widget is present
//     expect(find.byType(Login), findsOneWidget);

//     // Verify that the login button is present
//     expect(find.text('LOGIN'), findsOneWidget);

//     // Verify that the register link is present
//     expect(find.text('Register'), findsOneWidget);
//   });
// }

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:login_page/screens/login_screen.dart';

void main() {
  testWidgets('Login screen loads with email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}

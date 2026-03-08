import 'package:busbooking/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginPage Widget Tests', () {
    testWidgets('LoginPage displays Bus Booking title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      expect(find.text('Bus Booking'), findsOneWidget);
    });

    testWidgets('LoginPage displays Welcome back text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      expect(find.text('Welcome back!'), findsOneWidget);
    });

    testWidgets('LoginPage has two TextFields', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('LoginPage has email hint text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      expect(find.text('Email address'), findsOneWidget);
    });

    testWidgets('LoginPage has password hint text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('LoginPage has Sign In button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('LoginPage has Forgot Password button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('LoginPage has Create Account button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
          find.text('Create Account'), 100,
          scrollable: scrollable);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('LoginPage has email icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('LoginPage has lock icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('LoginPage has bus icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      expect(find.byIcon(Icons.directions_bus), findsOneWidget);
    });

    testWidgets('LoginPage has User/Admin toggle', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      expect(find.text('User'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });
  });
}

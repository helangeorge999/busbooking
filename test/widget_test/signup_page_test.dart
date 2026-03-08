import 'package:busbooking/features/auth/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignupPage Widget Tests', () {
    testWidgets('SignupPage displays Create Your Account title',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      expect(find.text('Create Your Account'), findsOneWidget);
    });

    testWidgets('SignupPage has full name input field', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      expect(find.text('Enter Your Full Name'), findsOneWidget);
    });

    testWidgets('SignupPage has email input field', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      expect(find.text('Email Address'), findsOneWidget);
    });

    testWidgets('SignupPage has phone input field', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      expect(find.text('Phone Number'), findsOneWidget);
    });

    testWidgets('SignupPage has password input field', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      expect(find.text('Enter Your Password'), findsOneWidget);
    });

    testWidgets('SignupPage has confirm password field', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      expect(find.text('Confirm Your Password'), findsOneWidget);
    });

    testWidgets('SignupPage has DOB field', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      expect(find.text('DOB (YYYY-MM-DD)'), findsOneWidget);
    });

    testWidgets('SignupPage has Sign Up button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('SignupPage has Sign In button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('SignupPage has Already have an account text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      expect(find.text('Already have an account?'), findsOneWidget);
    });

    testWidgets('SignupPage has person icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('SignupPage has calendar icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupPage()));
      expect(find.byIcon(Icons.calendar_month), findsOneWidget);
    });
  });
}

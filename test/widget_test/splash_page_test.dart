import 'package:busbooking/features/auth/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplashPage Widget Tests', () {
    testWidgets('SplashPage displays app title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));
      expect(find.text('Bus Booking'), findsOneWidget);
    });

    testWidgets('SplashPage displays subtitle', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));
      expect(find.text('Book your seat with ease'), findsOneWidget);
    });

    testWidgets('SplashPage displays bus icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));
      expect(find.byIcon(Icons.directions_bus), findsOneWidget);
    });

    testWidgets('SplashPage has Login button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('SplashPage has Sign Up button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('SplashPage has ElevatedButton for Login', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('SplashPage has OutlinedButton for Sign Up', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('SplashPage has a Scaffold', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}

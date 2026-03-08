import 'package:busbooking/features/auth/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Home page displays greeting subtitle', (tester) async {
    SharedPreferences.setMockInitialValues({'user_name': 'Helan George'});

    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeContent())));
    await tester.pumpAndSettle();

    expect(find.text('Ready to book your next bus trip?'), findsOneWidget);
  });
}

import 'package:busbooking/features/auth/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Home page displays full name', (tester) async {
    SharedPreferences.setMockInitialValues({'user_name': 'Helan George'});

    await tester.pumpWidget(const MaterialApp(home: HomeContent()));

    expect(find.text('Hello, Helan George!'), findsOneWidget);
  });
}

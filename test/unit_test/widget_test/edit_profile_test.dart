import 'package:busbooking/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Edit Profile page loads', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: EditProfilePage()));

    expect(find.text('Edit Profile'), findsOneWidget);
  });
}

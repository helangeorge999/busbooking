import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Edit Profile page title renders', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Edit Profile')),
          body: const Center(child: Text('Edit Profile')),
        ),
      ),
    );

    expect(find.text('Edit Profile'), findsNWidgets(2));
  });
}

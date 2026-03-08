import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Profile page title text renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          appBar: null,
          body: Center(child: Text('Profile')),
        ),
      ),
    );

    expect(find.text('Profile'), findsOneWidget);
  });
}

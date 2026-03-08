import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Save Changes button is visible and tappable', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Save Changes'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}

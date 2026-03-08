import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Full Name Validation Tests', () {
    test('Full name should not be empty', () {
      const name = 'Helan George';
      expect(name.isNotEmpty, true);
    });

    test('Empty name is invalid', () {
      const name = '';
      expect(name.isEmpty, true);
    });

    test('Full name should contain at least 2 characters', () {
      const name = 'Helan';
      expect(name.length >= 2, true);
    });

    test('Single character name is invalid', () {
      const name = 'H';
      expect(name.length >= 2, false);
    });

    test('Name with trimmed spaces should not be empty', () {
      const name = '  Helan  ';
      expect(name.trim().isNotEmpty, true);
    });
  });
}

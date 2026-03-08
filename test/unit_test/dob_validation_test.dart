import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Date of Birth Validation Tests', () {
    test('DOB format should be YYYY-MM-DD', () {
      const dob = '2000-01-15';
      final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      expect(regex.hasMatch(dob), true);
    });

    test('Invalid DOB format should fail', () {
      const dob = '15/01/2000';
      final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      expect(regex.hasMatch(dob), false);
    });

    test('DOB should not be empty', () {
      const dob = '2000-01-15';
      expect(dob.isNotEmpty, true);
    });

    test('DOB year should be reasonable', () {
      const dob = '2000-01-15';
      final year = int.parse(dob.split('-')[0]);
      expect(year >= 1950 && year <= 2025, true);
    });

    test('DOB should be parseable to DateTime', () {
      const dob = '2000-01-15';
      final date = DateTime.tryParse(dob);
      expect(date, isNotNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phone Number Validation Tests', () {
    test('Phone number should be at least 10 digits', () {
      const phone = '9812345678';
      expect(phone.length >= 10, true);
    });

    test('Short phone number is invalid', () {
      const phone = '98123';
      expect(phone.length >= 10, false);
    });

    test('Phone number should not be empty', () {
      const phone = '9841234567';
      expect(phone.isNotEmpty, true);
    });

    test('Phone number should contain only digits', () {
      const phone = '9812345678';
      final isNumeric = RegExp(r'^[0-9]+$').hasMatch(phone);
      expect(isNumeric, true);
    });

    test('Phone with letters is invalid', () {
      const phone = '98abc45678';
      final isNumeric = RegExp(r'^[0-9]+$').hasMatch(phone);
      expect(isNumeric, false);
    });
  });
}

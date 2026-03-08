import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gender Validation Tests', () {
    test('Gender should be one of the allowed values', () {
      const gender = 'Male';
      final allowed = ['Male', 'Female', 'Others'];
      expect(allowed.contains(gender), true);
    });

    test('Invalid gender should not be in allowed values', () {
      const gender = 'Unknown';
      final allowed = ['Male', 'Female', 'Others'];
      expect(allowed.contains(gender), false);
    });

    test('Gender should not be empty', () {
      const gender = 'Female';
      expect(gender.isNotEmpty, true);
    });

    test('Null gender means not selected', () {
      const String? gender = null;
      expect(gender == null, true);
    });

    test('Gender list should have exactly 3 options', () {
      final genders = ['Male', 'Female', 'Others'];
      expect(genders.length, 3);
    });
  });
}

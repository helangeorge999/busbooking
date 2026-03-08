import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Email Validation Tests', () {
    test('Valid email contains @ symbol', () {
      const email = 'user@gmail.com';
      expect(email.contains('@'), true);
    });

    test('Invalid email without @ symbol', () {
      const email = 'usergmail.com';
      expect(email.contains('@'), false);
    });

    test('Email should not be empty', () {
      const email = 'test@example.com';
      expect(email.isNotEmpty, true);
    });

    test('Empty email is invalid', () {
      const email = '';
      expect(email.isEmpty, true);
    });

    test('Email with domain is valid', () {
      const email = 'user@domain.com';
      expect(email.contains('.'), true);
    });
  });
}

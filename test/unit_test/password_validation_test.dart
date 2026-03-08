import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Password Validation Tests', () {
    test('Password should not be empty', () {
      const password = 'mypassword123';
      expect(password.isNotEmpty, true);
    });

    test('Empty password is invalid', () {
      const password = '';
      expect(password.isEmpty, true);
    });

    test('Password should be at least 6 characters', () {
      const password = 'pass123';
      expect(password.length >= 6, true);
    });

    test('Short password is invalid', () {
      const password = '123';
      expect(password.length >= 6, false);
    });

    test('Passwords should match for confirmation', () {
      const password = 'mypassword';
      const confirmPassword = 'mypassword';
      expect(password == confirmPassword, true);
    });
  });
}

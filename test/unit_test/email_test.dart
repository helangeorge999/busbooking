import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Email should contain @ symbol', () {
    const email = 'test@gmail.com';
    expect(email.contains('@'), true);
  });
}

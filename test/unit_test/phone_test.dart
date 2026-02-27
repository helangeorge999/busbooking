import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Phone number should be at least 10 digits', () {
    const phone = '9812345678';
    expect(phone.length >= 10, true);
  });
}

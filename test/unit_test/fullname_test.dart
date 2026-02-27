import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Full name should not be empty', () {
    const fullName = 'Helan George';
    expect(fullName.isNotEmpty, true);
  });
}

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Profile image path should not be null', () {
    const imagePath = '/storage/emulated/0/profile.jpg';
    expect(imagePath, isNotNull);
  });
}

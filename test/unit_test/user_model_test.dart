import 'package:busbooking/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User Model Tests', () {
    test('User object should be created with valid data', () {
      final user = User(id: '1', email: 'test@gmail.com', username: 'Helan');
      expect(user.id, '1');
      expect(user.email, 'test@gmail.com');
      expect(user.username, 'Helan');
    });

    test('User email should not be empty', () {
      final user = User(id: '1', email: 'test@gmail.com', username: 'Helan');
      expect(user.email.isNotEmpty, true);
    });

    test('User username should not be empty', () {
      final user = User(id: '1', email: 'test@gmail.com', username: 'Helan');
      expect(user.username.isNotEmpty, true);
    });

    test('User id should not be empty', () {
      final user = User(id: '1', email: 'test@gmail.com', username: 'Helan');
      expect(user.id.isNotEmpty, true);
    });

    test('Two users with different ids are different', () {
      final user1 = User(id: '1', email: 'a@a.com', username: 'A');
      final user2 = User(id: '2', email: 'b@b.com', username: 'B');
      expect(user1.id != user2.id, true);
    });
  });
}

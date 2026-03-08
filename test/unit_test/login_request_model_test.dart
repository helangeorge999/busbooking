import 'package:busbooking/features/auth/data/models/login_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginRequestModel Tests', () {
    test('LoginRequestModel should be created with email and password', () {
      final model =
          LoginRequestModel(email: 'test@gmail.com', password: 'pass123');
      expect(model.email, 'test@gmail.com');
      expect(model.password, 'pass123');
    });

    test('toJson should return correct map', () {
      final model =
          LoginRequestModel(email: 'test@gmail.com', password: 'pass123');
      final json = model.toJson();
      expect(json['email'], 'test@gmail.com');
      expect(json['password'], 'pass123');
    });

    test('toJson should contain email key', () {
      final model =
          LoginRequestModel(email: 'test@gmail.com', password: 'pass123');
      final json = model.toJson();
      expect(json.containsKey('email'), true);
    });

    test('toJson should contain password key', () {
      final model =
          LoginRequestModel(email: 'test@gmail.com', password: 'pass123');
      final json = model.toJson();
      expect(json.containsKey('password'), true);
    });

    test('toJson map should have exactly 2 entries', () {
      final model =
          LoginRequestModel(email: 'test@gmail.com', password: 'pass123');
      final json = model.toJson();
      expect(json.length, 2);
    });
  });
}

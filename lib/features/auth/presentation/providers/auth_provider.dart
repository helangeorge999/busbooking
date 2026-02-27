import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/login_request_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  Future<void> login(LoginRequestModel request) async {
    // TEMP TEST (replace with API later)
    await Future.delayed(const Duration(seconds: 1));

    if (request.email.isEmpty || request.password.isEmpty) {
      throw Exception("Invalid credentials");
    }
  }
}

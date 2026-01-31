import 'package:flutter/material.dart';
import '../../data/datasources/remote/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';

class AuthViewModel extends ChangeNotifier {
  final _repo =
      AuthRepositoryImpl(AuthRemoteDataSource());

  bool isLoading = false;
  String? error;

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      await _repo.login(email, password);

      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

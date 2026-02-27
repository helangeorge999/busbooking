import '../../domain/auth_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> login(String email, String password) async {
    await remoteDataSource.login(email, password);
  }

  @override
  Future<void> register(Map<String, dynamic> body) async {
    await remoteDataSource.register(body);
  }
}

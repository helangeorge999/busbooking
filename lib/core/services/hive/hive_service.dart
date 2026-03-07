import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/auth/data/models/user_hive_model.dart';
import '../../constants/hive_table_constant.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserHiveModelAdapter());
    await Hive.openBox<UserHiveModel>(HiveTableConstant.userBox);
  }

  static Box<UserHiveModel> get _userBox =>
      Hive.box<UserHiveModel>(HiveTableConstant.userBox);

  /// Register a new user. Returns error message or null on success.
  static String? register(UserHiveModel user) {
    // Check if phone already exists
    final existing = _userBox.values.where((u) => u.phone == user.phone);
    if (existing.isNotEmpty) {
      return 'An account with this phone number already exists.';
    }
    _userBox.add(user);
    return null;
  }

  /// Login with phone and password. Returns user or null.
  static UserHiveModel? login(String phone, String password) {
    try {
      return _userBox.values.firstWhere(
        (u) => u.phone == phone && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get currently logged-in user's name (if stored).
  static String? getLoggedInUserName() {
    final box = Hive.box(HiveTableConstant.userBox);
    return box.get('logged_in_user') as String?;
  }
}

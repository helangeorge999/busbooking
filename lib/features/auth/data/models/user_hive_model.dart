import 'package:hive/hive.dart';
import '../../../../core/constants/hive_table_constant.dart';

part 'user_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String phone;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final String? dob;

  @HiveField(4)
  final String? gender;

  UserHiveModel({
    required this.name,
    required this.phone,
    required this.password,
    this.dob,
    this.gender,
  });
}

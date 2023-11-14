import 'package:angeleno_project/models/user.dart';
import '../models/password_reset.dart';
import '../utils/constants.dart';

abstract class Api {

  final String baseUrl = cloudFunctionURL;

  void updateUser(final User user);

  void updatePassword(final PasswordBody body);

}
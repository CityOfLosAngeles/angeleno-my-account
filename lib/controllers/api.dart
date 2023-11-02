import 'package:angeleno_project/models/user.dart';
import '../utils/constants.dart';

abstract class Api {

  final String baseUrl = cloudFunctionURL;

  void updateUser(final User user, {final String url = 'updateUser'});

}
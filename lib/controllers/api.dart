import 'package:angeleno_project/models/user.dart';

import '../utils/constants.dart';

abstract class Api {

  final String baseUrl = 'https://$auth0Domain';

  Future<String> getAccessToken();

  Future<User> patchUser(final User user);
}
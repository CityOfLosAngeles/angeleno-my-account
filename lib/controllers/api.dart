import 'package:angeleno_project/models/user.dart';

import '../utils/constants.dart';

abstract class Api {
  final String baseUrl = 'https://$auth0Domain/api/v2';

  Future<User> patchUser(final User user);
}
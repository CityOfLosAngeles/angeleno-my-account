import 'package:angeleno_project/models/user.dart';

abstract class Api {
  final String baseUrl = 'https://jsonplaceholder.typicode.com/users';

  Future<User> getUser(final String url);
}
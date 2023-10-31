import 'package:angeleno_project/models/user.dart';
import 'package:http/http.dart' as http;

abstract class Api {
  final String baseUrl = 'https://jsonplaceholder.typicode.com/users/1';

  Future<User> getUser(final http.Client client);
}
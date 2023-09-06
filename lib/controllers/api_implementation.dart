import 'dart:convert';
import 'dart:io';

import 'package:angeleno_project/controllers/api.dart';
import 'package:angeleno_project/models/user.dart';
import 'package:http/http.dart' as http;


class UserApi extends Api {

  @override
  Future<User> getUser(final String url) async {
    late User user;

    try {
      final response = await http.get(Uri.parse(baseUrl + url));

      if (response.statusCode == HttpStatus.ok) {
        final String rawJson = response.body;
        final jsonMap = jsonDecode(rawJson)[0];

        user = User(
            userId: jsonMap['id'].toString(),
            email: jsonMap['email'].toString(),
            firstName: jsonMap['name'].toString().split(' ')[0],
            lastName: jsonMap['name'].toString().split(' ')[1],
            zip: jsonMap['address']['zipcode'].toString(),
            address: jsonMap['address']['street'].toString(),
            city: jsonMap['address']['city'].toString(),
            state: 'CA',
            phone: jsonMap['phone'].toString()
        );
      }

    } on SocketException {
      throw 'No Internet Connection';
    } catch (e) {
      throw '$e';
    }

    return user;
  }


}
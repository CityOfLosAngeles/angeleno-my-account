// ignore_for_file: prefer_single_quotes
// Single quotes were causing issue when sending to Auth0
import 'dart:convert';
import 'dart:io';

import 'package:angeleno_project/controllers/api.dart';
import 'package:angeleno_project/models/user.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';


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
            userId: jsonMap['id'] as String,
            email: jsonMap['email'] as String,
            firstName: jsonMap['name'].toString().split(' ')[0],
            lastName: jsonMap['name'].toString().split(' ')[1],
            zip: jsonMap['address']['zipcode'] as String,
            address: jsonMap['address']['street'] as String,
            city: jsonMap['address']['city'] as String,
            state: 'CA',
            phone: jsonMap['phone'] as String
        );
      }

    } on SocketException {
      throw 'No Internet Connection';
    } catch (e) {
      throw '$e';
    }

    return user;
  }

  @override
  Future<User> patchUser(final User user) async {

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $auth0Token'
    };

    final data = json.encode({
      "name" : user.firstName,
      "family_name":  user.lastName,
      "phone_number": user.phone
    });

    final String userId = user.userId;
    final response = await http.patch(
        Uri.parse('https://lacity-dev.us.auth0.com/api/v2/users/$userId'),
        headers: headers,
        body: data
    );

    if (response.statusCode == HttpStatus.ok) {
       print(response.body);
    }

    return user;

  }



}
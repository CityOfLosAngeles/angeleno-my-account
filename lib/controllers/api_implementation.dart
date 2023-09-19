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
  Future<User> patchUser(final User user) async {

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $auth0Token'
    };

    final body = <String, String>{};

    if (user.firstName != null && user.firstName!.isNotEmpty) {
      body["name"] = user.firstName!;
    }

    if (user.lastName != null && user.lastName!.isNotEmpty) {
      body["family_name"] = user.lastName!;
    }

    if (user.phone != null && user.phone!.isNotEmpty) {
      // Phone numbers need to be in E.164

      // Replace anything that's not a number
      var phoneNumber = user.phone?.replaceAll(RegExp(r"\D"), "");

      // Make international
      phoneNumber = "+1${user.phone!}";

      // Ensure it passes Auth0's RegEx
      final authRegEx = RegExp("^\\+[0-9]{1,15}\$");

      if (!authRegEx.hasMatch(phoneNumber)) {
        return throw const FormatException('Invalid phone number.');
      }

      // "Cannot update phone_number for non-sms user"

      body["phone_number"] = phoneNumber;
    }

    final data = json.encode(body);

    final String userId = user.userId;
    final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
        body: data
    );

    if (response.statusCode == HttpStatus.ok) {
       print(response.body);
    }

    return user;

  }
}
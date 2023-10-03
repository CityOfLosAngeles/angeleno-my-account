// ignore_for_file: prefer_single_quotes
// Single quotes were causing issue when sending to Auth0

import 'dart:convert';
import 'dart:io';

import 'package:angeleno_project/controllers/api.dart';
import 'package:angeleno_project/models/user.dart';
import 'package:angeleno_project/utils/constants.dart';
import 'package:http/http.dart' as http;


class UserApi extends Api {

  @override
  Future<String> getAccessToken() async {
    late String accessToken;

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    final body = {
      "grant_type": "client_credentials",
      "client_id": auth0MachineClientId,
      "client_secret": auth0MachineSecret,
      "audience": "$baseUrl/api/v2/"
    };

    final response = await http.post(
        Uri.parse('$baseUrl/oauth/token'),
        headers: headers,
        body: body
    );

    if (response.statusCode == HttpStatus.ok) {
      final res = jsonDecode(response.body);
      accessToken = res["access_token"] as String;
    }

    return accessToken;
  }

  @override
  Future<User> patchUser(final User user) async {

    //TODO: use valid token within 24 hour time span.
    final Object token = await getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    final body = <String, dynamic>{};

    if (user.firstName != null && user.firstName!.isNotEmpty) {
      body["name"] = user.firstName!;
    }

    if (user.lastName != null && user.lastName!.isNotEmpty) {
      body["family_name"] = user.lastName!;
    }

    final primaryAddress = <String, String>{};
    if (user.zip != null && user.zip!.isNotEmpty) {
      primaryAddress["zip"] = user.zip!;
    }

    if (user.address != null && user.address!.isNotEmpty) {
      primaryAddress["address"] = user.address!;
    }

    if (user.state != null && user.state!.isNotEmpty) {
      primaryAddress["state"] = user.state!;
    }

    if (user.city != null && user.city!.isNotEmpty) {
      primaryAddress["city"] = user.city!;
    }

    user.metadata?["addresses"]["primary"] = primaryAddress;
    user.metadata?["phone"] = user.phone;
    body["user_metadata"] = user.metadata;

    // Might move phone to user_metadata
    // if (user.phone != null && user.phone!.isNotEmpty) {
    //   // Phone numbers need to be in E.164
    //
    //   // Replace anything that's not a number
    //   var phoneNumber = user.phone?.replaceAll(RegExp(r"\D"), "");
    //
    //   // Make international
    //   phoneNumber = "+1${user.phone!}";
    //
    //   // Ensure it passes Auth0's RegEx
    //   final authRegEx = RegExp("^\\+[0-9]{1,15}\$");
    //
    //   if (!authRegEx.hasMatch(phoneNumber)) {
    //     return throw const FormatException('Invalid phone number.');
    //   }
    //
    //   // "Cannot update phone_number for non-sms user"
    //
    //   body["phone_number"] = phoneNumber;
    // }

    final data = json.encode(body);

    final String userId = user.userId;
    final response = await http.patch(
        Uri.parse('$baseUrl/api/v2/users/$userId'),
        headers: headers,
        body: data
    );

    if (response.statusCode == HttpStatus.ok) {
       print(response.body);
    }

    return user;

  }
}
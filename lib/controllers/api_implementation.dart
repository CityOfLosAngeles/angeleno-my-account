// ignore_for_file: prefer_single_quotes
// Single quotes were causing issue when sending to Auth0

import 'dart:convert';
import 'dart:io';
import 'dart:html';
import 'package:angeleno_project/utils/constants.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:angeleno_project/controllers/api.dart';
import 'package:angeleno_project/models/user.dart';


class UserApi extends Api {

  String createJwt() {
    final jwt = JWT(
      {
        'exp': DateTime.now()
            .add(const Duration(hours: 1))
            .millisecondsSinceEpoch ~/ 1000,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'aud': 'https://www.googleapis.com/oauth2/v4/token',
        'target_audience': '$cloudFunctionURL/updateUser'
      },
      issuer: serviceAccountEmail,
      subject: serviceAccountEmail,
      header: {
        "alg":"RS256",
        "typ":"JWT"
      }
    );

    final privKey = serviceAccountSecret
        .replaceAll(r'\n', '\n');

    final rsaPrivKey = RSAPrivateKey(privKey);

    return jwt.sign(rsaPrivKey, algorithm: JWTAlgorithm.RS256);

  }

  Future<String> getOAuthToken() async {
    String newToken = '';

    final createdToken = createJwt();

    try {
      final response = await http.post(
          Uri.parse('https://www.googleapis.com/oauth2/v4/token'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer $createdToken'
          },
          body: 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$createdToken'
      );

      if (response.statusCode == HttpStatus.ok) {
        final jsonRes = jsonDecode(response.body);
        newToken = jsonRes["id_token"] as String;
      }
    } catch (err) {
      print(err);
    }

    return newToken;
  }


  @override
  void updateUser(final User user, {final String url = 'updateUser'}) async {

    final token = await getOAuthToken();

    if (token.isEmpty) {
      throw const FormatException('Empty token received');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    final body = json.encode(user);

    try {
      final response = await http.post(
          Uri.parse('$baseUrl/$url'),
          headers: headers,
          body: body
      );

      if (response.statusCode == HttpStatus.ok) {
        print(response.body);
      } else {
        print(response);
      }
    } catch (err) {
      print (err);
    }


  }
}
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
        'target_audience': cloudFunctionURL
      },
      issuer: serviceAccountEmail,
      subject: serviceAccountEmail,
      header: {
        'alg':'RS256',
        'typ':'JWT'
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
          // ignore: lines_longer_than_80_chars
          body: 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$createdToken'
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == HttpStatus.ok) {
        final jsonRes = jsonDecode(response.body);
        newToken = jsonRes['id_token'] as String;
      }
    } catch (err) {
      print(err);
    }

    return newToken;
  }


  @override
  Future<int> updateUser(final User user) async {
    late int statusCode;

    try {
      final token = await getOAuthToken();

      if (token.isEmpty) {
        throw const FormatException('Empty token received');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      final body = json.encode(user);

      final response = await http.post(
          Uri.parse('/updateUser'),
          headers: headers,
          body: body
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == HttpStatus.ok) {
        print(response.body);

        statusCode = response.statusCode;
      } else {
        print(response);
        statusCode = response.statusCode;
      }
    } catch (err) {
      print (err);
      // generic server error
      statusCode = HttpStatus.internalServerError;
    }

    return statusCode;
  }
}
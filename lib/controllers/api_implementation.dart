import 'dart:convert';
import 'dart:io';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:angeleno_project/models/api_exception.dart';
import 'package:angeleno_project/models/api_response.dart';
import 'package:angeleno_project/models/password_reset.dart';
import 'package:angeleno_project/utils/constants.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:angeleno_project/controllers/api.dart';
import 'package:angeleno_project/models/user.dart';
import 'package:http/http.dart';

class UserApi extends Api {
  String createJwt() {
    final jwt = JWT(
        {
          'exp': DateTime.now()
                  .add(const Duration(hours: 1))
                  .millisecondsSinceEpoch ~/
              1000,
          'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'aud': 'https://www.googleapis.com/oauth2/v4/token',
          'target_audience': cloudFunctionURL
        },
        issuer: serviceAccountEmail,
        subject: serviceAccountEmail,
        header: {'alg': 'RS256', 'typ': 'JWT'});

    final privKey = serviceAccountSecret.replaceAll(r'\n', '\n');

    final rsaPrivKey = RSAPrivateKey(privKey);

    return jwt.sign(rsaPrivKey, algorithm: JWTAlgorithm.RS256);
  }

  Future<String> getOAuthToken() async {
    String newToken = '';

    final createdToken = createJwt();

    try {
      final response = await http
          .post(Uri.parse('https://www.googleapis.com/oauth2/v4/token'),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Authorization': 'Bearer $createdToken'
              },
              // ignore: lines_longer_than_80_chars
              body:
                  'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$createdToken')
          .timeout(const Duration(seconds: 15));

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
    print('We are in updateUser');

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
      Response? response;

      if (isTestingLocally) {
        print('We are testing locally UPDATE USER');
        response = await http
            //.post(Uri.parse('AUTH0_FIREBASE_UPDATE_USER_BASE_URL/updateUser'),
            .post(Uri.parse(UpdateUserAPIFirebaseURL),
                headers: headers, body: body)
            .timeout(const Duration(seconds: 15));
      } else {
        response = await http
            .post(Uri.parse('/updateUser'), headers: headers, body: body)
            .timeout(const Duration(seconds: 15));
      }

      if (response.statusCode == HttpStatus.ok) {
        print(response.body);
      } else {
        print(response);
      }

      statusCode = response.statusCode;
    } catch (err) {
      print(err);
      // generic server error
      statusCode = HttpStatus.internalServerError;
    }

    return statusCode;
  }

  @override
  Future<Map<String, dynamic>> updatePassword(final PasswordBody body) async {
    late Map<String, dynamic> response;

    final headers = {'Content-Type': 'application/json'};

    final reqBody = json.encode(body);

    try {
      Response? request;
      if (isTestingLocally) {
        await http.post(Uri.parse(updatePasswordAPIFirebaseURL),
            headers: headers, body: reqBody);
      } else {
        await http.post(Uri.parse('/updatePassword'),
            headers: headers, body: reqBody);
      }

      // await http.post(Uri.parse('updatePasswordAPIFirebaseURL/updatePassword'),
      //   headers: headers, body: reqBody);

      response = {
        'status': request!.statusCode,
        'body': request.body.isNotEmpty ? request.body : 'Error Encountered'
      };
    } catch (err) {
      print(err);
      // generic server error
      response = {
        'status': HttpStatus.internalServerError,
        'body': 'Error Encountered'
      };
    }

    return response;
  }

  @override
  Future<ApiResponse> getAuthenticationMethods(final String userId) async {

    final headers = {
      'Content-Type': 'application/json'
    };

    final reqBody = json.encode({'userId': userId});

    try {
      final request = await http.post(
          Uri.parse('/authMethods'),
          headers: headers,
          body: reqBody
      );

      if (request.statusCode == HttpStatus.ok) {
        return ApiResponse(request.statusCode, request.body);
      } else {
        throw ApiException(request.statusCode, request.body);
      }

    } on ApiException catch(e) {
      return ApiResponse(e.statusCode, e.error);
    } catch (err) {
      return ApiResponse(HttpStatus.internalServerError, 'Error Encountered');
    }
  }

  @override
  Future<Map<String, dynamic>>
    enrollAuthenticator(final Map<String, String> body) async {
    late Map<String, dynamic> response;

    final headers = {
      'Content-Type': 'application/json'
    };

    final reqBody = json.encode(body);

    try {
      final request = await http.post(
          Uri.parse('/enrollOTP'),
          headers: headers,
          body: reqBody
      );

      final jsonBody = jsonDecode(request.body);
      final barcode = jsonBody['barcode_uri'];
      final token = jsonBody['token'];
      final tokenSecret = jsonBody['secret'];

      if (request.statusCode == HttpStatus.ok) {
        response = {
          'status': request.statusCode,
          'body': request.body,
          'barcode': barcode,
          'token': token,
          'barcode_string': tokenSecret
        };
      } else {
        throw ApiException(request.statusCode, request.body);
      }

    } on ApiException catch(e) {
      response = {
        'status': e.statusCode,
        'body': e.error
      };
    } catch (err) {
      response = {
        'status': HttpStatus.internalServerError,
        'body': 'Error Encountered'
      };
    }

    return response;
  }

  @override
  Future<ApiResponse> confirmTOTP(final Map<String, String> body) async {

    final headers = {
      'Content-Type': 'application/json'
    };

    final reqBody = json.encode(body);

    try {
      final request = await http.post(
          Uri.parse('/confirmOTP'),
          headers: headers,
          body: reqBody
      );

      if (request.statusCode == HttpStatus.ok) {
        return ApiResponse(request.statusCode, '');
      } else {
        throw ApiException(request.statusCode, request.body);
      }

    }  on ApiException catch(e) {
      return ApiResponse(e.statusCode, e.error);
    } catch (err) {
      return ApiResponse(HttpStatus.internalServerError, 'Error Encountered.');
    }
  }

  @override
  Future<ApiResponse> unenrollAuthenticator(final Map<String, String> body)
  async {

    final headers = {
      'Content-Type': 'application/json'
    };

    final reqBody = json.encode(body);

    try {
      final request = await http.post(
          Uri.parse('/unenrollMFA'),
          headers: headers,
          body: reqBody
      );

      if (request.statusCode == HttpStatus.ok) {
        return ApiResponse(request.statusCode, '');
      } else {
        throw ApiException(request.statusCode, request.body);
      }

    }  on ApiException catch(e) {
      return ApiResponse(e.statusCode, e.error);
    } catch (err) {
      return ApiResponse(HttpStatus.internalServerError, 'Error Encountered');
    }
  }
}

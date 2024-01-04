import 'dart:convert';

class ApiException implements Exception {
  final int statusCode;
  final String? body;

  String get error {
    final errJson = jsonDecode(body!);
    return errJson['error'] as String;
  }

  ApiException(this.statusCode, this.body);
}

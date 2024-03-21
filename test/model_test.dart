import 'package:angeleno_project/models/api_exception.dart';
import 'package:angeleno_project/models/password_reset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiException', () {
    test('Should return error message from JSON body', () {
      // Arrange
      const int statusCode = 404;
      const String responseBody = '{"error": "Resource not found"}';
      final ApiException apiException = ApiException(statusCode, responseBody);

      // Act
      final error = apiException.error;

      // Assert
      expect(error, 'Resource not found');
    });

    test('Should return default error message when JSON decoding fails', () {
      const int statusCode = 500;
      const String responseBody = 'Internal Server Error';
      final ApiException apiException = ApiException(statusCode, responseBody);

      final error = apiException.error;

      expect(error, 'Error encountered');
    });

    test('Should return default error message when body is null', () {

      const int statusCode = 400;
      final ApiException apiException = ApiException(statusCode, null);

      final error = apiException.error;

      expect(error, 'Error encountered');
    });

    test('Should return response error message when body contains error in body', () {

      const int statusCode = 418;
      const String responseBody = '{"error": "I\'m a teapot"}';
      final ApiException apiException = ApiException(statusCode, responseBody);

      final error = apiException.error;

      expect(error, "I'm a teapot");
    });
  });

  group('PasswordBody', () {
    test('toJson() should return a valid map', () {
      // Arrange
      final passwordBody = PasswordBody(
        email: 'test@example.com',
        oldPassword: 'oldPassword123',
        newPassword: 'newPassword456',
        userId: '123456789',
      );

      // Act
      final json = passwordBody.toJson();

      // Assert
      expect(json, isA<Map<String, dynamic>>());
      expect(json['email'], 'test@example.com');
      expect(json['oldPassword'], 'oldPassword123');
      expect(json['newPassword'], 'newPassword456');
      expect(json['userId'], '123456789');
    });
  });


}
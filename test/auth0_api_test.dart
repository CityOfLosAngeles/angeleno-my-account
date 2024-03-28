import 'dart:io';

import 'package:angeleno_project/models/api_exception.dart';
import 'package:angeleno_project/models/api_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/advanced_test.mocks.dart';


void main() {

  late MockUserApi mockUserApi;

  setUp(() {
    mockUserApi = MockUserApi();
  });

  test('getAuthenticationMethods returns ApiResponse when successful', () async {
    const userId = 'testUser';
    final apiResponse = ApiResponse(HttpStatus.ok, 'Success');

    when(mockUserApi.getAuthenticationMethods(userId))
    .thenAnswer((_) async => apiResponse);

    expect(await mockUserApi.getAuthenticationMethods(userId), equals(apiResponse));
  });
}

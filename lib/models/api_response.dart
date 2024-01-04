class ApiResponse implements Exception {
  late final int statusCode;
  late final String body;

  ApiResponse(final int statusCode, final String body);
}

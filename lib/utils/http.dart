import "package:http/http.dart" show Response;

void handleServiceError(Response response) {
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw BadHTTPStatusException(response.statusCode);
  }
}

class BadHTTPStatusException implements Exception {
  BadHTTPStatusException(this.status);

  final int status;

  @override
  String toString() => "Bad HTTP status code: $status";
}

class HttpRequestException implements Exception {
  final int statusCode;
  final bool success;
  final String message;
  final dynamic details;
  final String? stackTrace;

  HttpRequestException({
    required this.statusCode,
    required this.message,
    this.success = false,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'HttpRequestException($statusCode): Success: $success\nMessage: $message\nDetails: $details';
  }
}

class ClientErrorException extends HttpRequestException {
  ClientErrorException({
    required super.statusCode,
    required super.message,
    super.success = false,
    super.details,
    super.stackTrace,
  });
}

class ServerErrorException extends HttpRequestException {
  ServerErrorException({
    required super.statusCode,
    required super.message,
    super.success = false,
    super.details,
    super.stackTrace,
  });
}

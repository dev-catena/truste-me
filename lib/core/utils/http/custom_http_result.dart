class HttpResult implements Exception {
  final int statusCode;
  final bool success;
  final String? message;
  final dynamic result;

  HttpResult({
    required this.statusCode,
    this.message,
    this.success = true,
    this.result,
  });

  @override
  String toString() {
    return 'HttpResult($statusCode): Success: $success\nMessage: $message\nResult: $result';
  }
}
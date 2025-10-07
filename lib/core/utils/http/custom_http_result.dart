class HttpResult implements Exception {
  final int statusCode;
  final bool success;
  final String? message;
  final dynamic data;

  HttpResult({
    required this.statusCode,
    this.message,
    this.success = true,
    this.data,
  });

  @override
  String toString() {
    return 'HttpResult($statusCode): Success: $success\nMessage: $message\nData: $data';
  }
}
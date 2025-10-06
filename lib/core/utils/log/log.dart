
import 'package:trustme/core/utils/log/logger.dart';

class Log {
  static const APP_NAME = "TRUSTME";

  static void v(String tag, String message, [dynamic exception, StackTrace? stackTrace]) {
    logger.t('($APP_NAME) V - $tag: $message', error: exception, stackTrace: stackTrace);
  }

  static void i(String tag, String message, [dynamic exception, StackTrace? stackTrace]) {
    logger.i('($APP_NAME) I - $tag: $message', error: exception, stackTrace: stackTrace);
  }

  static void d(String tag, String message, [dynamic exception, StackTrace? stackTrace]) {
    logger.d('($APP_NAME) D - $tag: $message', error: exception, stackTrace: stackTrace);
  }

  static void e(String tag, String message, [dynamic exception, StackTrace? stackTrace]) {
    logger.e('($APP_NAME) E - $tag: $message', error: exception, stackTrace: stackTrace);
  }
}
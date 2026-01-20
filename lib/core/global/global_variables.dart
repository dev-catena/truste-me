

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class GlobalVariables {
  static Level DEF_LOG_LEVEL = kDebugMode ? Level.trace : Level.error;
  static bool DEF_CHECK_AUTH_ERRORS = true;

  static const String DEF_APP_NAME = 'TrueConnect';
  static const bool DEF_USE_LOGO_COLOR_AS_APP_COLOR = true;
  static const bool DEF_USE_APP_LOGO_ON_APPBAR = true;

  static bool DEF_PRINT_HTTP_REQUEST = false || !kDebugMode;
  static bool DEF_PRINT_HTTP_RESPONSES = true && kDebugMode;
  // ignore: dead_code
  static bool DEF_PRINT_HTTP_RESPONSES_FORMATTED = false && kDebugMode;

  // TODO: Don't use it for PRODUCTION deploy
  static bool DEF_USE_DEV_ENVIRONMENT = false;

  static var isGoogleTestUser = false;
  static var isFirebaseTestLab = false;
  static var isCrashlyticsCollectionEnabled = false;
}
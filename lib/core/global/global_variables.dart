

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class GlobalVariables {
  static Level DEF_LOG_LEVEL = kDebugMode ? Level.trace : Level.error;
  static bool DEF_CHECK_AUTH_ERRORS = true;

  // TODO: Don't use it for PRODUCTION deploy
  static bool DEF_USE_DEV_ENVIRONMENT = false;

  static var isGoogleTestUser = false;
  static var isFirebaseTestLab = false;
  static var isCrashlyticsCollectionEnabled = false;
}


import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class GlobalVariables {
  static Level DEF_LOG_LEVEL = kDebugMode ? Level.trace : Level.error;
  static bool DEF_CHECK_AUTH_ERRORS = true;
}
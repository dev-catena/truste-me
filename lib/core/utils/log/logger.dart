import 'package:logger/logger.dart';

import 'package:trustme/core/global/global_variables.dart';

/*
* The LogFilter decides which log events should be shown and which don't.
* The default implementation (DevelopmentFilter) shows all logs with level >= Logger.level while in debug mode.
* In release mode all logs are omitted.
* */
class CustomFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

var logger = Logger(
  level: GlobalVariables.DEF_LOG_LEVEL,
  //filter: CustomFilter(),
  printer: PrettyPrinter(
      noBoxingByDefault: true,
      methodCount: 0, // number of method calls to be displayed
      //errorMethodCount: 8, // number of method calls if stacktrace is provided
      //lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      //printEmojis: true, // Print an emoji for each log message
      printTime: true // Should each log print contain a timestamp
  ),
);
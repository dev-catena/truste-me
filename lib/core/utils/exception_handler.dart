import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class ExceptionHandler {
  final Object e;
  final StackTrace s;

  ExceptionHandler(this.e, this.s) {
    debugPrint('$runtimeType - error: $e\n    stack: $s');
    // _logException(e, s);
  }

  String getMessage() {
    final String message;
    if (e is TimeoutException) {
      message = '${e.runtimeType}: Tempo de execução excedido!\nVerifique sua conexão e tente novamente.';
    } else if (e is FormatException) {
      message = '${e.runtimeType}: Request/Response mal formatado.\nTente novamente mais tarde!';
    } else if (e is ClientException) {
      message = '${e.runtimeType}: Não foi possível alcançar o serivdor!\nVerifique sua conexão e tente novamente.';
    } else {
      message = '${e.runtimeType}: Ocorreu um erro inesperado,\ntente novamente mais tarde!';
    }
    return message;
  }

  // Future<void> _logException(Object e, StackTrace s) async {
  //   if (kReleaseMode) {
  //     FirebaseCrashlytics.instance.recordError(e, s);
  //     logger.e('Exception: $e\nStack: $s');
  //   } else {
  //     logger.e('Exception: $e\nStack: $s');
  //   }
  // }
}

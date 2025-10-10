import 'dart:convert';

import 'package:trustme/core/api_provider.dart';
import 'package:trustme/core/utils/log/log.dart';

class NewPasswordDataSource {
  final _apiProvider = ApiProvider();

  Future<bool> verifyEmail(String email) async {
    final content = {
      'email': email,
      'tipo': 'redefinicao',
    };

    try {
      final resp = (await _apiProvider.post('acesso/enviar-codigo', jsonEncode(content), useToken: false)).result;

      if(resp['message'] == 'Email com código enviado com sucesso'){
        return true;
      } else {
        return false;
      }
    } catch (e, s) {
      Log.e('$runtimeType', 'Error on verifyEmail method.', e, s);
      return false;
    }
  }

  Future<bool> validateCode(int code) async {
    final content = {
      'codigo': code,
    };

    try {
      final resp = (await _apiProvider.post('acesso/validar-codigo', jsonEncode(content), useToken: false)).result;

      if(resp['success']){
        return true;
      } else {
        return false;
      }
    } catch (e, s) {
      Log.e('$runtimeType', 'Error on validateCode method.', e, s);
      return false;
    }
  }

  Future<bool> resetPwd(int code, String pwd) async {
    final content = {
      'codigo': code,
      'new_password': pwd,
      'new_password_confirmation': pwd
    };


    try {
      final resp = (await _apiProvider.post('acesso/redefinir-senha', jsonEncode(content), useToken: false)).result;

      if(resp['success']){
        return true;
      } else {
        return false;
      }
    } catch (e, s) {
      Log.e('$runtimeType', 'Error on resetPwd method.', e, s);
      return false;
    }
  }
}

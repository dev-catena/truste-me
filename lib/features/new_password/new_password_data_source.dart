import 'dart:convert';

import '../../core/api_provider.dart';

class NewPasswordDataSource {
  final _apiProvider = ApiProvider(false);

  Future<bool> verifyEmail(String email) async {
    final content = {
      'email': email,
      'tipo': 'redefinicao',
    };

    final resp = await _apiProvider.post('acesso/enviar-codigo', jsonEncode(content));

    if(resp['message'] == 'Email com código enviado com sucesso'){
      return true;
    } else {
      return false;
    }
  }

  Future<bool> validateCode(int code) async {
    final content = {
      'codigo': code,
    };

    final resp = await _apiProvider.post('acesso/validar-codigo', jsonEncode(content));

    if(resp['success']){
      return true;
    } else {
      return false;
    }
  }

  Future<bool> resetPwd(int code, String pwd) async {
    final content = {
      'codigo': code,
      'new_password': pwd,
      'new_password_confirmation': pwd
    };

    final resp = await _apiProvider.post('acesso/redefinir-senha', jsonEncode(content));

    if(resp['success']){
      return true;
    } else {
      return false;
    }

  }
}

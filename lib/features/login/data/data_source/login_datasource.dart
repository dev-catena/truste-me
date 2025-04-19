import 'dart:convert';

import '../../../../core/api_provider.dart';
import '../../../common/data/models/person_model.dart';
import '../../../common/domain/entities/person.dart';

class LoginDataSource{
  final bool useToken;
  LoginDataSource(this.useToken);

  late final ApiProvider _apiProvider = ApiProvider(useToken);

  Future<bool> login(String cpf, String pwd) async {
    final content = {'CPF': cpf, 'password': pwd};
    try {
      final rawData = await _apiProvider.post('login', jsonEncode(content));

      final user = PersonModel.fromJson(rawData).toEntity();

      setLoggedInUser(user);

      return true;
    } catch(e){
      return false;
    }
  }

  Future<void> logout() async {
    await _apiProvider.post('logout', jsonEncode({}));
  }
}
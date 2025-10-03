import 'dart:convert';


import '../../../../core/api_provider.dart';
import '../../../../core/providers/app_data_cubit.dart';
import '../../../../core/providers/user_data_cubit.dart';
import '../../../../core/utils/preferences/app_preferences.dart';
import '../../../common/data/models/auth_model.dart';
import '../../../common/data/models/user_model.dart';
import '../../../common/domain/entities/auth.dart';

class LoginDataSource {
  final bool useToken;
  final UserDataCubit userData;
  final AppDataCubit appData;

  LoginDataSource(this.useToken, this.userData, this.appData);

  late final ApiProvider _apiProvider = ApiProvider();

  Future<bool> login(String cpf, String pwd) async {
    final content = {'CPF': cpf, 'password': pwd};
    final rawData = await _apiProvider.post('login', jsonEncode(content), useToken: false);

    if (rawData['token'] != null) {
      final auth = AuthModel.fromJson(rawData).toEntity();
      await setAuthData(auth);
      await appData.initialize();
      return true;
    } else {
      return false;
    }
  }
}

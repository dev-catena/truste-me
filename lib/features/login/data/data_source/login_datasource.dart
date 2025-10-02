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

  late final ApiProvider _apiProvider = ApiProvider(useToken);

  Future<bool> login(String cpf, String pwd) async {
    final content = {'CPF': cpf, 'password': pwd};
    final rawData = await _apiProvider.post('login', jsonEncode(content));

    if (rawData['token'] != null) {
      final auth = AuthModel.fromJson(rawData).toEntity();
      await setAuthData(auth);
      await appData.initialize();
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    await _apiProvider.post('logout', jsonEncode({})); // TODO: Perguntar para o Raul o que o logout faz no backend

    final prefs = AppPreferences();
    await prefs.remove(KeyPrefs.AUTH_TOKEN);
    await prefs.remove(KeyPrefs.REFRESH_TOKEN);
    await prefs.remove(KeyPrefs.AUTH_TOKEN_EXPIRATION);

    // setLoggedInUser(
    //   Person(
    //     id: 0,
    //     fullName: '',
    //     cpf: '',
    //     birthDate: DateTime.now(),
    //     memberSince: DateTime.now(),
    //     connectionCode: '',
    //     authToken: '',
    //   ),
    // );
  }
}

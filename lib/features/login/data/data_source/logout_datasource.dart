import 'dart:convert';


import '../../../../core/api_provider.dart';
import '../../../../core/providers/app_data_cubit.dart';
import '../../../../core/providers/user_data_cubit.dart';
import '../../../../core/utils/preferences/app_preferences.dart';
import '../../../common/data/models/auth_model.dart';
import '../../../common/data/models/user_model.dart';
import '../../../common/domain/entities/auth.dart';

class LogoutDataSource {
  LogoutDataSource();

  late final ApiProvider _apiProvider = ApiProvider(true);

  Future<void> logout() async {
    await _apiProvider.post('logout', jsonEncode({}));

    final prefs = AppPreferences();
    await prefs.remove(KeyPrefs.AUTH_TOKEN);
    await prefs.remove(KeyPrefs.REFRESH_TOKEN);
    await prefs.remove(KeyPrefs.AUTH_TOKEN_EXPIRATION);

    await prefs.remove(KeyPrefs.USER_LAST_ITERATION);

    resetAuthData();

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

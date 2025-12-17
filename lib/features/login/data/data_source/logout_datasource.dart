import 'dart:convert';

import 'package:trustme/core/utils/log/log.dart';

import '../../../../core/api_provider.dart';
import '../../../../core/utils/preferences/app_preferences.dart';
import '../../../common/domain/entities/auth.dart';

class LogoutDataSource {
  LogoutDataSource();

  late final ApiProvider _apiProvider = ApiProvider();

  Future<void> logout() async {
    try {
      await _apiProvider.post('logout', jsonEncode({}), checkErrors: false);
    } catch(ex) {
      Log.e('$runtimeType', 'Error trying to logout');
      // Do nothing...
    }

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

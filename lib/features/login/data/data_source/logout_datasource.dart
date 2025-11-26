import 'dart:convert';

import 'package:trustme/core/api_provider.dart';
import 'package:trustme/core/utils/log/log.dart';
import 'package:trustme/core/utils/preferences/app_preferences.dart';
import 'package:trustme/features/common/domain/entities/auth.dart';

class LogoutDataSource {
  LogoutDataSource();

  late final ApiProvider _apiProvider = ApiProvider();

  Future<void> logout() async {
    try {
      await _apiProvider.post('logout', jsonEncode({}), checkErrors: false);
    } catch (e, s) {
      // Even if the server-side logout fails, we must clear local data.
      // Log the error for debugging purposes.
      Log.e('$runtimeType', 'Server logout failed', e, s);
    }

    // Always proceed to clear local authentication data.
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

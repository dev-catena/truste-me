
import '../../../../core/utils/preferences/app_preferences.dart';

Future<void> setAuthData(Auth auth) async {
  
  final prefs = AppPreferences();
  await prefs.setString(KeyPrefs.AUTH_TOKEN, auth.authToken);

  if(auth.refreshToken != null) {
    await prefs.setString(KeyPrefs.REFRESH_TOKEN, auth.refreshToken!);
  } else {
    await prefs.remove(KeyPrefs.REFRESH_TOKEN);
  }

  if(auth.expirationAt != null) {
    await prefs.setInt(KeyPrefs.AUTH_TOKEN_EXPIRATION, auth.expirationAt!.millisecondsSinceEpoch);
  } else {
    await prefs.remove(KeyPrefs.AUTH_TOKEN_EXPIRATION);
  }

  _auth = auth;
}

Auth? get authData {
  return _auth;
}

void resetAuthData() {
  _auth = null;
}

Auth? _auth;

class Auth {
  String authToken;
  String? refreshToken;
  final DateTime? expirationAt;

  Auth({
    this.authToken = '',
    this.refreshToken,
    this.expirationAt
  });

  Auth copyWith({
    String? authToken,
    String? refreshToken,
    DateTime? expirationAt,
  }) {
    return Auth(
      authToken: authToken ?? this.authToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expirationAt: expirationAt ?? this.expirationAt,
    );
  }

  @override
  String toString() {
    return 'Auth{authToken: $authToken, refreshToken: $refreshToken, expirationAt: $expirationAt }';
  }
}

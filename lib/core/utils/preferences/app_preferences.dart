
import 'package:encrypt_shared_preferences/provider.dart';

enum KeyPrefs {
  //region ## ACCOUNT CONTROL
  AUTH_TOKEN,
  REFRESH_TOKEN,
  AUTH_TOKEN_EXPIRATION,
  //endregion
  //region ## DEVICE DATA
  PUSH_TOKEN,
  PUSH_TOKEN_NOT_REGISTERED,
  PUSH_TOKEN_LAST_SENT,
  //endregion

  //region ## USER DATA
  USER_CODE,
  USER_FULL_NAME,
  USER_CPF,
  USER_EMAIL,
  //endregion

  INSTALLATION_DATE,
  IS_TEST_USER,

  USER_LAST_ITERATION,

  LAST_LOGOUT_REASON,
}

extension KeyPrefsEx on KeyPrefs {
  String get name => this.toString().replaceAll('KeyPrefs.', ''); //names[this];
}

/// How to use it:
/// var ap = AppPreferences();
/// await ap.initializationDone;
class AppPreferences {

  static final String DEF_KEY = 'PREF_KEY_TRUSTME'; // WARNING: It MUST BE 16 characters

  late Future _doneFuture;
  Future get initializationDone => _doneFuture;

  late EncryptedSharedPreferences prefs;

  AppPreferences() {
    _doneFuture = _init();
  }

  Future _init() async {
    await EncryptedSharedPreferences.initialize(DEF_KEY);
    prefs = EncryptedSharedPreferences.getInstance();
  }

  //region ## Set Methods
  Future<void> setString(KeyPrefs key, String value) async {
    await initializationDone;
    await prefs.setString(key.name, value);
  }

  Future<void> setStringWithPrefix(KeyPrefs prefix, String key, String value) async {
    await initializationDone;
    await prefs.setString(prefix.name + key, value);
  }

  Future<void> setInt(KeyPrefs key, int value) async {
    await initializationDone;
    await prefs.setInt(key.name, value);
  }

  Future<void> setBool(KeyPrefs key, bool value) async {
    await initializationDone;
    await prefs.setBool(key.name, value);
  }
  //endregion

  //region ## Get Methods
  Future<String?> getString(KeyPrefs key, String? defValue) async {
    await initializationDone;
    return prefs.getString(key.name, defaultValue: defValue);
  }

  Future<int?> getInt(KeyPrefs key, int? defValue) async {
    await initializationDone;
    return prefs.getInt(key.name, defaultValue: defValue);
  }

  Future<bool?> getBool(KeyPrefs key, bool? defValue) async {
    await initializationDone;
    return prefs.getBool(key.name, defaultValue: defValue);
  }
  //endregion

  //region ## Remove Methods
  Future<bool> remove(KeyPrefs key) async {
    await initializationDone;
    return await prefs.remove(key.name);
  }
  //endregion

  Future<List<String>> getKeysByPrefix(KeyPrefs key) async {
    await initializationDone;

    final allKeys = prefs.getKeys(); // Get all keys

    final List<String> filteredKeys = [];
    for (String prefKey in allKeys) {
      if (prefKey.startsWith(key.name)) {
        filteredKeys.add(prefKey); // Add keys that match the prefix
      }
    }
    return filteredKeys;
  }

  Future<Map<String, dynamic>> getMapFromKeys(List<String> keys) async {
    await initializationDone;

    final Map<String, dynamic> retrievedMap = {};

    for (String key in keys) {
      // You'll need to know the expected type for each key,
      // or handle potential nulls and type casting.
      // For demonstration, let's assume all values are strings or can be handled generically.
      final dynamic value = prefs.get(key); // Use get() for generic retrieval
      if (value != null) {
        retrievedMap[key] = value;
      }
    }
    return retrievedMap;
  }
}
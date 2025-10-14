
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:trustme/core/global/global_variables.dart';
import 'package:trustme/core/utils/log/log.dart';
import 'package:trustme/core/utils/preferences/app_preferences.dart';

class CrashlyticsUtil {

  static const String TAG = 'CrashlyticsUtil';
  static FirebaseCrashlytics _firebaseCrashlytics = FirebaseCrashlytics.instance;

  static Future<void> setCrashlyticsEnabledWithCheck() async {

    final prefs = AppPreferences();

    final installationDate = (await prefs.getInt(KeyPrefs.INSTALLATION_DATE, 0))!;

    if(installationDate <= 0) {
      await prefs.setInt(KeyPrefs.INSTALLATION_DATE, DateTime.now().millisecondsSinceEpoch);
    }

    if (kDebugMode) {
    //if (false) { // TODO: Remove this line, uncomment the line above
      // Force disable Crashlytics collection while doing every day development.
      // Temporarily toggle this to true if you want to test crash reporting in your app.
      await _firebaseCrashlytics.setCrashlyticsCollectionEnabled(false);
      GlobalVariables.isCrashlyticsCollectionEnabled = false;
      //Log.d(TAG, "isCrashlyticsCollectionEnabled = FALSE");
    } else {
      // Handle Crashlytics enabled status when not in Debug
      // add the following if you want to test in debug mode
      await _firebaseCrashlytics.setCrashlyticsCollectionEnabled(true);
      GlobalVariables.isCrashlyticsCollectionEnabled = true;
      Log.d(TAG, 'isCrashlyticsCollectionEnabled = TRUE');
    }
  }

  static Future<void> setCrashlyticsCustomVariables( ) async {

    final prefs = AppPreferences();

    //region Register user data to Crashlytics events
    // CPF (LOGIN)
    String? strData = await prefs.getString(KeyPrefs.USER_CPF, null);
    if(strData != null && strData.isNotEmpty) {
      _firebaseCrashlytics.setCustomKey('USER', strData);
    }

    strData = await prefs.getString(KeyPrefs.USER_CODE, null);
    if(strData != null && strData.isNotEmpty) {
      _firebaseCrashlytics.setCustomKey('TRUSTME_CODE', strData);
    }

    strData = await prefs.getString(KeyPrefs.USER_EMAIL, null);
    if(strData != null && strData.isNotEmpty) {
      _firebaseCrashlytics.setCustomKey('EMAIL', strData);
    }

    // USER FULL NAME
    strData = await prefs.getString(KeyPrefs.USER_FULL_NAME, null);
    if(strData != null && strData.isNotEmpty) {
      _firebaseCrashlytics.setCustomKey('USER_FULL_NAME', strData);
    }

    // FIREBASE TEST LAB
    if(GlobalVariables.isFirebaseTestLab) {
      _firebaseCrashlytics.setCustomKey('IS_FIREBASE_TEST_LAB', GlobalVariables.isFirebaseTestLab);
    }

    // Token FCM / APN (PUSH NOTIFICATION TOKEN)
    // strData = await prefs.getString(KeyPrefs.PUSH_TOKEN, null);
    // if(strData != null && strData.isNotEmpty) {
    //   _firebaseCrashlytics.setCustomKey("PUSH_TOKEN", strData);
    // }

    // PLATFORM (Android / iOS)
    //_firebaseCrashlytics.setCustomKey("PLATFORM", Platform.isIOS ? "IOS" : "ANDROID");

    // APP VERSION CODE AND VERSION NAME
    //PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // _firebaseCrashlytics.setCustomKey("APP_VERSION", packageInfo.version); // VERSION CODE
    // _firebaseCrashlytics.setCustomKey("APP_BUILD_NUMBER", packageInfo.buildNumber); // VERSION NAME
    //endregion
  }

  static void setUserIdentifier(String userId, String userName) {
    _firebaseCrashlytics.setUserIdentifier(userId);
    _firebaseCrashlytics.setCustomKey('NAME', userName);
  }

  static void reportError(String reason, dynamic e, StackTrace? stack, {bool fatal = false, bool? printDetails, String? logDetail, Iterable<Object> information = const []}) {
    if(logDetail != null) {
      _firebaseCrashlytics.log(logDetail);
    }
    _firebaseCrashlytics.recordError(e, stack, reason: reason, fatal: fatal, printDetails: printDetails, information: information);

    //_firebaseCrashlytics.sendUnsentReports();
  }
}
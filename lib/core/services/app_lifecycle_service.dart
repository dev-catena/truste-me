import 'package:flutter/material.dart';

import '../../main.dart';
import '../utils/log/log.dart';
import '../utils/preferences/app_preferences.dart';

class AppLifecycleService with WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  static final DEF_USER_LAST_ITERATION_THRESHOLD_IN_HOURS = 24;

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      final prefs = AppPreferences();
      await prefs.setInt(KeyPrefs.USER_LAST_ITERATION, DateTime.now().millisecondsSinceEpoch);
      Log.d('$runtimeType', '📦 Last user iteration SAVED!');
    } else if(state == AppLifecycleState.resumed) {
      if(!(await isUserLastIterationThresholdValid())) {
        TrustMeApp.logout();
      }
    }
  }

  Future<DateTime> getLastInteraction() async {
    final prefs = AppPreferences();
    return DateTime.fromMillisecondsSinceEpoch((await prefs.getInt(KeyPrefs.USER_LAST_ITERATION, DateTime.now().millisecondsSinceEpoch))!);
  }

  Future<bool> isUserLastIterationThresholdValid() async {
    // WARNING: If last user iteration is greater than X HOURS, the app needs to logout
    return (await getLastInteraction()).add(Duration(hours: DEF_USER_LAST_ITERATION_THRESHOLD_IN_HOURS)).millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch;
  }
}

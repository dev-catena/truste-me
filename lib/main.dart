import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_testlab_detector/firebase_testlab_detector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trustme/core/global/global_variables.dart';
import 'package:trustme/core/utils/firebase/crashlytics_util.dart';

import 'core/app_theme.dart';
import 'core/providers/app_data_cubit.dart';
import 'core/providers/user_data_cubit.dart';
import 'core/routes.dart';
import 'core/services/app_lifecycle_service.dart';
import 'core/utils/globals.dart';
import 'core/utils/preferences/app_preferences.dart';
import 'features/common/data/data_source/app_data_source.dart';
import 'features/common/data/data_source/user_data_source.dart';
import 'features/common/domain/entities/auth.dart';
import 'features/conection/data/data_source/connection_datasource.dart';
import 'features/contracts/data/data_source/contract_datasource.dart';
import 'features/login/data/data_source/logout_datasource.dart';

// windows cmd
// mkdir home\data\data_source && mkdir home\data\models && mkdir home\data\repositories && mkdir home\domain\entities && mkdir home\domain\repositories && mkdir home\domain\usecases && mkdir home\presentation\blocs && mkdir home\presentation\widgets
// mkdir profile\data\data_source
// mkdir profile\data\models
// mkdir profile\data\repositories
// mkdir profile\domain\entities
// mkdir profile\domain\repositories
// mkdir profile\domain\usecases
// mkdir profile\presentation\blocs
// mkdir profile\presentation\widgets

final DEF_TEST = true;

void main() {
  initializeDateFormatting('pt_BR', null).then((_) async {
    WidgetsFlutterBinding.ensureInitialized();

    AppLifecycleService().init();

    //region # LOAD AUTH VARIABLES
    final prefs = AppPreferences();

    final authToken = await prefs.getString(KeyPrefs.AUTH_TOKEN, null);
    final expirationAt = await prefs.getInt(KeyPrefs.AUTH_TOKEN_EXPIRATION, null);

    if(authToken != null) {
      await setAuthData(
          Auth(
            authToken: authToken,
            expirationAt: expirationAt != null ? DateTime.fromMillisecondsSinceEpoch(expirationAt) : null,
            refreshToken: await prefs.getString(KeyPrefs.REFRESH_TOKEN, null),
          )
      );
    } else {
      await prefs.getString(KeyPrefs.AUTH_TOKEN, null);
      await prefs.getString(KeyPrefs.AUTH_TOKEN_EXPIRATION, null);
      await prefs.getString(KeyPrefs.REFRESH_TOKEN, null);
    }
    //endregion

    await Firebase.initializeApp();

    //region ## CRASHLYTICS CONFIGURATION
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    //endregion

    GlobalVariables.isFirebaseTestLab = await FirebaseTestlabDetector.isAppRunningInTestlab() ?? false;

    await CrashlyticsUtil.setCrashlyticsEnabledWithCheck();
    await CrashlyticsUtil.setCrashlyticsCustomVariables();

    GlobalVariables.isGoogleTestUser = (await prefs.getBool(KeyPrefs.IS_TEST_USER, false))!;

    runApp(const TrustMeApp());
  });
}

class TrustMeApp extends StatefulWidget {
  const TrustMeApp({super.key});

  static final GoRouter _routes = AppRoutes().routes;

  static Future<void> logout() async {
    await LogoutDataSource().logout();
    _routes.goNamed(AppRoutes.loginScreen);
  }

  @override
  State<TrustMeApp> createState() => _TrustMeAppState();
}

class _TrustMeAppState extends State<TrustMeApp> {

  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
      providers: [
        BlocProvider<UserDataCubit>(
          create: (_) => UserDataCubit(UserDataSource(), ContractDataSource(), ConnectionDataSource()),
        ),
        BlocProvider<AppDataCubit>(
          create: (_) => AppDataCubit(AppDataSource()),
        ),
      ],
      child: MaterialApp.router(
        scaffoldMessengerKey: Globals.scaffoldMessengerKey,
        title: 'TrustMe',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        theme: AppTheme().getAppTheme(context),
        routeInformationParser: TrustMeApp._routes.routeInformationParser,
        routeInformationProvider: TrustMeApp._routes.routeInformationProvider,
        routerDelegate: TrustMeApp._routes.routerDelegate,
      ),
    );
  }
}

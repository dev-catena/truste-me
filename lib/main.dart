import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_theme.dart';
import 'core/providers/app_data_cubit.dart';
import 'core/providers/user_data_cubit.dart';
import 'core/routes.dart';
import 'core/utils/globals.dart';
import 'core/utils/preferences/app_preferences.dart';
import 'features/common/data/data_source/app_data_source.dart';
import 'features/common/data/data_source/user_data_source.dart';
import 'features/common/domain/entities/auth.dart';
import 'features/conection/data/data_source/connection_datasource.dart';
import 'features/contracts/data/data_source/contract_datasource.dart';

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

var DEF_TEST = true;

void main() {
  initializeDateFormatting('pt_BR', null).then((_) async {
    WidgetsFlutterBinding.ensureInitialized();

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

    runApp(const TrustMeApp());
  });
}

class TrustMeApp extends StatelessWidget {
  const TrustMeApp({super.key});

  static final GoRouter _routes = AppRoutes().routes;

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
        routeInformationParser: _routes.routeInformationParser,
        routeInformationProvider: _routes.routeInformationProvider,
        routerDelegate: _routes.routerDelegate,
      ),
    );
  }
}

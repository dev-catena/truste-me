import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/app_theme.dart';
import 'core/routes.dart';
import 'core/utils/globals.dart';
import 'features/common/domain/entities/person.dart';

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

void main() {

  // setLoggedInUser(Person(
  //   id: 1,
  //   fullName: 'Artur Dias',
  //   cpf: '14080264658',
  //   birthDate: 26,
  //   memberSince: DateTime(2025, 2, 20),
  //   connectionCode: 'artur#123456',
  //   photoPath: 'https://thispersondoesnotexist.com/',
  //   country: 'Brasil',
  //   state: 'Belo Horizonte',
  //   sealsObtained: [],
  //   profession: 'Desenvolvedor',
  // ));

  initializeDateFormatting('pt_BR', null).then((_) {

    runApp(const TrustMeApp());
  });
}

class TrustMeApp extends StatelessWidget {
  const TrustMeApp({super.key});

  static final GoRouter _routes = AppRoutes().routes;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: Globals.scaffoldMessengerKey,
      title: 'Laços',
      theme: AppTheme().getAppTheme(context),
      routeInformationParser: _routes.routeInformationParser,
      routeInformationProvider: _routes.routeInformationProvider,
      routerDelegate: _routes.routerDelegate,
    );
  }
}

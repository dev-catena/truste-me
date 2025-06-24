import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/conection/domain/entities/connection.dart';
import '../features/conection/presentation/widgets/screens/connection_detail_screen.dart';
import '../features/conection/presentation/widgets/screens/connection_panel_screen.dart';
import '../features/contracts/domain/entities/contract.dart';
import '../features/contracts/presentation/widgets/screens/contract_detail_screen.dart';
import '../features/contracts/presentation/widgets/screens/contracts_panel_screen.dart';
import '../features/contracts/presentation/widgets/screens/new_contract_screen.dart';
import '../features/home/presentation/widgets/screens/home_screen.dart';
import '../features/login/presentation/widgets/login_screen.dart';
import '../features/new_password/new_password_screen.dart';
import '../features/profile/presentation/widgets/profile_screen.dart';
import '../features/register/presentation/register_screen.dart';
import 'providers/user_data_cubit.dart';
import 'scaffold_with_nested_navigation.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
final _shellNavigatorBKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');
final _shellNavigatorCKey = GlobalKey<NavigatorState>(debugLabel: 'shellC');

class AppRoutes {
  static const loginScreen = '/login';
  static const splashScreen = '/splash';

  static const newPasswordScreen = 'nova-senha';

  static const homeScreen = '/';
  static const contractsScreen = '/contratos';
  static const contractDetailScreen = 'contrato-detalhes';
  static const newContractScreen = 'novo-contrato';

  static const registerScreen = '/cadastro';

  // Dentro de homeScreen
  static const connectionPanelScreen = 'conexoes';
  static const connectionDetailScreen = 'conexao-detalhes';

  static const profileScreen = '/perfil';

  GoRouter get routes {
    return _routes;
  }
}

final GoRouter _routes = GoRouter(
  initialLocation: AppRoutes.loginScreen,
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorBKey,
          initialLocation: AppRoutes.contractsScreen,
          routes: [
            GoRoute(
              path: AppRoutes.contractsScreen,
              name: AppRoutes.contractsScreen,
              pageBuilder: (context, state) {
                final initialFilter = (state.extra as Map<String, dynamic>? ?? {})['initialFilter'] as ContractStatus?;
                return NoTransitionPage(
                  child: ContractsScreen(
                    key: ValueKey(initialFilter),
                    initialFilter: initialFilter?.description,
                  ),
                );
              },
              routes: [
                GoRoute(
                  path: AppRoutes.contractDetailScreen,
                  name: AppRoutes.contractDetailScreen,
                  builder: (context, state) {
                    final Contract extra = state.extra as Contract;

                    return ContractDetailScreen(extra);
                  },
                ),
                GoRoute(
                  path: AppRoutes.newContractScreen,
                  name: AppRoutes.newContractScreen,
                  builder: (context, state) {
                    return const NewContractScreen();
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAKey,
          initialLocation: AppRoutes.homeScreen,
          routes: [
            GoRoute(
              path: AppRoutes.homeScreen,
              name: 'home',
              pageBuilder: (context, state) => NoTransitionPage(child: HomeScreen()),
              routes: [
                GoRoute(
                  path: AppRoutes.connectionPanelScreen,
                  name: AppRoutes.connectionPanelScreen,
                  builder: (_, state) {
                    final initialFilter =
                        (state.extra as Map<String, dynamic>? ?? {})['initialFilter'] as ConnectionStatus?;

                    return ConnectionPanelScreen(
                      key: ValueKey(initialFilter),
                      initialFilter: initialFilter?.description,
                    );
                  },
                  routes: [
                    GoRoute(
                      path: AppRoutes.connectionDetailScreen,
                      name: AppRoutes.connectionDetailScreen,
                      builder: (context, state) {
                        final connection = state.extra as Connection;

                        return ConnectionDetailScreen(connection);
                      },
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
        // StatefulShellBranch(
        //   navigatorKey: _shellNavigatorCKey,
        //   initialLocation: AppRoutes.appointmentScheduleScreen,
        //   routes: [
        //   ],
        // ),
      ],
    ),
    GoRoute(
      path: AppRoutes.loginScreen,
      name: AppRoutes.loginScreen,
      builder: (_, __) => const LoginScreen(),
      routes: [
        GoRoute(
          path: AppRoutes.newPasswordScreen,
          name: AppRoutes.newPasswordScreen,
          builder: (_, __) => const NewPasswordScreen(),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.registerScreen,
      name: AppRoutes.registerScreen,
      builder: (_, __) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.profileScreen,
      name: AppRoutes.profileScreen,
      builder: (context, __) {
        return const ProfileScreen();
      },
    ),
  ],
);

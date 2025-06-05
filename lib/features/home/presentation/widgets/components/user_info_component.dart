import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/providers/user_data_cubit.dart';
import '../../../../../core/routes.dart';
import '../../../../conection/domain/entities/connection.dart';
import '../../../../contracts/domain/entities/contract.dart';
import 'summary_card.dart';

class UserInfoComponent extends StatelessWidget {
  const UserInfoComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = context.read<UserDataCubit>();

    return BlocBuilder<UserDataCubit, UserDataState>(
      bloc: userData,
      builder: (_, state) {
        if (state is UserDataReady) {
          final info = userData.getUserInfo;
          final summaries = [
            SummaryData(
              'Contratos ativos',
              info.activeContracts,
              onTap: () => context.go(
                AppRoutes.contractsScreen,
                extra: {'initialFilter': ContractStatus.active},
              ),
            ),
            SummaryData(
              'Contratos pendentes',
              info.pendingContracts,
              onTap: () => context.go(
                AppRoutes.contractsScreen,
                extra: {'initialFilter': ContractStatus.pending},
              ),
            ),
            SummaryData(
              'Selos pendentes',
              info.pendingSeals,
              onTap: () => context.push(AppRoutes.profileScreen),
            ),
            SummaryData(
              'Conexões ativas',
              info.activeConnections,
              onTap: () => context.pushNamed(
                AppRoutes.connectionPanelScreen,
                extra: {'initialFilter': ConnectionStatus.accepted},
              ),
            ),
            SummaryData(
              'Conexões pendentes',
              info.pendingConnections,
              onTap: () => context.pushNamed(
                AppRoutes.connectionPanelScreen,
                extra: {'initialFilter': ConnectionStatus.pending},
              ),
            ),
          ];

          return Wrap(
            spacing: 5,
            runSpacing: 5,
            children: List.generate(
              summaries.length,
              (index) {
                return summaries[index].buildCard();
              },
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/enums/contract_status.dart';
import '../../../../../core/providers/user_data_cubit.dart';
import '../../../../../core/routes.dart';
import '../../../../conection/domain/entities/connection.dart';
import 'summary_card.dart';

class UserHomeInfoComponent extends StatelessWidget {
  const UserHomeInfoComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = context.read<UserDataCubit>();

    return BlocBuilder<UserDataCubit, UserDataState>(
      bloc: userData,
      builder: (_, state) {
        if (state is UserDataReady) {
          final summaries = [
            SummaryData(
              'Contratos ativos',
              state.contracts.where((element) => element.status == ContractStatus.active).length,
              onTap: () => context.go(
                AppRoutes.contractsScreen,
                extra: {'initialFilter': ContractStatus.active},
              ),
            ),
            SummaryData(
              'Contratos pendentes',
              state.contracts.where((element) => element.status == ContractStatus.pending).length,
              onTap: () => context.go(
                AppRoutes.contractsScreen,
                extra: {'initialFilter': ContractStatus.pending},
              ),
            ),
            SummaryData(
              'Selos pendentes',
              0,
              onTap: () => context.push(AppRoutes.profileScreen),
            ),
            SummaryData(
              'Conexões ativas',
              state.connections.where((element) => element.status == ConnectionStatus.accepted).length,
              onTap: () => context.pushNamed(
                AppRoutes.connectionPanelScreen,
                extra: {'initialFilter': ConnectionStatus.accepted},
              ),
            ),
            SummaryData(
              'Conexões pendentes',
              state.connections.where((element) => element.status == ConnectionStatus.pending).length,
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

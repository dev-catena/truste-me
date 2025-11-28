import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:trustme/core/enums/contract_status.dart';
import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/core/routes.dart';
import 'package:trustme/features/connection/domain/entities/connection.dart';
import 'package:trustme/features/home/presentation/widgets/components/summary_card.dart';

class UserHomeInfoComponent extends StatelessWidget {
  const UserHomeInfoComponent({super.key});

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<UserDataCubit, UserDataState>(
      bloc: context.read<UserDataCubit>(),
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
              emphasizeQuantity: true,
              state.contracts.where((element) => element.status == ContractStatus.pending).length,
              onTap: () => context.go(
                AppRoutes.contractsScreen,
                extra: {'initialFilter': ContractStatus.pending},
              ),
            ),
            SummaryData(
              'Selos pendentes',
              0,
              emphasizeQuantity: true,
              onTap: () => context.push(AppRoutes.sealsScreen, extra: {'onlyPendingSeals': true}),
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
              emphasizeQuantity: true,
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

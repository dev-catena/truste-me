import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/providers/user_data_cubit.dart';
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
            SummaryData('Contratos ativos', info.activeContracts),
            SummaryData('Contratos pendentes', info.pendingContracts),
            SummaryData('Selos pendentes', info.pendingSeals),
            SummaryData('Conexões ativas', info.activeConnections),
            SummaryData('Conexões pendentes', info.pendingConnections),
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

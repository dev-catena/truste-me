import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../../common/presentation/widgets/components/header_line.dart';
import '../../../../home/data/models/feature_data.dart';
import '../../../../home/presentation/widgets/dialogs/contract_history_dialog.dart';
import '../../../data/data_source/contract_datasource.dart';
import '../../../domain/entities/contract.dart';
import '../../blocs/contract_detail/contract_detail_bloc.dart';
import '../components/clause_selection_card.dart';

class ContractDetailScreen extends StatelessWidget {
  const ContractDetailScreen(this.contract, {super.key});

  final Contract contract;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContractDetailBloc(ContractDataSource(), contract),
      child: CustomScaffold(
        child: BlocBuilder<ContractDetailBloc, ContractDetailState>(
          builder: (blocCtx, state) {
            final bloc = blocCtx.read<ContractDetailBloc>();
            if (state is ContractDetailInitial) {
              bloc.add(ContractDetailStarted());
              return const CircularProgressIndicator();
            } else if (state is ContractDetailLoadInProgress) {
              return const CircularProgressIndicator();
            } else if (state is ContractDetailReady) {
              return _ContractReady(state);
            } else {
              return Column(
                children: [
                  const Text('NoState'),
                  IconButton(onPressed: ()=>bloc.add(ContractDetailStarted()), icon: const Icon(Icons.refresh_outlined))
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class _ContractReady extends StatelessWidget {
  const _ContractReady(
    this.state
  );

  final ContractDetailReady state;

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge!;

    return RefreshIndicator(
      onRefresh: () async => context.read<ContractDetailBloc>().add(ContractDetailStarted()),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HeaderLine('Contrato ${state.contract.contractNumber}', Symbols.contract),
            const SizedBox(height: 12),
            state.contract.buildDetailCard(),
            const SizedBox(height: 12),
            Text(
              'Atividades',
              style: titleLarge.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FeatureData(
                  name: 'Histórico',
                  icon: Icons.history,
                  extraAction: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const ContractHistoryDialog();
                      },
                    );
                  },
                ).buildCard(),
                FeatureData(name: 'Download', icon: Symbols.file_save).buildCard(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Detalhes',
              style: titleLarge.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ClauseSelectionCard(
              contractor: state.contract.contractor!,
              stakeHolder: state.contract.stakeHolder,
              possibleClauses: state.possibleClauses,
              clausesChosen: state.contract.clauses,
              onClausePicked: (value) => context.read<ContractDetailBloc>().add(ContractDetailClauseSet(value)),
            ),
          ],
        ),
      ),
    );
  }
}

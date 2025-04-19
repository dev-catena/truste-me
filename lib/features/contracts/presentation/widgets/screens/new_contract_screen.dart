import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../../core/routes.dart';
import '../../../../common/domain/entities/person.dart';
import '../../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../../common/presentation/widgets/components/header_line.dart';
import '../../../../conection/data/data_source/connection_datasource.dart';
import '../../../data/data_source/contract_datasource.dart';
import '../../blocs/new_contract/new_contract_bloc.dart';
import '../components/clause_selection_card.dart';
import '../components/new_contract_header.dart';
import 'contract_detail_screen.dart';

class NewContractScreen extends StatelessWidget {
  const NewContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: BlocProvider<NewContractBloc>(
        create: (_) => NewContractBloc(ContractDataSource(), ConnectionDatasource()),
        child: BlocConsumer<NewContractBloc, NewContractState>(
          listener: (context, state) {
            if (state is NewContractCreationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contrato criado com sucesso!')));
              context.pop();
            } else if (state is NewContractInsufficientData) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Preencha os campos de parte interessada e tipo de contrato!'),
              ));
            }
          },
          builder: (blocCtx, state) {
            if (state is NewContractInitial) {
              blocCtx.read<NewContractBloc>().add(NewContractStarted());
              return const CircularProgressIndicator();
            } else if (state is NewContractLoadInProgress) {
              return const CircularProgressIndicator();
            } else if (state is NewContractReady) {
              return _ReadyScreen(state);
            } else {
              return const Text('No state');
            }
          },
        ),
      ),
    );
  }
}

class _ReadyScreen extends StatelessWidget {
  const _ReadyScreen(this.state);

  final NewContractReady state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NewContractBloc>();

    final List<Person> personList = [];

    for (final ele in state.acceptedConnections) {
      personList.add(ele.user);
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HeaderLine('Criação de contrato', Symbols.contract),
          const SizedBox(height: 12),
          NewContractHeader(state),
          const SizedBox(height: 16),
          ClauseSelectionCard(
            stakeHolder: state.stakeHolderSelected,
            possibleClauses: state.possibleClauses,
            clausesChosen: state.clausesChosen,
            onClausePicked: (clause) {
              bloc.add(NewContractClauseAdded(clause));
            },
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              bloc.add(NewContractContractCreated());
            },
            child: const Text('Criar contrato'),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../../core/providers/user_data_cubit.dart';
import '../../../../common/domain/entities/person.dart';
import '../../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../../common/presentation/widgets/components/header_line.dart';
import '../../../../conection/data/data_source/connection_datasource.dart';
import '../../../data/data_source/contract_datasource.dart';
import '../../../domain/entities/clause.dart';
import '../../../domain/entities/contract.dart';
import '../../blocs/new_contract/new_contract_bloc.dart';
import '../components/clause_selection_card.dart';
import '../components/new_contract_header.dart';

class NewContractScreen extends StatefulWidget {
  const NewContractScreen({super.key});

  @override
  State<NewContractScreen> createState() => _NewContractScreenState();
}

class _NewContractScreenState extends State<NewContractScreen> {
  Person? stakeHolderSelected;
  ContractType? typeSelected;
  final List<Clause> allClauses = [];
  final List<Clause> currentClauses = [];

  void _setStakeHolder(Person user) {
    if (stakeHolderSelected == user) {
      stakeHolderSelected = null;
    } else {
      stakeHolderSelected = user;
    }
    setState(() {});
  }

  Future<void> _setType(ContractType type) async {
    allClauses.clear();

    if (typeSelected == type) {
      typeSelected = null;
    } else {
      typeSelected = type;
      final clausesFetched = await ContractDataSource().getClausesForContractType(typeSelected!);
      allClauses.addAll(clausesFetched);
    }
    setState(() {});
  }

  void _addClause(Clause clause) {
    currentClauses.add(clause);

    if (allClauses.contains(clause)) {
      allClauses.remove(clause);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userData = context.read<UserDataCubit>();

    return CustomScaffold(child: BlocBuilder<UserDataCubit, UserDataState>(
      builder: (context, state) {
        if (state is UserDataReady) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const HeaderLine('Criação de contrato', Symbols.contract),
                const SizedBox(height: 12),
                NewContractHeader(
                  state.connections,
                  onStakeHolderSelected: _setStakeHolder,
                  onTypeSelected: (value) async => await _setType(value),
                  currentStakeHolder: stakeHolderSelected,
                  currentType: typeSelected,
                ),
                const SizedBox(height: 16),
                ClauseSelectionCard(
                  contractor: userData.getUser,
                  stakeHolder: stakeHolderSelected,
                  possibleClauses: allClauses,
                  clausesChosen: currentClauses,
                  onClausePicked: _addClause,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    await userData.createContract(stakeHolderSelected!, typeSelected!, allClauses);
                    context.pop();
                  },
                  child: const Text('Criar contrato'),
                )
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    ));

    return CustomScaffold(
      child: BlocProvider<NewContractBloc>(
        create: (_) => NewContractBloc(userData, ContractDataSource(), ConnectionDataSource()),
        child: BlocConsumer<NewContractBloc, NewContractState>(
          listener: (context, state) {
            if (state is NewContractCreationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contrato criado com sucesso!')));
              context.pop();
            } else if (state is NewContractInsufficientData) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Preencha os campos de parte interessada, tipo de contrato e adicione pelo menos uma cláusula!'),
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

    final userData = context.watch<UserDataCubit>();

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
          // NewContractHeader(state),
          const SizedBox(height: 16),
          ClauseSelectionCard(
            contractor: userData.getUser,
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

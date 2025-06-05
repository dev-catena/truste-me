import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../../core/providers/app_data_cubit.dart';
import '../../../../../core/providers/user_data_cubit.dart';
import '../../../../common/domain/entities/person.dart';
import '../../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../../common/presentation/widgets/components/header_line.dart';
import '../../../data/data_source/contract_datasource.dart';
import '../../../domain/entities/clause.dart';
import '../../../domain/entities/contract.dart';
import '../../../domain/entities/contract_type.dart';
import '../../../domain/entities/sexual_practice.dart';
import '../components/clause_selection_card.dart';
import '../components/contract_specification_widget.dart';
import '../components/new_contract_header.dart';

class NewContractScreen extends StatefulWidget {
  const NewContractScreen({super.key});

  @override
  State<NewContractScreen> createState() => _NewContractScreenState();
}

class _NewContractScreenState extends State<NewContractScreen> {
  Person? stakeHolderSelected;
  ContractType? typeSelected;
  final List<Clause> currentClauses = [];
  final List<SexualPractice> practicesTaken = [];
  bool sharesNeedle = false;

  List<Clause> allClauses = [];
  List<SexualPractice> allPractices = [];

  String periodicitySelected = 'Nunca';

  void _setStakeHolder(Person user) {
    if (stakeHolderSelected == user) {
      stakeHolderSelected = null;
    } else {
      stakeHolderSelected = user;
    }
    setState(() {});
  }

  Future<void> _setType(ContractType type) async {
    currentClauses.clear();

    if (typeSelected == type) {
      typeSelected = null;
    } else {
      typeSelected = type;
      final clausesFetched = await ContractDataSource().getClausesForContractType(typeSelected!);
      allClauses = clausesFetched.clauses;
      allPractices = clausesFetched.practices;
    }
    setState(() {});
  }

  void _addClause(Clause clause) {
    currentClauses.add(clause);

    setState(() {});
  }

  void _removeClause(Clause clause) {
    currentClauses.remove(clause);

    setState(() {});
  }

  void onPracticeChosen(SexualPractice value) {
    practicesTaken.add(value);
  }

  void onPracticeRemoved(SexualPractice value) {
    practicesTaken.remove(value);
  }

  @override
  void dispose() {
    practicesTaken.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = context.read<UserDataCubit>();
    final appData = context.read<AppDataCubit>();

    return CustomScaffold(
      child: BlocBuilder<UserDataCubit, UserDataState>(
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
                    stakeHolders: stakeHolderSelected != null ? [stakeHolderSelected!] : [],
                    possibleClauses: allClauses,
                    clausesChosen: currentClauses,
                    onClausePicked: _addClause,
                    onRemove: _removeClause,
                    onAcceptOrDeny: null,
                  ),
                  const SizedBox(height: 12),
                  if (typeSelected != null && stakeHolderSelected != null)
                    ContractSpecificationWidget(
                      type: typeSelected!,
                      practicesAvailable: allPractices,
                      initialPractices: practicesTaken,
                      // participants: userData.getConnections.map((e) => e.user).toList(),
                      // participants: [userLoggedIn, stakeHolderSelected!],
                      participants: [userLoggedIn],
                      onPick: onPracticeChosen,
                      onRemove: onPracticeRemoved,
                      showStatusPerPerson: false,
                      onAcceptOrDeny: null,
                    ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () async {
                      await userData.createContract(
                          stakeHolderSelected!, typeSelected!, currentClauses, practicesTaken);
                      context.pop();
                      // final Contract contract = Contract(
                      //   id: 0,
                      //   contractNumber: 'x',
                      //   status: 'Pendente',
                      //   type: typeSelected!,
                      //   stakeHolders: stakeHolders,
                      //   clauses: clauses,
                      // );
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
      ),
    );
  }
}

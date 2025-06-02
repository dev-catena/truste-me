import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../../core/providers/app_data_cubit.dart';
import '../../../../../core/providers/user_data_cubit.dart';
import '../../../../common/domain/entities/person.dart';
import '../../../../common/presentation/widgets/components/custom_scaffold.dart';
import '../../../../common/presentation/widgets/components/header_line.dart';
import '../../../../common/presentation/widgets/components/stateful_segmented_button.dart';
import '../../../../common/presentation/widgets/dialogs/single_select_dialog.dart';
import '../../../../conection/data/data_source/connection_datasource.dart';
import '../../../data/data_source/contract_datasource.dart';
import '../../../domain/entities/clause.dart';
import '../../../domain/entities/contract.dart';
import '../../../domain/entities/sexual_practice.dart';
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
  final List<SexualPractice> practicesTaken = [];
  bool sharesNeedle = false;

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

  void onPracticeChosen(SexualPractice value) {
    practicesTaken.add(value);
    setState(() {});
  }

  Widget _buildPracticesContent(
    ContractType type,
    List<Person> users,
    List<SexualPractice> practicesAvailable,
    List<SexualPractice> practicesChosen,
  ) {
    switch (type) {
      case ContractType.sexual:
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Práticas permitidas'),
              ...List.generate(
                practicesTaken.length,
                (index) {
                  final practice = practicesTaken[index];

                  return practice.buildTile(users);
                },
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_) {
                          for (final ele in practicesTaken) {
                            practicesAvailable.remove(ele);
                          }

                          return SingleSelectDialog<SexualPractice>(
                            title: 'Selecione uma prática',
                            getName: (option) => option.description,
                            onChoose: onPracticeChosen,
                            options: practicesAvailable,
                            optionSelected: null,
                          );
                        });
                  },
                  child: const IntrinsicWidth(
                    child: Row(
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 12),
                        Text('Adicionar prática'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Com que frequência você realiza as práticas marcadas acima?'),
              StatefulSegmentedButton<String>(
                options: const ['Nunca', 'Ocasionalmente', 'Frequentemente', 'Sempre'],
                getLabel: (value) => value,
                getValue: (value) => value,
                initialSelection: {periodicitySelected},
                onChanged: (value) {
                  periodicitySelected = value.first;
                  setState(() {});
                },
              ),
              const SizedBox(height: 10),
              const Text('Você costuma usar preservativo nas práticas sexuais?'),
              StatefulSegmentedButton<String>(
                options: const ['Nunca', 'As vezes', 'Na maioria das vezes', 'Sempre'],
                getLabel: (value) => value,
                getValue: (value) => value,
                initialSelection: {periodicitySelected},
                onChanged: (value) {
                  periodicitySelected = value.first;
                  setState(() {});
                },
              ),
              const SizedBox(height: 10),
              const Text('Já compartilhou seringas, agulhas ou outros objetos perfurantes?'),
              ListTile(
                title: const Text('Sim'),
                leading: Radio(
                  value: true,
                  groupValue: sharesNeedle,
                  onChanged: (value) {
                    sharesNeedle = true;
                    setState(() {});
                  },
                ),
              ),
              ListTile(
                title: const Text('Não'),
                leading: Radio(
                  value: false,
                  groupValue: sharesNeedle,
                  onChanged: (value) {
                    sharesNeedle = false;
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        );
      case ContractType.buyAndSale:
        return const SizedBox.shrink();
    }
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
                if (typeSelected != null)
                  _buildPracticesContent(
                    typeSelected!,
                    userData.getConnections.map((e) => e.user).toList(),
                    appData.getPractices,
                    practicesTaken,
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
  }
}

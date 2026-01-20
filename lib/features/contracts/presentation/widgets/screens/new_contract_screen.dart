import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:trustme/core/extensions/context_extensions.dart';

import 'package:trustme/core/enums/contract_status.dart';
import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/core/providers/user_data_event.dart';
import 'package:trustme/features/common/domain/entities/user.dart';
import 'package:trustme/features/common/presentation/widgets/components/custom_scaffold.dart';
import 'package:trustme/features/common/presentation/widgets/components/header_line.dart';
import 'package:trustme/features/contracts/domain/entities/clause.dart';
import 'package:trustme/features/contracts/domain/entities/contract.dart';
import 'package:trustme/features/contracts/domain/entities/contract_type.dart';
import 'package:trustme/features/contracts/domain/entities/sexual_practice.dart';
import 'package:trustme/features/contracts/presentation/widgets/components/clause_selection_card.dart';
import 'package:trustme/features/contracts/presentation/widgets/components/contract_specification_widget.dart';
import 'package:trustme/features/contracts/presentation/widgets/components/new_contract_header.dart';

class NewContractScreen extends StatefulWidget {
  const NewContractScreen({super.key});

  @override
  State<NewContractScreen> createState() => _NewContractScreenState();
}

class _NewContractScreenState extends State<NewContractScreen> {
  User? stakeHolderSelected;
  ContractType? typeSelected;
  final List<Clause> currentClauses = [];
  final List<SexualPractice> practicesTaken = [];
  bool sharesNeedle = false;
  DateTime? startDate;
  DateTime? endDate;
  int validity = 24;

  List<Clause> allClauses = [];
  List<SexualPractice> allPractices = [];
  bool _isLoadingClauses = false;

  String periodicitySelected = 'Nunca';

  void _setStakeHolder(User user) {
    if (stakeHolderSelected == user) {
      stakeHolderSelected = null;
    } else {
      stakeHolderSelected = user;
    }
    setState(() {});
  }

  void _setType(ContractType type) {
    setState(() {
      currentClauses.clear();
      practicesTaken.clear();
      allClauses.clear();
      allPractices.clear();

      if (typeSelected == type) {
        typeSelected = null;
      } else {
        typeSelected = type;
        _isLoadingClauses = true;
        context.read<UserDataCubit>().fetchClausesForType(typeSelected!);
      }
    });
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
    setState(() {});
  }

  void onPracticeRemoved(SexualPractice value) {
    practicesTaken.remove(value);
    setState(() {});
  }

  @override
  void dispose() {
    practicesTaken.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = context.read<UserDataCubit>();

    return CustomScaffold(
      child: BlocListener<UserDataCubit, UserDataState>(
        listener: (context, state) {
          if (state is UserDataReady && state.event is ClausesFetchResult) {
            final event = state.event as ClausesFetchResult;
            setState(() {
              _isLoadingClauses = false;
            });

            if (event.isSuccess) {
              setState(() {
                allClauses = event.clauses ?? [];
                allPractices = event.practices ?? [];
                currentClauses.addAll(allClauses);
                practicesTaken.addAll(allPractices);
              });
            } else {
              context.showSnack(event.message ?? 'Falha ao buscar cláusulas.');
            }
            userData.clearEvent();
          }
        },
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
                      onTypeSelected: (value) => _setType(value),
                      currentStakeHolder: stakeHolderSelected,
                      currentType: typeSelected,
                      currentValidity: validity,
                      onStartSet: (value) => startDate = value,
                      onEndSet: (value) => endDate = value,
                      onValiditySet: (value) => validity = value,
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingClauses)
                      const Center(child: CircularProgressIndicator())
                    else if (allClauses.isNotEmpty)
                      ClauseSelectionCard(
                        canEdit: false,
                        contractor: userData.getUser,
                        stakeHolders: stakeHolderSelected != null ? [stakeHolderSelected!] : [],
                        possibleClauses: allClauses,
                        clausesChosen: currentClauses,
                        onClausePicked: _addClause,
                        onRemove: _removeClause,
                        onAcceptOrDeny: null,
                      ),
                    const SizedBox(height: 12),
                    if (typeSelected != null && stakeHolderSelected != null && allPractices.isNotEmpty)
                      ContractSpecificationWidget(
                        canEdit: false,
                        type: typeSelected!,
                        practicesAvailable: allPractices,
                        initialPractices: practicesTaken,
                        participants: [userLoggedIn],
                        onPick: onPracticeChosen,
                        onRemove: null,
                        showStatusPerUser: false,
                        onAcceptOrDeny: null,
                        answers: const [],
                        onQuestionAnswered: (question, answer) {},
                      ),
                    const SizedBox(height: 12),
                    if (typeSelected != null && stakeHolderSelected != null)
                      FilledButton(
                        onPressed: () async {
                          final newContract = Contract(
                            id: 0,
                            contractNumber: '',
                            status: ContractStatus.pending,
                            contractor: userLoggedIn,
                            type: typeSelected!,
                            stakeHolders: [stakeHolderSelected!],
                            clauses: currentClauses,
                            sexualPractices: practicesTaken,
                            duration: validity,
                            signatures: const [],
                            answers: const [],
                            startDt: DateTime.now(),
                            endDt: DateTime.now(),
                          );

                          await userData.createContract(newContract);
                          context.pop();
                        },
                        child: const Text('Criar contrato'),
                      )
                  ],
                ),
              );
            }
            // Should ideally show a loading or error state based on UserDataCubit state
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

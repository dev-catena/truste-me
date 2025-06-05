import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../../../../common/domain/entities/person.dart';
import '../../../data/data_source/contract_datasource.dart';
import '../../../domain/entities/clause.dart';
import '../../../domain/entities/contract.dart';
import '../../../domain/entities/sexual_practice.dart';

part 'contract_detail_event.dart';

part 'contract_detail_state.dart';

class ContractDetailBloc extends Bloc<ContractDetailEvent, ContractDetailState> {
  final ContractDataSource datasource;
  final Contract preliminaryContract;

  ContractDetailBloc(this.datasource, this.preliminaryContract) : super(ContractDetailInitial()) {
    on<ContractDetailStarted>(_onStarted);
    on<ContractDetailClauseAdded>(_onClauseAdded);
    on<ContractDetailClauseSet>(_onClauseSet);
  }

  Future<void> _onStarted(ContractDetailStarted event, Emitter<ContractDetailState> emit) async {
    emit(ContractDetailLoadInProgress());

    List<Clause> possibleClauses = [];
    List<SexualPractice> possiblePracs = [];
    late final Contract contract;

    // try {
    await Future.wait([
      datasource.getClausesForContractType(preliminaryContract.type).then((value) {
        possibleClauses = value.clauses;
        possiblePracs = value.practices;
      }),
      datasource.getContractFullInfo(preliminaryContract).then((value) => contract = value),
    ]);

    final List<Clause> contractClauses = List<Clause>.of(contract.clauses);

    final filteredClauses = _removeCurrentClausesFromAll(possibleClauses, contractClauses);

    emit(ContractDetailReady(
      contract: contract,
      possibleClauses: filteredClauses,
      possiblePractices: possiblePracs,
    ));
    // } catch(e, s){
    //   emit(ContractDetailError(e.toString()));
    // }
  }

  Future<void> _onClauseAdded(ContractDetailClauseAdded event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;
    final updatedContract = internState.contract
      ..clauses.add(
        event.selectedClause.copyWith(
          acceptedBy: [internState.contract.contractor!.id],
          pendingFor: internState.contract.stakeHolders.map((e) => e.id).toList(),
        ),
      );

    // final possibleClauses = internState.possibleClauses..remove(event.selectedClause);
    final filteredClauses = List<Clause>.of(internState.possibleClauses);
    filteredClauses.remove(event.selectedClause);

    emit(internState.copyWith(contract: updatedContract, possibleClauses: filteredClauses));
  }

  Future<void> _onClauseSet(ContractDetailClauseSet event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;

    await datasource.acceptOrDenyClause(internState.contract, event.selectedClause, event.hasAccepted);
    final updatedClause = internState.contract.clauses.firstWhere((element) => element == event.selectedClause);

    updatedClause.pendingFor.remove(userLoggedIn.id);

    if (event.hasAccepted) {
      updatedClause.deniedBy.remove(userLoggedIn.id);
      updatedClause.acceptedBy.add(userLoggedIn.id);
    } else {
      updatedClause.acceptedBy.remove(userLoggedIn.id);
      updatedClause.deniedBy.add(userLoggedIn.id);
    }

    final index = internState.contract.clauses.indexOf(event.selectedClause);
    final updatedClauseList = List.of(internState.contract.clauses);

    updatedClauseList.removeAt(index);
    updatedClauseList.insert(index, updatedClause);

    final updatedContract = internState.contract;
    updatedContract.clauses.clear();
    updatedContract.clauses.addAll(updatedClauseList);

    emit(internState.copyWith(contract: updatedContract));
  }

  List<Clause> _removeCurrentClausesFromAll(List<Clause> allClauses, List<Clause> currentClauses) {
    for (final ele in currentClauses) {
      allClauses.remove(ele);
    }

    return allClauses;
  }
}

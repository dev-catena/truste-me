import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../../../data/data_source/contract_datasource.dart';
import '../../../domain/entities/clause.dart';
import '../../../domain/entities/contract.dart';

part 'contract_detail_event.dart';

part 'contract_detail_state.dart';

class ContractDetailBloc extends Bloc<ContractDetailEvent, ContractDetailState> {
  final ContractDataSource datasource;
  final Contract preliminaryContract;

  ContractDetailBloc(this.datasource, this.preliminaryContract) : super(ContractDetailInitial()) {
    on<ContractDetailStarted>(_onStarted);
    on<ContractDetailClauseAdded>(_onClauseAdded);
  }

  Future<void> _onStarted(ContractDetailStarted event, Emitter<ContractDetailState> emit) async {
    emit(ContractDetailLoadInProgress());

    List<Clause> possibleClauses = [];
    late final Contract contract;

    // try {
    await Future.wait([
      datasource.getClausesForContractType(preliminaryContract.type).then((value) => possibleClauses = value),
      datasource.getContractFullInfo(preliminaryContract).then((value) => contract = value),
    ]);

    final List<Clause> contractClauses = List<Clause>.of(contract.clauses);

    final filteredClauses = _removeCurrentClausesFromAll(possibleClauses, contractClauses);

    emit(ContractDetailReady(contract: contract, possibleClauses: filteredClauses));
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

  List<Clause> _removeCurrentClausesFromAll(List<Clause> allClauses, List<Clause> currentClauses) {
    for (final ele in currentClauses) {
      allClauses.remove(ele);
    }

    return allClauses;
  }
}
